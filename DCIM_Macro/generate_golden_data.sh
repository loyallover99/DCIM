#!/bin/bash

# Compile the RTL sources and the testbench
iverilog -o sim.vvp rtl/*.v tb/tb_top.v

# Run the simulation and redirect stdout to the golden data file
vvp sim.vvp > tbverify/golden_top.txt

echo "Golden data generated in tbverify/golden_top.txt"
