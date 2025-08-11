`timescale 1ns / 1ps

module tb_cim_bank;

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

    initial begin
        // This testbench now prints the verification logic for the other testbench.
        D = 0;
        WA = 0;
        #1;

        $display("// --- Generated Verification Code ---");
        $display("// Test Case 1: Write to all memory locations");
        for (i = 0; i < 8; i = i + 1) begin
            WA = 1 << i;
            D = {12'h100 + i, 12'hA00 + i};
            #10;
            $display("check_output(96'h%h, 96'h%h);", wb_a, wb_b);
        end
        WA = 8'b0;
        #10;
        $display("check_output(96'h%h, 96'h%h);", wb_a, wb_b);

        $display("// Test Case 2: Overwrite location 4");
        WA = 1 << 4;
        D = 24'hDEADBE;
        #10;
        $display("check_output(96'h%h, 96'h%h);", wb_a, wb_b);
        WA = 8'b0;
        #10;
        $display("check_output(96'h%h, 96'h%h);", wb_a, wb_b);

        $display("// Test Case 3: Write with WA=0 (should be no-op)");
        WA = 8'b0;
        D = 24'hFFFFFF;
        #10;
        $display("check_output(96'h%h, 96'h%h);", wb_a, wb_b);

        #20;
        $finish;
    end

endmodule