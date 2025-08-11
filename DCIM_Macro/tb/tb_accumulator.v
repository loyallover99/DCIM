`timescale 1ns / 1ps

module tb_accumulator;

    // Inputs
    reg [26:0] a;
    reg clk;
    reg acm_en;
    reg rstn;
    reg st;

    // Outputs
    wire [50:0] nout;

    // Instantiate the Unit Under Test (UUT)
    accumulator uut (
        .a(a),
        .clk(clk),
        .acm_en(acm_en),
        .rstn(rstn),
        .st(st),
        .nout(nout)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Declare variables outside of initial block
    integer i, j;
    reg [50:0] expected_nout;

    initial begin
        // Initialize Inputs
        a = 0;
        acm_en = 0;
        rstn = 0;
        st = 1;

        $dumpfile("tb_accumulator.vcd");
        $dumpvars(0, tb_accumulator);
        $monitor("Time=%0t rstn=%b acm_en=%b st=%b a=%d nout=%d", 
                 $time, rstn, acm_en, st, a, nout);

        // Test Case 1: Reset
        $display("\n--- Test Case 1: Reset ---");
        #10;
        rstn = 1;
        #10;
        $display("Reset released. nout should be 0. nout = %d", nout);

        // Test Case 2: Accumulation disabled
        $display("\n--- Test Case 2: Accumulation disabled (acm_en=0) ---");
        acm_en = 0;
        st = 0;
        a = 100;
        #20; // Wait for a few clock cycles
        $display("nout should remain 0. nout = %d", nout);

        // Test Case 3: Accumulation enabled and running
        $display("\n--- Test Case 3: Accumulation enabled and running ---");
        acm_en = 1;
        st = 0;
        a = 10; @(posedge clk); #1; // Cycle 1: nout = (0 << 1) + 10 = 10
        $display("Cycle 1: a=%d, nout=%d", 10, nout);
        a = 20; @(posedge clk); #1; // Cycle 2: nout = (10 << 1) + 20 = 40
        $display("Cycle 2: a=%d, nout=%d", 20, nout);
        a = 30; @(posedge clk); #1; // Cycle 3: nout = (40 << 1) + 30 = 110
        $display("Cycle 3: a=%d, nout=%d", 30, nout);
        a = 0; @(posedge clk); #1; // Cycle 4: nout = (110 << 1) + 0 = 220
        $display("Cycle 4: a=%d, nout=%d", 0, nout);

        // Test Case 4: 'st' signal stops and resets accumulation
        $display("\n--- Test Case 4: 'st' signal high ---");
        st = 1;
        a = 999; // This value should be ignored
        @(posedge clk); #1;
        $display("st is high, nout should reset to 0. nout = %d", nout);
        st = 0;
        a = 5;
        @(posedge clk); #1;
        $display("st is low again, accumulation starts from 0. nout = %d", nout);

        // Test Case 5: Negative reset
        $display("\n--- Test Case 5: Negative reset (rstn=0) ---");
        rstn = 0;
        #10;
        $display("rstn is low, nout should reset to 0. nout = %d", nout);
        rstn = 1; // Release reset for next test
        #10;

        // Test Case 6: Long accumulation sequence
        $display("\n--- Test Case 6: Long accumulation sequence ---");
        st = 1; @(posedge clk); #1; // Reset accumulator
        st = 0;
        acm_en = 1;
        
        expected_nout = 0;
        
        for (i = 1; i <= 10; i = i + 1) begin
            a = i;
            expected_nout = (expected_nout << 1) + i;
            @(posedge clk); #1;
            $display("Cycle %0d: a=%d, nout=%d (expected %d)", 
                     i, i, nout, expected_nout);
        end

        // Test Case 7: Overflow test
        $display("\n--- Test Case 7: Overflow Test ---");
        st = 1; @(posedge clk); #1; // Reset accumulator
        st = 0;
        a = 27'h7FFFFFF; // Max positive value (134,217,727)
        expected_nout = 0;
        
        @(posedge clk); #1;
        expected_nout = (expected_nout << 1) + a;
        $display("First value loaded: nout = %h (expected %h)", 
                 nout, expected_nout);
        
        // Add large numbers to force overflow
        for (j = 0; j < 5; j = j + 1) begin
            a = 27'h7FFFFFF;
            expected_nout = (expected_nout << 1) + a;
            @(posedge clk); #1;
            $display("Cycle %0d: nout = %h (expected %h)", 
                     j+1, nout, expected_nout);
        end

        #20;
        $finish;
    end

endmodule