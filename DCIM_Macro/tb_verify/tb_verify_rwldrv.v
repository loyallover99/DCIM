`timescale 1ns / 1ps

module tb_verify_rwldrv;

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
    integer errors = 0;

    // Verification task
    task check_output;
        input [7:0] expected_row0;
        input [7:0] expected_row1;
        begin
            #1; // Settle time
            if (rwlb_row0 !== expected_row0 || rwlb_row1 !== expected_row1) begin
                $display("ERROR @ Time=%0t: sel=%d, cima=%b, inwidth=%b", $time, sel, cima, inwidth);
                $display("  rwlb_row0 = %h (expected %h)", rwlb_row0, expected_row0);
                $display("  rwlb_row1 = %h (expected %h)", rwlb_row1, expected_row1);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Initialize Inputs
        xin0 = 0;
        sel = 0;
        cima = 0;
        inwidth = 0;

        // Setup xin0 with the same pattern as the original tb
        for (i=0; i<8; i=i+1) begin
            xin0[i*24 +: 24] = 24'hAAAAAA + i;
        end
        #10;

        $dumpfile("tb_verify_rwldrv.vcd");
        $dumpvars(0, tb_verify_rwldrv);

        $display("--- Verification for rwldrv starting ---");

        // Test Case 1: 12-bit mode, bank 0
        $display("// Test Case 1: 12-bit mode, bank 0");
        inwidth = 0;
        cima = 0;
        for (sel = 0; sel < 12; sel = sel + 1) begin
            #10;
            case (sel)
                0: check_output(8'h00, 8'hff);
                1: check_output(8'hff, 8'hff);
                2: check_output(8'h00, 8'hff);
                3: check_output(8'hff, 8'hff);
                4: check_output(8'h00, 8'hff);
                5: check_output(8'hff, 8'hff);
                6: check_output(8'h00, 8'hff);
                7: check_output(8'h3f, 8'hff);
                8: check_output(8'hc0, 8'hff);
                9: check_output(8'hc3, 8'hff);
                10: check_output(8'hcc, 8'hff);
                11: check_output(8'h55, 8'hff);
            endcase
        end

        // Test Case 2: 12-bit mode, bank 1
        $display("// Test Case 2: 12-bit mode, bank 1");
        inwidth = 0;
        cima = 1;
        for (sel = 0; sel < 12; sel = sel + 1) begin
            #10;
            case (sel)
                0: check_output(8'hff, 8'h00);
                1: check_output(8'hff, 8'hff);
                2: check_output(8'hff, 8'h00);
                3: check_output(8'hff, 8'hff);
                4: check_output(8'hff, 8'h00);
                5: check_output(8'hff, 8'hff);
                6: check_output(8'hff, 8'h00);
                7: check_output(8'hff, 8'h3f);
                8: check_output(8'hff, 8'hc0);
                9: check_output(8'hff, 8'hc3);
                10: check_output(8'hff, 8'hcc);
                11: check_output(8'hff, 8'h55);
            endcase
        end

        // Test Case 3: 24-bit mode, bank 0
        $display("// Test Case 3: 24-bit mode, bank 0");
        inwidth = 1;
        cima = 0;
        for (sel = 0; sel < 24; sel = sel + 1) begin
            #10;
            case (sel)
                0: check_output(8'h00, 8'hff);
                1: check_output(8'hff, 8'hff);
                2: check_output(8'h00, 8'hff);
                3: check_output(8'hff, 8'hff);
                4: check_output(8'h00, 8'hff);
                5: check_output(8'hff, 8'hff);
                6: check_output(8'h00, 8'hff);
                7: check_output(8'hff, 8'hff);
                8: check_output(8'h00, 8'hff);
                9: check_output(8'hff, 8'hff);
                10: check_output(8'h00, 8'hff);
                11: check_output(8'hff, 8'hff);
                12: check_output(8'h00, 8'hff);
                13: check_output(8'hff, 8'hff);
                14: check_output(8'h00, 8'hff);
                15: check_output(8'hff, 8'hff);
                16: check_output(8'h00, 8'hff);
                17: check_output(8'hff, 8'hff);
                18: check_output(8'h00, 8'hff);
                19: check_output(8'h3f, 8'hff);
                20: check_output(8'hc0, 8'hff);
                21: check_output(8'hc3, 8'hff);
                22: check_output(8'hcc, 8'hff);
                23: check_output(8'h55, 8'hff);
            endcase
        end

        // Test Case 4: 24-bit mode, bank 1
        $display("// Test Case 4: 24-bit mode, bank 1");
        inwidth = 1;
        cima = 1;
        for (sel = 0; sel < 24; sel = sel + 1) begin
            #10;
            case (sel)
                0: check_output(8'hff, 8'h00);
                1: check_output(8'hff, 8'hff);
                2: check_output(8'hff, 8'h00);
                3: check_output(8'hff, 8'hff);
                4: check_output(8'hff, 8'h00);
                5: check_output(8'hff, 8'hff);
                6: check_output(8'hff, 8'h00);
                7: check_output(8'hff, 8'hff);
                8: check_output(8'hff, 8'h00);
                9: check_output(8'hff, 8'hff);
                10: check_output(8'hff, 8'h00);
                11: check_output(8'hff, 8'hff);
                12: check_output(8'hff, 8'h00);
                13: check_output(8'hff, 8'hff);
                14: check_output(8'hff, 8'h00);
                15: check_output(8'hff, 8'hff);
                16: check_output(8'hff, 8'h00);
                17: check_output(8'hff, 8'hff);
                18: check_output(8'hff, 8'h00);
                19: check_output(8'hff, 8'h3f);
                20: check_output(8'hff, 8'hc0);
                21: check_output(8'hff, 8'hc3);
                22: check_output(8'hff, 8'hcc);
                23: check_output(8'hff, 8'h55);
            endcase
        end

        #20;
        if (errors == 0) begin
            $display("--- All rwldrv checks PASSED ---");
        end else begin
            $display("--- rwldrv verification FAILED with %0d errors ---", errors);
        end
        $finish;
    end

endmodule
