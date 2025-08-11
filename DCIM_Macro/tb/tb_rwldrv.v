`timescale 1ns / 1ps

module tb_rwldrv;

    // Inputs
    reg [191:0] xin0;
    reg [5:0] sel;
    reg cima;
    reg inwidth;

    // Outputs
    wire [7:0] rwlb_row0;
    wire [7:0] rwlb_row1;

    // Instantiate the Unit Under Test (UUT)
    rwldrv uut (
        .xin0(xin0),
        .sel(sel),
        .cima(cima),
        .inwidth(inwidth),
        .rwlb_row0(rwlb_row0),
        .rwlb_row1(rwlb_row1)
    );

    integer i;
    reg [7:0] selected_bits_calc;
    reg [5:0] bit_to_select_calc;

    initial begin
        // Initialize Inputs
        xin0 = 0;
        sel = 0;
        cima = 0;
        inwidth = 0;

        // Setup xin0 with a pattern
        // Each 24-bit word will be i, so we can easily check the bits.
        for (i=0; i<8; i=i+1) begin
            xin0[i*24 +: 24] = 24'hAAAAAA + i;
        end
        #10;

        $display("// --- Generated Verification Code ---");

        // Test Case 1: 12-bit mode (inwidth=0), bank 0 (cima=0)
        $display("// Test Case 1: 12-bit mode, bank 0");
        inwidth = 0;
        cima = 0;
        for (sel = 0; sel < 12; sel = sel + 1) begin
            #10;
            bit_to_select_calc = 11 - sel;
            for (i=0; i<8; i=i+1) selected_bits_calc[i] = xin0[(i*24) + bit_to_select_calc];
            $display("check_output(8'h%h, 8'h%h);", ~selected_bits_calc, 8'hFF);
        end

        // Test Case 2: 12-bit mode (inwidth=0), bank 1 (cima=1)
        $display("// Test Case 2: 12-bit mode, bank 1");
        inwidth = 0;
        cima = 1;
        for (sel = 0; sel < 12; sel = sel + 1) begin
            #10;
            bit_to_select_calc = 11 - sel;
            for (i=0; i<8; i=i+1) selected_bits_calc[i] = xin0[(i*24) + bit_to_select_calc];
            $display("check_output(8'h%h, 8'h%h);", 8'hFF, ~selected_bits_calc);
        end

        // Test Case 3: 24-bit mode (inwidth=1), bank 0 (cima=0)
        $display("// Test Case 3: 24-bit mode, bank 0");
        inwidth = 1;
        cima = 0;
        for (sel = 0; sel < 24; sel = sel + 1) begin
            #10;
            bit_to_select_calc = 23 - sel;
            for (i=0; i<8; i=i+1) selected_bits_calc[i] = xin0[(i*24) + bit_to_select_calc];
            $display("check_output(8'h%h, 8'h%h);", ~selected_bits_calc, 8'hFF);
        end

        // Test Case 4: 24-bit mode (inwidth=1), bank 1 (cima=1)
        $display("// Test Case 4: 24-bit mode, bank 1");
        inwidth = 1;
        cima = 1;
        for (sel = 0; sel < 24; sel = sel + 1) begin
            #10;
            bit_to_select_calc = 23 - sel;
            for (i=0; i<8; i=i+1) selected_bits_calc[i] = xin0[(i*24) + bit_to_select_calc];
            $display("check_output(8'h%h, 8'h%h);", 8'hFF, ~selected_bits_calc);
        end

        #20;
        $finish;
    end

endmodule