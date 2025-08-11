// top_tb.v
`timescale 1ns / 1ps

module top_tb;

    // Inputs
    reg clk;
    reg rstn;
    reg start;
    reg cima;
    reg inwidth;
    reg wwidth;
    reg [7:0] WA;
    reg [23:0] D;
    reg [191:0] xin0;

    // Outputs
    wire [50:0] nout;
    wire st;

    // Instantiate the Unit Under Test (UUT)
    top uut (
        .clk(clk), 
        .rstn(rstn), 
        .start(start), 
        .cima(cima), 
        .inwidth(inwidth), 
        .wwidth(wwidth), 
        .WA(WA), 
        .D(D), 
        .xin0(xin0), 
        .nout(nout), 
        .st(st)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to write data to the CIM array
    task write_data;
        input [7:0] address;
        input [23:0] data;
        begin
            @(posedge clk);
            WA = address;
            D = data;
            @(posedge clk); // Wait for the write to be captured
            //WA = 8'b0;      // De-assert address to prevent re-writing
        end
    endtask

    initial begin
        // Initialize Inputs
        clk = 0;
        rstn = 0;
        start = 0;
        cima = 0;
        inwidth = 0; // Assuming 1-bit for simplicity
        wwidth = 0;  // Assuming 1-bit for simplicity
        WA = 0;
        D = 0;
        xin0 = 0;

        // Dump waves
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        // Apply reset
        #10 rstn = 1;
        #10;

        // Write data using one-hot addresses
        $display("Start writing weights with one-hot addresses...");
        for (integer i = 0; i < 8; i = i + 1) begin
            write_data(1 << i, 24'd9 + i);
            #10;
        end
        $display("Finished writing weights.");
        
        #20;

        // Start computation
        $display("Starting computation...");
        @(posedge clk);
        //xin0 = 192'hA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5; // Example input
        xin0 = 192'haaa_aaa_aaa_aaa_aaa_aaa_aaa_aaa_aaa_aaa_aaa_aaa_aaa_aaa_aaa_aaa; // Example input
        start = 1;
        #10;
        @(posedge clk);
        start = 0;
        $display("Start signal asserted.");

        // Monitor outputs
        $monitor("Time=%0t nout=%h, st=%b", $time, nout, st);

        // Wait for computation to finish (indicated by 'st' signal)
        // This is a simple wait, a real scenario might need a more robust completion check.
        wait (st == 1);
        $display("Computation finished at Time=%0t", $time);
        
        #1000;

        // Finish simulation
        $display("Simulation finished.");
        $finish;
    end

endmodule