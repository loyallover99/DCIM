`timescale 1ns / 1ps

module tb_top_full;

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

    // --- Task for writing weights ---
    integer i; // Moved declaration outside of the task
    task write_weights;
        input [0:0] bank_select;
        begin
            $display("Writing weights to Bank %d...", bank_select);
            cima = bank_select;
            for (i = 0; i < 8; i = i + 1) begin
                WA = 1 << i;
                D = 24'h000001 * (i+1) + bank_select * 24'h101010; // Different data for each bank
                #10;
            end
            WA = 8'h00;
            D = 24'h00;
            #10;
            $display("Finished writing weights to Bank %d.", bank_select);
        end
    endtask

    // --- Task for running computation ---
    task run_computation;
        input [0:0] in_w;
        input [0:0] w_w;
        input [0:0] bank_select;
        input [191:0] x_in;
        begin
            $display("Starting computation: inwidth=%b, wwidth=%b, cima=%b", in_w, w_w, bank_select);
            inwidth = in_w;
            wwidth = w_w;
            cima = bank_select;
            xin0 = x_in;
            acm_en = 1;

            #10;
            start = 1;
            @(posedge clk);
            start = 0;

            $monitor("Time: %0t, st: %b, sel: %d, nout: %h", $time, dut.st, dut.gctrl_inst.sel, nout);

            wait (dut.st == 1);
            #20;
            $monitoroff;
            $display("Computation finished. Final nout: %h", nout);
            acm_en = 0;
        end
    endtask


    // --- Test Sequence ---
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
        $dumpfile("tb_top_full.vcd");
        $dumpvars(0, tb_top_full);

        // 1. Apply Reset
        #20;
        rstn = 1;
        #10;
        $display("Reset released. Starting test sequence.");

        // 2. Write weights to both banks
        write_weights(0); // Write to bank 0
        write_weights(1); // Write to bank 1

        // 3. Run computations
        // Test 1: 12-bit in, 12-bit w, bank 0
        run_computation(0, 0, 0, 192'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

        // Test 2: 12-bit in, 12-bit w, bank 1
        run_computation(0, 0, 1, 192'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA);

        // Test 3: 24-bit in, 12-bit w, bank 0
        run_computation(1, 0, 0, 192'h555555555555555555555555555555555555555555555555);

        // Test 4: 24-bit in, 24-bit w, bank 1
        run_computation(1, 1, 1, 192'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0);

        // 5. Finish simulation
        #100;
        $display("Simulation finished.");
        $finish;
    end

endmodule
