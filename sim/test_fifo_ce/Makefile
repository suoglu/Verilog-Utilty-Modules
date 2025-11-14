TOPLEVEL_LANG = verilog

# Your Verilog sources
VERILOG_SOURCES = $(PWD)/../../Modules/fifo.v

# Top-level module name in Verilog
COCOTB_TOPLEVEL = fifo_ce

# Python test module (test_fifo_ce.py)
COCOTB_TEST_MODULES = test_fifo_ce

SIM = icarus

COMPILE_ARGS += -P fifo_ce.DATA_WIDTH=32
COMPILE_ARGS += -P fifo_ce.FIFO_DEPTH=22

include $(shell cocotb-config --makefiles)/Makefile.sim
