import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ReadOnly


async def reset_dut(dut):
    """Reset the DUT."""
    dut.rst.value = 0
    await RisingEdge(dut.clk)
    dut.rst.value = 1
    dut.push.value = 0
    dut.drop.value = 0
    dut.data_i.value = 0

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    dut.rst.value = 0
    await RisingEdge(dut.clk)  # one cycle after reset deassert


async def push_word(dut, value, hold_cycles=1):
    """Push one word into the FIFO (edge sensitive)."""
    dut.data_i.value = value
    await RisingEdge(dut.clk)
    dut.push.value = 1
    for _ in range(hold_cycles):
        await RisingEdge(dut.clk)
    dut.push.value = 0


async def drop_word(dut, hold_cycles=1):
    """Drop (read) one word from the FIFO (edge sensitive)."""
    # data_o shows the *current* head; we sample after the drop edge
    val = int(dut.data_o.value)
    dut.drop.value = 1
    for _cycle in range(hold_cycles):
        await RisingEdge(dut.clk)
    dut.drop.value = 0
    return val


@cocotb.test()
async def test_reset_and_flags(dut):
    """Check reset behavior and initial flags."""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    # After reset: FIFO must be empty, not full, count = 0
    assert dut.fifo_empty.value == 1, "FIFO should be empty after reset"
    assert dut.fifo_full.value == 0, "FIFO should not be full after reset"
    assert int(dut.awaiting_count.value) == 0, "awaiting_count must be 0 after reset"


@cocotb.test()
async def test_single_push_pop(dut):
    """Push one word and pop it back."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    test_word = 0xDEADBEEF

    # Push one word
    await push_word(dut, test_word)

    await ReadOnly()  # ensure we read stable values

    # After single push: not empty, not full (for reasonable depth), count = 1
    assert dut.fifo_empty.value == 0, "FIFO should not be empty after one push"
    assert int(dut.awaiting_count.value) == 1, "awaiting_count should be 1 after one push"

    # Data at head must be what we pushed
    got_head = int(dut.data_o.value)
    assert got_head == test_word, f"Head data mismatch: got 0x{got_head:X}, expected 0x{test_word:X}"

    await RisingEdge(dut.clk)

    # Drop it
    got = await drop_word(dut)
    assert got == test_word, f"FIFO pop mismatch: got 0x{got:X}, expected 0x{test_word:X}"

    await ReadOnly()  # ensure we read stable values

    # Now FIFO should be empty again
    assert dut.fifo_empty.value == 1, "FIFO should be empty after popping the only item"
    assert int(dut.awaiting_count.value) == 0, "awaiting_count should be 0 after pop"


@cocotb.test()
async def test_fill_and_full_flag(dut):
    """Fill FIFO to capacity, check full flag and behavior on extra push."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    if not hasattr(dut, "FIFO_DEPTH"):
        raise TestFailure("DUT does not expose FIFO_DEPTH parameter")

    depth = int(dut.FIFO_DEPTH.value)

    # Fill FIFO
    for i in range(depth):
        await push_word(dut, i)
        await RisingEdge(dut.clk) # wait a cycle between pushes for edge sensitivity
    
    await ReadOnly()  # ensure we read stable values

    assert dut.fifo_full.value == 1, f"fifo_full should be asserted when FIFO is full {dut.awaiting_count.value} != {depth}"
    assert dut.fifo_empty.value == 0, "fifo_empty should not be asserted when FIFO is full"
    assert int(dut.awaiting_count.value) == depth, "awaiting_count should equal FIFO_DEPTH when full"

    await RisingEdge(dut.clk)

    # Try one extra push (should be ignored by design)
    await push_word(dut, 0x12345678)
    await ReadOnly()  # ensure we read stable values
    assert int(dut.awaiting_count.value) == depth, "awaiting_count should not increase beyond full"

    await RisingEdge(dut.clk)

    # Read everything back and verify order
    for i in range(depth):
        val = await drop_word(dut)
        await RisingEdge(dut.clk) # wait a cycle between drops for edge sensitivity
        assert val == i, f"FIFO order error at index {i}: got {val}, expected {i}"

    await ReadOnly()  # ensure we read stable values

    assert dut.fifo_empty.value == 1, "fifo_empty should be asserted after draining FIFO"
    assert int(dut.awaiting_count.value) == 0, "awaiting_count should be 0 after draining FIFO"


@cocotb.test()
async def test_randomized_sequence(dut):
    """Random pushes/drops against a Python reference model."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    if not hasattr(dut, "FIFO_DEPTH"):
        raise TestFailure("DUT does not expose FIFO_DEPTH parameter")

    data_width = 32
    depth = int(dut.FIFO_DEPTH.value)
    mask = (1 << data_width) - 1

    model = []  # software model of FIFO contents

    num_cycles = 500

    for cycle in range(num_cycles):
        hw_count = int(dut.awaiting_count.value)
        hw_empty = bool(dut.fifo_empty.value)
        hw_full = bool(dut.fifo_full.value)

        # Sanity checks vs model
        assert hw_count == len(model), f"[cycle {cycle}] awaiting_count mismatch: hw={hw_count}, model={len(model)}"
        assert hw_empty == (len(model) == 0), f"[cycle {cycle}] fifo_empty mismatch"
        assert hw_full == (len(model) == depth), f"[cycle {cycle}] fifo_full mismatch"

        # Decide random operation:
        do_push = False
        do_drop = False

        if len(model) == 0:
            # can't drop from empty
            do_push = True
        elif len(model) == depth:
            # can't push into full
            do_drop = True
        else:
            # random choice
            choice = random.randint(0, 2)
            if choice == 0:
                do_push = True
            elif choice == 1:
                do_drop = True
            else:
                # idle cycle, no operation
                pass

        if do_push:
            value = random.getrandbits(data_width) & mask
            model.append(value)
            await push_word(dut, value)
        elif do_drop:
            expected = model.pop(0)
            got = await drop_word(dut)
            assert got == expected, f"[cycle {cycle}] drop mismatch: got 0x{got:X}, expected 0x{expected:X}"
        await RisingEdge(dut.clk) # wait a cycle between operations for edge sensitivity

    # Final consistency check
    assert int(dut.awaiting_count.value) == len(model), "Final awaiting_count mismatch at end of randomized test"
    assert bool(dut.fifo_empty.value) == (len(model) == 0), "Final fifo_empty mismatch at end of randomized test"
    assert bool(dut.fifo_full.value) == (len(model) == depth), "Final fifo_full mismatch at end of randomized test"

@cocotb.test()
async def test_edge_sensitivity(dut):
    """Test that push/drop are edge sensitive."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    test_word1 = 0xBEEFBABE
    test_word2 = 0xFEEDFACE

    # Push first word
    await push_word(dut, test_word1, hold_cycles=3)
    await ReadOnly()
    assert int(dut.awaiting_count.value) == 1, "awaiting_count should be 1 after first push edge"
    await RisingEdge(dut.clk)

    # Add another push without dropping
    await push_word(dut, test_word2, hold_cycles=9)
    await ReadOnly()
    assert int(dut.awaiting_count.value) == 2, "awaiting_count should be 2 after second push edge"
    await RisingEdge(dut.clk)

    # Drop first word
    got1 = await drop_word(dut, hold_cycles=5)
    assert got1 == test_word1, f"First drop mismatch: got 0x{got1:X}, expected 0x{test_word1:X}"
    await ReadOnly()
    assert int(dut.awaiting_count.value) == 1, "awaiting_count should be 1 after first drop edge"
