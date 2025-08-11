`timescale 1ns / 1ps

module tb_global_io;

    // Inputs
    reg [14:0] macout_a;
    reg [14:0] macout_b;
    reg clk;
    reg acm_en;
    reg rstn;
    reg st;
    reg wwidth;

    // Outputs
    wire [50:0] nout;

    // Instantiate the Unit Under Test (UUT)
    global_io uut (
        .macout_a(macout_a),
        .macout_b(macout_b),
        .clk(clk),
        .acm_en(acm_en),
        .rstn(rstn),
        .st(st),
        .wwidth(wwidth),
        .nout(nout)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize Inputs
        macout_a = 0;
        macout_b = 0;
        acm_en = 0;
        rstn = 0;
        st = 1;
        wwidth = 0;

        $dumpfile("tb_global_io.vcd");
        $dumpvars(0, tb_global_io);
        $monitor("Time=%0t rstn=%b st=%b acm_en=%b wwidth=%b macout_a=%d macout_b=%d | nout=%d", $time, rstn, st, acm_en, wwidth, macout_a, macout_b, nout);

        // Test Case 1: Reset
        $display("--- Test Case 1: Reset ---");
        #10;
        rstn = 1;
        #10;
        $display("Reset released. nout should be 0.");

        // Test Case 2: 12-bit weight mode (wwidth=0)
        $display("--- Test Case 2: 12-bit weight mode (wwidth=0) ---");
        st = 1; @(posedge clk); #1; // Reset accumulator
        st = 0;
        acm_en = 1;
        wwidth = 0; // macout_b is ignored
        macout_a = 10; macout_b = 999; @(posedge clk); #1; // nout = 10
        macout_a = 20; macout_b = 888; @(posedge clk); #1; // nout = (10<<1)+20 = 40
        macout_a = 30; macout_b = 777; @(posedge clk); #1; // nout = (40<<1)+30 = 110
        $display("12-bit mode accumulation finished. nout = %d", nout);

        // Test Case 3: 24-bit weight mode (wwidth=1)
        $display("--- Test Case 3: 24-bit weight mode (wwidth=1) ---");
        st = 1; // Reset accumulator
        @(posedge clk); #1;
        st = 0;
        wwidth = 1;
        // add_out = macout_a + (macout_b << 12)
        macout_a = 10; macout_b = 1; @(posedge clk); #1; // nout = 10 + (1<<12) = 4106
        $display("Cycle 1: nout = %d", nout);
        macout_a = 20; macout_b = 2; @(posedge clk); #1; // nout = (4106<<1) + (20 + (2<<12)) = 8212 + 8212 = 16424
        $display("Cycle 2: nout = %d", nout);

        // Test Case 4: acm_en disable/enable
        $display("--- Test Case 4: acm_en disable/enable ---");
        st = 1; @(posedge clk); #1; // Reset accumulator
        st = 0;
        wwidth = 0;
        acm_en = 1;
        macout_a = 100; @(posedge clk); #1; // nout = 100
        $display("acm_en=1, nout = %d", nout);
        acm_en = 0;
        macout_a = 50; @(posedge clk); #1; // nout should not change
        $display("acm_en=0, nout = %d (should be 100)", nout);
        acm_en = 1;
        macout_a = 5; @(posedge clk); #1; // nout = (100<<1) + 5 = 205
        $display("acm_en=1 again, nout = %d", nout);

        // Test Case 5: st during operation
        $display("--- Test Case 5: st during operation ---");
        st = 0;
        wwidth = 0;
        acm_en = 1;
        macout_a = 1; @(posedge clk); #1; // nout = (205<<1) + 1 = 411
        macout_a = 2; @(posedge clk); #1; // nout = (411<<1) + 2 = 824
        st = 1; // Reset accumulator
        @(posedge clk); #1;
        $display("st asserted, nout should be 0. nout = %d", nout);
        st = 0;
        macout_a = 99; @(posedge clk); #1; // nout = 99
        $display("st de-asserted, accumulation restarts. nout = %d", nout);

        #20;
        $finish;
    end

endmodule