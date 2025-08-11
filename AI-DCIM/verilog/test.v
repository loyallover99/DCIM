// test.v
// Testbench for the top-level DCIM module.

`timescale 1ns / 1ps

module test;

    // Parameters
    localparam INPUT_WIDTH = 144;
    localparam WEIGHT_BITS = 12;
    localparam ACC_WIDTH = 51;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg start_op;
    reg [0:0] wwidth;
    reg [0:0] inwidth;
    reg we;
    reg [7:0] wa;
    reg [WEIGHT_BITS-1:0] d_in;
    reg [INPUT_WIDTH-1:0] xin;

    wire [ACC_WIDTH-1:0] nout;
    wire op_done;

    // Instantiate the DUT (Device Under Test)
    top #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .WEIGHT_BITS(WEIGHT_BITS),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start_op(start_op),
        .wwidth(wwidth),
        .inwidth(inwidth),
        .we(we),
        .wa(wa),
        .d_in(d_in),
        .xin(xin),
        .nout(nout),
        .op_done(op_done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Monitor op_done
    always @(posedge clk) begin
        if (op_done) begin
            $display("op_done asserted at time %t", $time);
        end
    end

    // Main test sequence
    initial begin
        // 1. Initialization
        clk = 0;
        rst_n = 0;
        start_op = 0;
        wwidth = 0; // 12-bit weights
        inwidth = 0; // 12-bit inputs
        we = 0;
        wa = 0;
        d_in = 0;
        xin = 0;
        #10;
        rst_n = 1;
        #10;

        // 2. Load Weights (simplified)
        we = 1;
        for (integer i = 0; i < INPUT_WIDTH; i = i + 1) begin
            wa = i;
            d_in = 12'h001;
            #10;
        end
        we = 0;
        #10;

        // 3. Load Input Vector
        xin = {132'b0, 12'hFFF};
        #10;

        // 4. Start MAC operation
        start_op = 1;
        #10;
        start_op = 0;

        // 5. Wait for completion
        wait (op_done);
        #10;

        // 6. Check result
        $display("Test finished. Output nout = %h", nout);

        #100;
        $finish;
    end

endmodule