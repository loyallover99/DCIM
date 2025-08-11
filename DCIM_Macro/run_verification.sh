#!/bin/bash

# Compile the RTL sources and the verification testbench
iverilog -o verify_top.vvp rtl/*.v tbverify/tb_verify_top.v

# Run the verification simulation
vvp verify_top.vvp

echo "Verification simulation finished."
