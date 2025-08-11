`timescale 1ns / 1ps

module tb_verify_cim_bank;

    // Inputs
    reg [23:0] D;
    reg [7:0] WA;

    // Outputs
    wire [95:0] wb_a;
    wire [95:0] wb_b;

    // Instantiate the Unit Under Test (UUT)
    cim_bank uut (
        .D(D),
        .WA(WA),
        .wb_a(wb_a),
        .wb_b(wb_b)
    );

    integer i;
    integer errors = 0;

    // Verification task
    task check_output;
        input [95:0] expected_wb_a;
        input [95:0] expected_wb_b;
        begin
            #1; // Allow for combinational logic to settle
            if (wb_a !== expected_wb_a || wb_b !== expected_wb_b) begin
                $display("ERROR @ Time=%0t: WA=%h", $time, WA);
                $display("  wb_a = %h (expected %h)", wb_a, expected_wb_a);
                $display("  wb_b = %h (expected %h)", wb_b, expected_wb_b);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Initialize Inputs
        D = 0;
        WA = 0;

        $dumpfile("tb_verify_cim_bank.vcd");
        $dumpvars(0, tb_verify_cim_bank);
        #1;

        // --- Test Case 1: Write to all memory locations ---
        $display("--- Test Case 1: Write to all memory locations ---");
        for (i = 0; i < 8; i = i + 1) begin
            WA = 1 << i;
            D = {12'h100 + i, 12'hA00 + i};
            #10;
            case (i)
                0: check_output(96'hfffffffffffffffffffff5ff, 96'hffffffffffffffffffffffff);
                1: check_output(96'hffffffffffffffffff5fe5ff, 96'hffffffffffffffffffffffff);
                2: check_output(96'hfffffffffffffff5fd5fe5ff, 96'hffffffffffffffffffffffff);
                3: check_output(96'hffffffffffff5fc5fd5fe5ff, 96'hffffffffffffffffffffffff);
                4: check_output(96'hfffffffff5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff);
                5: check_output(96'hffffff5fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff);
                6: check_output(96'hfff5f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff);
                7: check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff);
            endcase
        end
        WA = 8'b0;
        #10;
        check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff);

        // --- Test Case 2: Overwrite location 4 ---
        $display("--- Test Case 2: Overwrite location 4 ---");
        WA = 1 << 4;
        D = 24'hDEADBE;
        #10;
        check_output(96'h5f85f95fa2415fc5fd5fe5ff, 96'hfffffffff215ffffffffffff);
        WA = 8'b0;
        #10;
        check_output(96'h5f85f95fa2415fc5fd5fe5ff, 96'hfffffffff215ffffffffffff);

        // --- Test Case 3: Write with WA=0 (should be no-op) ---
        $display("--- Test Case 3: Write with WA=0 (should be no-op) ---");
        WA = 8'b0;
        D = 24'hFFFFFF;
        #10;
        check_output(96'h5f85f95fa2415fc5fd5fe5ff, 96'hfffffffff215ffffffffffff);

        // Final result
        #20;
        if (errors == 0)
            $display("--- VERIFICATION PASSED ---");
        else
            $display("--- VERIFICATION FAILED: %0d errors ---", errors);

        $finish;
    end

endmodule