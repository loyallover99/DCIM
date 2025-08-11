`timescale 1ns / 1ps

module top_tb;

    // --- DUT Signals ---
    reg [23:0] D;
    reg clk;
    reg rstn;
    reg cima;
    reg acm_en;
    reg [7:0] WA;
    reg inwidth;
    reg wwidth;
    reg start;
    reg [191:0] xin0;
    wire [50:0] nout;
    wire st;

    // --- Instantiate DUT ---
    top dut (
        .D(D), .clk(clk), .rstn(rstn), .cima(cima), .acm_en(acm_en),
        .WA(WA), .inwidth(inwidth), .wwidth(wwidth), .start(start),
        .xin0(xin0), .nout(nout), .st(st)
    );

    // --- Clock Generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- Test Sequence (Simple & Robust) ---
    initial begin
        // Initialize all signals
        rstn = 0;
        cima = 0;
        acm_en = 0;
        WA = 8'b0;
        inwidth = 0;
        wwidth = 0;
        start = 0;
        D = 24'b0;
        xin0 = 192'b0;

        // Waveform dumping
        $dumpfile("tb_top.vcd");
        $dumpvars(0, top_tb);

        // 1. Apply Reset
        #20;
        rstn = 1;
        #10;
        $display("Reset released. Starting test sequence.");

        // 2. Write Weights to Bank 0
        acm_en = 1;
        cima = 0;
        $display("Writing weights to Bank 0...");
        WA = 8'h01; D = 24'h000001; #10;
        WA = 8'h02; D = 24'h000002; #10;
        WA = 8'h04; D = 24'h000003; #10;
        WA = 8'h08; D = 24'h000004; #10;
        WA = 8'h10; D = 24'h000005; #10;
        WA = 8'h20; D = 24'h000006; #10;
        WA = 8'h40; D = 24'h000007; #10;
        WA = 8'h80; D = 24'h000008; #10;
        WA = 8'h00; D = 24'h00; #10;
        $display("Finished writing weights.");

        // 3. Start a single 12-bit computation
        inwidth = 0; // 12-bit mode
        wwidth = 0;  // 12-bit mode
        xin0 = 192'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        #10;
        start = 1;
        #10;
        start = 0;
        $display("Computation started.");

        // 4. Monitor and wait for completion
        wait (st == 1);
        #20;
        $display("Computation finished (st is high).");

        // 5. Finish simulation
        #100;
        $display("Simulation finished.");
        $finish;
    end

    // --- Golden Data Generation (to stdout) ---
    initial begin
        // Wait for reset to be released before monitoring
        wait (rstn == 1);
        #1; // Ensure we are past the reset edge
        forever @(posedge clk) begin
            $display("%h %b", nout, st);
        end
    end

endmodule