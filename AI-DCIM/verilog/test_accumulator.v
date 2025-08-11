// test_accumulator.v
// Testbench for the accumulator module.

`timescale 1ns / 1ps

module test_accumulator;

    // Parameters
    localparam INPUT_WIDTH = 27;
    localparam OUTPUT_WIDTH = 51;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg start_acc;
    reg [INPUT_WIDTH-1:0] psum_in;

    wire [OUTPUT_WIDTH-1:0] nout;

    // Instantiate the DUT
    accumulator #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start_acc(start_acc),
        .psum_in(psum_in),
        .nout(nout)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Main test sequence
    initial begin
        // 1. Initialization
        clk = 0;
        rst_n = 0;
        start_acc = 0;
        psum_in = 0;
        #10;
        rst_n = 1;
        #10;

        // 2. Start accumulation
        start_acc = 1;
        #10;
        start_acc = 0;

        // 3. Provide input data
        psum_in = 24;
        #10;
        psum_in = 24;
        #10;
        psum_in = 24;
        #10;

        // 4. Check result
        // Expected: ( ( (0 << 1) + 24) << 1) + 24 = 72
        $display("Test finished. Output nout = %d", nout);

        #100;
        $finish;
    end

endmodule
