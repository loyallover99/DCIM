// accumulator.v
// Global accumulator with shifting for multi-cycle accumulation.

module accumulator #(
    parameter INPUT_WIDTH = 27, // Width of the input partial sum
    parameter OUTPUT_WIDTH = 51 // Width of the final accumulated output
)(
    input wire clk,
    input wire rst_n,             // Asynchronous reset, active low
    input wire start_acc,         // Signal from gctrl to start a new accumulation
    input wire [INPUT_WIDTH-1:0] psum_in, // Partial sum from global_io

    output reg [OUTPUT_WIDTH-1:0] nout   // Final accumulated result
);

    reg [OUTPUT_WIDTH-1:0] acc_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_reg <= 0;
            nout <= 0;
        end else begin
            if (start_acc) begin
                // When a new operation starts, reset the accumulator.
                acc_reg <= 0;
            end else begin
                // Accumulate on the subsequent cycles.
                // This ensures we don't miss the first psum.
                acc_reg <= (acc_reg << 1) + {{ (OUTPUT_WIDTH - INPUT_WIDTH){psum_in[INPUT_WIDTH-1]} }, psum_in};
            end
            nout <= acc_reg;
        end
    end

endmodule
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
