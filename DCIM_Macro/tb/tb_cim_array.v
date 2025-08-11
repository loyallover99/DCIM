`timescale 1ns / 1ps

module tb_cim_array;

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
    
    initial begin
        // Initialize Inputs
        D = 0;
        WA0 = 0;
        WA1 = 0;
        
        #1; // Allow initial values to settle

        $display("// --- Generated Verification Code ---");

        // Test Case 1: Write to bank 0 and verify
        $display("// Test Case 1: Write to bank 0 and verify");
        for (i = 0; i < 8; i = i + 1) begin
            WA0 = 1 << i;
            WA1 = 8'b0;
            D = {12'h100 + i, 12'hA00 + i};
            #10;
            $display("check_output(96'h%h, 96'h%h, 96'h%h, 96'h%h);", wb0_a, wb0_b, wb1_a, wb1_b);
        end
        WA0 = 8'b0;
        #10;
        $display("check_output(96'h%h, 96'h%h, 96'h%h, 96'h%h);", wb0_a, wb0_b, wb1_a, wb1_b);

        // Test Case 2: Write to bank 1 and verify
        $display("// Test Case 2: Write to bank 1 and verify");
        for (i = 0; i < 8; i = i + 1) begin
            WA0 = 8'b0;
            WA1 = 1 << i;
            D = {12'h200 + i, 12'hB00 + i};
            #10;
            $display("check_output(96'h%h, 96'h%h, 96'h%h, 96'h%h);", wb0_a, wb0_b, wb1_a, wb1_b);
        end
        WA1 = 8'b0;
        #10;
        $display("check_output(96'h%h, 96'h%h, 96'h%h, 96'h%h);", wb0_a, wb0_b, wb1_a, wb1_b);

        // Test Case 3: Overwrite data in bank 0
        $display("// Test Case 3: Overwrite data in bank 0");
        WA0 = 1 << 3; // Address 3
        WA1 = 8'b0;
        D = 24'hDEADBE;
        #10;
        $display("check_output(96'h%h, 96'h%h, 96'h%h, 96'h%h);", wb0_a, wb0_b, wb1_a, wb1_b);
        WA0 = 8'b0;
        #10;
        $display("check_output(96'h%h, 96'h%h, 96'h%h, 96'h%h);", wb0_a, wb0_b, wb1_a, wb1_b);

        #20;
        $finish;
    end

endmodule
