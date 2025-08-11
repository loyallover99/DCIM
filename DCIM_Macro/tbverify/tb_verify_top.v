// tbverify/tb_verify_top.v
`timescale 1ns / 1ps

module tb_verify_top;

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

    // --- Verification Signals ---
    integer golden_file;
    reg [50:0] golden_nout;
    reg golden_st;
    integer line_num = 0;
    integer errors = 0;

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

    // --- Test Sequence (Identical to original tb_top.v) ---
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

        // Open the golden data file
        golden_file = $fopen("./tbverify/golden_top.txt", "r");
        if (golden_file == 0) begin
            $display("ERROR: Could not open golden data file ./tbverify/golden_top.txt");
            $finish;
        end

        // 1. Apply Reset
        #20;
        rstn = 1;
        #10;

        // 2. Write Weights to Bank 0
        acm_en = 1;
        cima = 0;
        WA = 8'h01; D = 24'h000001; #10;
        WA = 8'h02; D = 24'h000002; #10;
        WA = 8'h04; D = 24'h000003; #10;
        WA = 8'h08; D = 24'h000004; #10;
        WA = 8'h10; D = 24'h000005; #10;
        WA = 8'h20; D = 24'h000006; #10;
        WA = 8'h40; D = 24'h000007; #10;
        WA = 8'h80; D = 24'h000008; #10;
        WA = 8'h00; D = 24'h00; #10;

        // 3. Start a single 12-bit computation
        inwidth = 0; wwidth = 0;
        xin0 = 192'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        #10;
        start = 1;
        #10;
        start = 0;

        // 4. Wait for completion (driven by simulation end)
        wait (st == 1);
        #20;

        // 5. Final check and finish
        #100;
        if (errors == 0) begin
            $display("*** PASSED: All checks matched the golden data. ***");
        end else begin
            $display("*** FAILED: %0d mismatches found. ***", errors);
        end
        $fclose(golden_file);
        $finish;
    end

    // --- Verification Logic ---
    always @(posedge clk) begin
        if (rstn) begin
            line_num = line_num + 1;
            // Read a line from the golden file
            if (!$feof(golden_file)) begin
                $fscanf(golden_file, "%h %b\n", golden_nout, golden_st); // Simplified $fscanf
                
                // Compare DUT output with golden data
                if (nout !== golden_nout || st !== golden_st) begin
                    $display("ERROR: Mismatch at line %0d (Time: %0t)", line_num, $time);
                    $display("  DUT   : nout=%h, st=%b", nout, st);
                    $display("  GOLDEN: nout=%h, st=%b", golden_nout, golden_st);
                    errors = errors + 1;
                end
            }
        }
    end

endmodule