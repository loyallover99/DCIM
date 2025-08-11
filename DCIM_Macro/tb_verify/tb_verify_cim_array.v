`timescale 1ns / 1ps

module tb_verify_cim_array;

    // Inputs
    reg [23:0] D;
    reg [7:0] WA0;
    reg [7:0] WA1;

    // Outputs
    wire [95:0] wb0_a;
    wire [95:0] wb0_b;
    wire [95:0] wb1_a;
    wire [95:0] wb1_b;

    // Instantiate the Unit Under Test (UUT)
    cim_array uut (
        .D(D),
        .WA0(WA0),
        .WA1(WA1),
        .wb0_a(wb0_a),
        .wb0_b(wb0_b),
        .wb1_a(wb1_a),
        .wb1_b(wb1_b)
    );

    integer i;
    integer errors = 0;

    // Verification task
    task check_output;
        input [95:0] expected_wb0_a, expected_wb0_b, expected_wb1_a, expected_wb1_b;
        begin
            #1; // Allow for combinational logic to settle
            if (wb0_a !== expected_wb0_a || wb0_b !== expected_wb0_b || wb1_a !== expected_wb1_a || wb1_b !== expected_wb1_b) begin
                $display("ERROR @ Time=%0t", $time);
                if (wb0_a !== expected_wb0_a) $display("  wb0_a = %h (expected %h)", wb0_a, expected_wb0_a);
                if (wb0_b !== expected_wb0_b) $display("  wb0_b = %h (expected %h)", wb0_b, expected_wb0_b);
                if (wb1_a !== expected_wb1_a) $display("  wb1_a = %h (expected %h)", wb1_a, expected_wb1_a);
                if (wb1_b !== expected_wb1_b) $display("  wb1_b = %h (expected %h)", wb1_b, expected_wb1_b);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Initialize Inputs
        D = 0;
        WA0 = 0;
        WA1 = 0;

        $dumpfile("tb_verify_cim_array.vcd");
        $dumpvars(0, tb_verify_cim_array);
        #1;

        // Test Case 1: Write to bank 0 and verify
        $display("--- Test Case 1: Write to bank 0 and verify ---");
        for (i = 0; i < 8; i = i + 1) begin
            WA0 = 1 << i;
            WA1 = 8'b0;
            D = {12'h100 + i, 12'hA00 + i};
            #10;
            case (i)
                0: check_output(96'hfffffffffffffffffffff5ff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff);
                1: check_output(96'hffffffffffffffffff5fe5ff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff);
                2: check_output(96'hfffffffffffffff5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff);
                3: check_output(96'hffffffffffff5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff);
                4: check_output(96'hfffffffff5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff);
                5: check_output(96'hffffff5fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff);
                6: check_output(96'hfff5f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff);
                7: check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff);
            endcase
        end
        WA0 = 8'b0;
        #10;
        check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffffffffff);

        // Test Case 2: Write to bank 1 and verify
        $display("--- Test Case 2: Write to bank 1 and verify ---");
        for (i = 0; i < 8; i = i + 1) begin
            WA0 = 8'b0;
            WA1 = 1 << i;
            D = {12'h200 + i, 12'hB00 + i};
            #10;
            case (i)
                0: check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hfffffffffffffffffffff4ff, 96'hffffffffffffffffffffffff);
                1: check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hffffffffffffffffff4fe4ff, 96'hffffffffffffffffffffffff);
                2: check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hfffffffffffffff4fd4fe4ff, 96'hffffffffffffffffffffffff);
                3: check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hffffffffffff4fc4fd4fe4ff, 96'hffffffffffffffffffffffff);
                4: check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hfffffffff4fb4fc4fd4fe4ff, 96'hffffffffffffffffffffffff);
                5: check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hffffff4fa4fb4fc4fd4fe4ff, 96'hffffffffffffffffffffffff);
                6: check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'hfff4f94fa4fb4fc4fd4fe4ff, 96'hffffffffffffffffffffffff);
                7: check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'h4f84f94fa4fb4fc4fd4fe4ff, 96'hffffffffffffffffffffffff);
            endcase
        end
        WA1 = 8'b0;
        #10;
        check_output(96'h5f85f95fa5fb5fc5fd5fe5ff, 96'hffffffffffffffffffffffff, 96'h4f84f94fa4fb4fc4fd4fe4ff, 96'hffffffffffffffffffffffff);

        // Test Case 3: Overwrite data in bank 0
        $display("--- Test Case 3: Overwrite data in bank 0 ---");
        WA0 = 1 << 3; // Address 3
        WA1 = 8'b0;
        D = 24'hDEADBE;
        #10;
        check_output(96'h5f85f95fa5fb2415fd5fe5ff, 96'hffffffffffff215fffffffff, 96'h4f84f94fa4fb4fc4fd4fe4ff, 96'hffffffffffffffffffffffff);
        WA0 = 8'b0;
        #10;
        check_output(96'h5f85f95fa5fb2415fd5fe5ff, 96'hffffffffffff215fffffffff, 96'h4f84f94fa4fb4fc4fd4fe4ff, 96'hffffffffffffffffffffffff);

        // Final result
        #20;
        if (errors == 0)
            $display("--- VERIFICATION PASSED ---");
        else
            $display("--- VERIFICATION FAILED: %0d errors ---", errors);

        $finish;
    end

endmodule
