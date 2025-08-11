// tbverify/tb_capture_top.v
`timescale 1ns / 1ps

// This wrapper instantiates the original testbench and captures its output.

`include "tb/tb_top.v"

module tb_capture_top;

    // Instantiate the original testbench
    top_tb testbench_inst ();

    // --- Golden Data Generation ---
    integer file;
    initial begin
        file = $fopen("./tbverify/golden_top.txt", "w");
        if (file == 0) begin
            $display("Error: Could not open ./tbverify/golden_top.txt for writing.");
            $finish;
        end
    end

    // At every positive clock edge inside the instantiated testbench,
    // write the nout and st signals to the file.
    always @(posedge testbench_inst.clk) begin
        // Only start writing after reset is done
        if (testbench_inst.rstn) begin
            $fwrite(file, "%h %b\n", testbench_inst.nout, testbench_inst.st);
        end
    end

endmodule
