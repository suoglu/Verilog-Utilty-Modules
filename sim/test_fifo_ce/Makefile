TOPLEVEL_LANG = verilog

# Your Verilog sources
VERILOG_SOURCES = $(PWD)/../../Modules/fifo.v

# Top-level module name in Verilog
COCOTB_TOPLEVEL = fifo_ce

# Python test module (test_fifo_ce.py)
COCOTB_TEST_MODULES = test_fifo_ce

SIM = icarus

DATA_WIDTH ?= 32
FIFO_DEPTH ?= 16   

COMPILE_ARGS += -P fifo_ce.DATA_WIDTH=$(DATA_WIDTH)
COMPILE_ARGS += -P fifo_ce.FIFO_DEPTH=$(FIFO_DEPTH)

FIFO_DEPTHS = 22 64

.PHONY: run_all

run_all:
	$(MAKE) SIM_BUILD=sim_build_22 FIFO_DEPTH=22 sim
	$(MAKE) SIM_BUILD=sim_build_64 FIFO_DEPTH=64 sim

include $(shell cocotb-config --makefiles)/Makefile.sim
