`timescale 1ns / 1ps

module tb_verify_s_cla;

    // Inputs
    reg [23:0] a;
    reg [23:0] b;
    reg cin;

    // Outputs
    wire [23:0] sum;

    // Instantiate the Unit Under Test (UUT)
    s_cla uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum)
    );

    integer errors = 0;

    // Verification task
    task check_output;
        input [23:0] expected_sum;
        begin
            #10;
            if (sum !== expected_sum) begin
                $display("ERROR: a=%h, b=%h, cin=%b -> sum=%h (expected %h)", a, b, cin, sum, expected_sum);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Initialize Inputs
        a = 0;
        b = 0;
        cin = 0;

        $dumpfile("tb_verify_s_cla.vcd");
        $dumpvars(0, tb_verify_s_cla);

        // Test Case 1: Zero test
        $display("--- Verification Case 1: Zero Test ---");
        a = 24'd0; b = 24'd0; cin = 0; check_output(24'd0);

        // Test Case 2: Basic addition
        $display("--- Verification Case 2: Basic Addition ---");
        a = 24'd12345; b = 24'd54321; cin = 0; check_output(24'd66666);
        a = 24'd10; b = 24'd20; cin = 1; check_output(24'd31);

        // Test Case 3: Max values and overflow
        $display("--- Verification Case 3: Max values and overflow ---");
        a = 24'hFFFFFF; b = 24'h000000; cin = 0; check_output(24'hFFFFFF);
        a = 24'hFFFFFF; b = 24'h000001; cin = 0; check_output(24'h000000);
        a = 24'hFFFFFF; b = 24'hFFFFFF; cin = 1; check_output(24'hFFFFFF);

        // Test Case 5: Signed-like addition (pos + neg)
        $display("--- Verification Case 5: Signed-like addition ---");
        a = 24'd100; b = -24'sd50; cin = 0; check_output(24'd50);
        a = -24'sd100; b = 24'd50; cin = 0; check_output(-24'sd50);
        a = -24'sd100; b = -24'sd50; cin = 0; check_output(-24'sd150);

        // Final result
        #20;
        if (errors == 0)
            $display("--- VERIFICATION PASSED ---");
        else
            $display("--- VERIFICATION FAILED: %0d errors ---", errors);

        $finish;
    end

endmodule