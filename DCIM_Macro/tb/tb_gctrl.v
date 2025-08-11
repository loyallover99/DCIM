`timescale 1ns / 1ps

module tb_gctrl;

    // Inputs
    reg clk;
    reg rstn;
    reg start;
    reg inwidth;

    // Outputs
    wire [5:0] sel;
    wire st;

    // Instantiate the Unit Under Test (UUT)
    gctrl uut (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .inwidth(inwidth),
        .sel(sel),
        .st(st)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize Inputs
        rstn = 0;
        start = 0;
        inwidth = 0;

        $dumpfile("tb_gctrl.vcd");
        $dumpvars(0, tb_gctrl);
        $monitor("Time=%0t rstn=%b start=%b inwidth=%b | st=%b sel=%d", $time, rstn, start, inwidth, st, sel);

        // Test Case 1: Reset
        $display("--- Test Case 1: Reset ---");
        #10;
        rstn = 1;
        #10;
        $display("Reset released. st should be 1, sel should be 0.");

        // Test Case 2: 12-bit mode (inwidth=0)
        $display("--- Test Case 2: 12-bit mode (inwidth=0) ---");
        inwidth = 0;
        start = 1;
        @(posedge clk); #1;
        start = 0;
        @(posedge clk); #1;
        $display("Start pulse given. st should go to 0 and sel should start counting.");
        wait (st == 1);
        $display("12-bit mode finished. sel reached %d.", sel);
        #20;

        // Test Case 3: 24-bit mode (inwidth=1)
        $display("--- Test Case 3: 24-bit mode (inwidth=1) ---");
        inwidth = 1;
        start = 1;
        @(posedge clk); #1;
        start = 0;
        @(posedge clk); #1;
        $display("Start pulse given. st should go to 0 and sel should start counting.");
        wait (st == 1);
        $display("24-bit mode finished. sel reached %d.", sel);
        #20;

        // Test Case 4: Start during operation (should be ignored)
        $display("--- Test Case 4: Start during operation ---");
        inwidth = 0;
        start = 1;
        @(posedge clk); #1;
        start = 0;
        @(posedge clk); #1;
        // after a few cycles, assert start again
        #30;
        $display("Asserting start again while counting...");
        start = 1;
        @(posedge clk); #1;
        start = 0;
        wait (st == 1);
        $display("12-bit mode finished. Re-start was ignored.");
        #20;

        // Test Case 5: Reset during operation
        $display("--- Test Case 5: Reset during operation ---");
        inwidth = 1; // 24-bit mode
        start = 1;
        @(posedge clk); #1;
        start = 0;
        @(posedge clk); #1;
        #50; // Let it run for a while
        $display("Asserting reset during operation. sel is %d", sel);
        rstn = 0;
        #10;
        rstn = 1;
        #10;
        $display("Reset released. st should be 1, sel should be 0.");
        if (st === 1 && sel === 0)
            $display("PASSED: State correctly reset.");
        else
            $display("FAILED: State not reset correctly.");

        #20;
        $finish;
    end

endmodule