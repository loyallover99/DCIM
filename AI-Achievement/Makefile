# Makefile for Verilog simulation

# Compiler
VERILOG = iverilog

# Simulation runtime
VVP = vvp

# Waveform viewer
WAVE_VIEWER = gtkwave

# Verilog source files
# Use wildcard to get all .v files in the current directory
SOURCES = $(wildcard *.v)

# Testbench file
TESTBENCH = top_tb.v

# Output file
OUTPUT = top_tb.vvp

# Waveform file
WAVEFORM = top_tb.vcd

.PHONY: all compile run wave clean

all: run

# Compile the Verilog source files
compile: $(SOURCES)
	$(VERILOG) -o $(OUTPUT) $(SOURCES)

# Run the simulation
run: compile
	$(VVP) $(OUTPUT)

# Open the waveform file
wave: $(WAVEFORM)
	$(WAVE_VIEWER) $(WAVEFORM)

# Clean up generated files
clean:
	rm -f $(OUTPUT) $(WAVEFORM)
