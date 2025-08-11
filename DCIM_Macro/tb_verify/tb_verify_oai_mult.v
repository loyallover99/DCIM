`timescale 1ns / 1ps

module tb_verify_oai_mult;

    // Inputs
    reg [11:0] a;
    reg [11:0] b;
    reg c;
    reg d;

    // Outputs
    wire [11:0] e;

    // Instantiate the Unit Under Test (UUT)
    oai_mult uut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e)
    );

    integer errors = 0;

    // Verification task
    task check_output;
        input [11:0] expected_e;
        begin
            #10;
            if (e !== expected_e) begin
                $display("ERROR: a=%h, b=%h, c=%b, d=%b -> e=%h (expected %h)", a, b, c, d, e, expected_e);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Initialize Inputs
        a = 0;
        b = 0;
        c = 0;
        d = 0;

        $dumpfile("tb_verify_oai_mult.vcd");
        $dumpvars(0, tb_verify_oai_mult);

        // Test Case 1: c=0, d=0 => e = ~(a & b) (NAND)
        $display("--- Verification Case 1: c=0, d=0 (NAND logic) ---");
        c = 0; d = 0;
        a = 12'hFFF; b = 12'hFFF; check_output(12'h000);
        a = 12'hFFF; b = 12'h000; check_output(12'hFFF);
        a = 12'h000; b = 12'hFFF; check_output(12'hFFF);
        a = 12'h000; b = 12'h000; check_output(12'hFFF);
        a = 12'hF0F; b = 12'h0F0; check_output(12'hFFF);
        a = 12'hA5A; b = 12'h5A5; check_output(12'hFFF);

        // Test Case 2: c=0, d=1 => e = ~a (NOT a)
        $display("--- Verification Case 2: c=0, d=1 (NOT a logic) ---");
        c = 0; d = 1;
        a = 12'hFFF; b = 12'hFFF; check_output(12'h000);
        a = 12'h000; b = 12'hFFF; check_output(12'hFFF);
        a = 12'hF0F; b = 12'hFFF; check_output(12'h0F0);
        a = 12'hA5A; b = 12'hFFF; check_output(12'h5A5);

        // Test Case 3: c=1, d=0 => e = ~b (NOT b)
        $display("--- Verification Case 3: c=1, d=0 (NOT b logic) ---");
        c = 1; d = 0;
        a = 12'hFFF; b = 12'hFFF; check_output(12'h000);
        a = 12'hFFF; b = 12'h000; check_output(12'hFFF);
        a = 12'hFFF; b = 12'hF0F; check_output(12'h0F0);
        a = 12'hFFF; b = 12'hA5A; check_output(12'h5A5);

        // Test Case 4: c=1, d=1 => e = 0
        $display("--- Verification Case 4: c=1, d=1 (Output is always 0) ---");
        c = 1; d = 1;
        a = 12'hFFF; b = 12'hFFF; check_output(12'h000);
        a = 12'h000; b = 12'h000; check_output(12'h000);
        a = 12'hA5A; b = 12'h5A5; check_output(12'h000);

        // Final result
        #20;
        if (errors == 0)
            $display("--- VERIFICATION PASSED ---");
        else
            $display("--- VERIFICATION FAILED: %0d errors ---", errors);

        $finish;
    end

endmodule