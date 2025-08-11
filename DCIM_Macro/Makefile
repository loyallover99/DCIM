# Makefile for Verilog Simulation

# --- Compiler and Tools ---
VERILOG_COMPILER = iverilog
VVP = vvp
WAVE_VIEWER = gtkwave

# --- Source Files ---
RTL_SOURCES = $(wildcard rtl/*.v)
TB_SOURCES = $(wildcard tb/*.v)
VERIFY_TB_SOURCES = $(wildcard tb_verify/*.v)

# --- Primary Targets ---
all: test_all

test_all: test_oai_mult test_add test_s_cla test_se_cla test_accumulator test_cim_bank test_cim_array_ctrl test_cim_array test_rwldrv test_local_mac test_gctrl test_global_io test_top_full

verify_all: verify_oai_mult verify_add verify_s_cla verify_se_cla verify_accumulator verify_cim_bank verify_cim_array_ctrl verify_cim_array verify_rwldrv verify_local_mac verify_gctrl verify_global_io

# --- Individual Test Targets ---

test_oai_mult:
	@echo "--- Running test for oai_mult ---"
	$(VERILOG_COMPILER) -o tb_oai_mult.vvp rtl/oai_mult.v tb/tb_oai_mult.v
	$(VVP) tb_oai_mult.vvp

test_add:
	@echo "--- Running test for add ---"
	$(VERILOG_COMPILER) -o tb_add.vvp rtl/add.v tb/tb_add.v
	$(VVP) tb_add.vvp

test_s_cla:
	@echo "--- Running test for s_cla ---"
	$(VERILOG_COMPILER) -o tb_s_cla.vvp rtl/s_cla.v tb/tb_s_cla.v
	$(VVP) tb_s_cla.vvp

test_se_cla:
	@echo "--- Running test for se_cla ---"
	$(VERILOG_COMPILER) -o tb_se_cla.vvp rtl/se_cla.v rtl/add.v rtl/s_cla.v tb/tb_se_cla.v
	$(VVP) tb_se_cla.vvp

test_accumulator:
	@echo "--- Running test for accumulator ---"
	$(VERILOG_COMPILER) -o tb_accumulator.vvp rtl/accumulator.v rtl/se_cla.v rtl/add.v rtl/s_cla.v tb/tb_accumulator.v
	$(VVP) tb_accumulator.vvp

test_cim_bank:
	@echo "--- Running test for cim_bank ---"
	$(VERILOG_COMPILER) -o tb_cim_bank.vvp rtl/cim_bank.v tb/tb_cim_bank.v
	$(VVP) tb_cim_bank.vvp

test_cim_array_ctrl:
	@echo "--- Running test for cim_array_ctrl ---"
	$(VERILOG_COMPILER) -o tb_cim_array_ctrl.vvp rtl/cim_array_ctrl.v tb/tb_cim_array_ctrl.v
	$(VVP) tb_cim_array_ctrl.vvp

test_cim_array:
	@echo "--- Running test for cim_array ---"
	$(VERILOG_COMPILER) -o tb_cim_array.vvp rtl/cim_array.v rtl/cim_bank.v tb/tb_cim_array.v
	$(VVP) tb_cim_array.vvp

test_rwldrv:
	@echo "--- Running test for rwldrv ---"
	$(VERILOG_COMPILER) -o tb_rwldrv.vvp rtl/rwldrv.v tb/tb_rwldrv.v
	$(VVP) tb_rwldrv.vvp

test_local_mac:
	@echo "--- Running test for local_mac ---"
	$(VERILOG_COMPILER) -o tb_local_mac.vvp rtl/local_mac.v rtl/oai_mult.v rtl/add.v tb/tb_local_mac.v
	$(VVP) tb_local_mac.vvp

test_gctrl:
	@echo "--- Running test for gctrl ---"
	$(VERILOG_COMPILER) -o tb_gctrl.vvp rtl/gctrl.v tb/tb_gctrl.v
	$(VVP) tb_gctrl.vvp

test_global_io:
	@echo "--- Running test for global_io ---"
	$(VERILOG_COMPILER) -o tb_global_io.vvp rtl/global_io.v rtl/accumulator.v rtl/se_cla.v rtl/add.v rtl/s_cla.v tb/tb_global_io.v
	$(VVP) tb_global_io.vvp

test_top_full:
	@echo "--- Running test for top_full ---"
	$(VERILOG_COMPILER) -o tb_top_full.vvp $(RTL_SOURCES) tb/tb_top_full.v
	$(VVP) tb_top_full.vvp

# --- Individual Verification Targets ---

verify_oai_mult:
	@echo "--- Running verification for oai_mult ---"
	$(VERILOG_COMPILER) -o tb_verify_oai_mult.vvp rtl/oai_mult.v tb_verify/tb_verify_oai_mult.v
	$(VVP) tb_verify_oai_mult.vvp

verify_add:
	@echo "--- Running verification for add ---"
	$(VERILOG_COMPILER) -o tb_verify_add.vvp rtl/add.v tb_verify/tb_verify_add.v
	$(VVP) tb_verify_add.vvp

verify_s_cla:
	@echo "--- Running verification for s_cla ---"
	$(VERILOG_COMPILER) -o tb_verify_s_cla.vvp rtl/s_cla.v tb_verify/tb_verify_s_cla.v
	$(VVP) tb_verify_s_cla.vvp

verify_se_cla:
	@echo "--- Running verification for se_cla ---"
	$(VERILOG_COMPILER) -o tb_verify_se_cla.vvp rtl/se_cla.v rtl/add.v rtl/s_cla.v tb_verify/tb_verify_se_cla.v
	$(VVP) tb_verify_se_cla.vvp

verify_accumulator:
	@echo "--- Running verification for accumulator ---"
	$(VERILOG_COMPILER) -o tb_verify_accumulator.vvp rtl/accumulator.v rtl/se_cla.v rtl/add.v rtl/s_cla.v tb_verify/tb_verify_accumulator.v
	$(VVP) tb_verify_accumulator.vvp

verify_cim_bank:
	@echo "--- Running verification for cim_bank ---"
	$(VERILOG_COMPILER) -o tb_verify_cim_bank.vvp rtl/cim_bank.v tb_verify/tb_verify_cim_bank.v
	$(VVP) tb_verify_cim_bank.vvp

verify_cim_array_ctrl:
	@echo "--- Running verification for cim_array_ctrl ---"
	$(VERILOG_COMPILER) -o tb_verify_cim_array_ctrl.vvp rtl/cim_array_ctrl.v tb_verify/tb_verify_cim_array_ctrl.v
	$(VVP) tb_verify_cim_array_ctrl.vvp

verify_cim_array:
	@echo "--- Running verification for cim_array ---"
	$(VERILOG_COMPILER) -o tb_verify_cim_array.vvp rtl/cim_array.v rtl/cim_bank.v tb_verify/tb_verify_cim_array.v
	$(VVP) tb_verify_cim_array.vvp

verify_rwldrv:
	@echo "--- Running verification for rwldrv ---"
	$(VERILOG_COMPILER) -o tb_verify_rwldrv.vvp rtl/rwldrv.v tb_verify/tb_verify_rwldrv.v
	$(VVP) tb_verify_rwldrv.vvp

verify_local_mac:
	@echo "--- Running verification for local_mac ---"
	$(VERILOG_COMPILER) -o tb_verify_local_mac.vvp rtl/local_mac.v rtl/oai_mult.v rtl/add.v tb_verify/tb_verify_local_mac.v
	$(VVP) tb_verify_local_mac.vvp

verify_gctrl:
	@echo "--- Running verification for gctrl ---"
	$(VERILOG_COMPILER) -o tb_verify_gctrl.vvp rtl/gctrl.v tb_verify/tb_verify_gctrl.v
	$(VVP) tb_verify_gctrl.vvp

verify_global_io:
	@echo "--- Running verification for global_io ---"
	$(VERILOG_COMPILER) -o tb_verify_global_io.vvp rtl/global_io.v rtl/accumulator.v rtl/se_cla.v rtl/add.v rtl/s_cla.v tb_verify/tb_verify_global_io.v
	$(VVP) tb_verify_global_io.vvp

# --- Cleanup ---
clean:
	@echo "Cleaning up..."
	rm -f *.vvp *.vcd

.PHONY: all test_all verify_all clean test_oai_mult test_add test_s_cla test_se_cla test_accumulator test_cim_bank test_cim_array_ctrl test_cim_array test_rwldrv test_local_mac test_gctrl test_global_io test_top_full verify_oai_mult verify_add verify_s_cla verify_se_cla verify_accumulator verify_cim_bank verify_cim_array_ctrl verify_cim_array verify_rwldrv verify_local_mac verify_gctrl verify_global_io
