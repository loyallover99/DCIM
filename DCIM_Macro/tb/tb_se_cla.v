`timescale 1ns / 1ps

module tb_se_cla;

    // Inputs
    reg signed [26:0] a;
    reg signed [50:0] b;

    // Outputs
    wire signed [50:0] sum;

    // Instantiate the Unit Under Test (UUT)
    se_cla uut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    // Verification logic
    wire signed [51:0] expected_sum = a + b;


    initial begin
        // Initialize Inputs
        a = 0;
        b = 0;

        $dumpfile("tb_se_cla.vcd");
        $dumpvars(0, tb_se_cla);

        // Test Case 1: Zero test
        $display("--- Test Case 1: Zero Test ---");
        a = 27'sd0; b = 51'sd0; #10;
        $display("a=%d, b=%d -> sum=%d (expected=%d)", a, b, sum, expected_sum);

        // Test Case 2: Positive 'a', Positive 'b'
        $display("--- Test Case 2: Positive 'a', Positive 'b' ---");
        a = 27'sd12345; b = 51'sd5432109876; #10;
        $display("a=%d, b=%d -> sum=%d (expected=%d)", a, b, sum, expected_sum);

        // Test Case 3: Negative 'a', Positive 'b'
        $display("--- Test Case 3: Negative 'a', Positive 'b' ---");
        a = -27'sd12345; b = 51'sd5432109876; #10;
        $display("a=%d, b=%d -> sum=%d (expected=%d)", a, b, sum, expected_sum);
        a = -27'sd1; b = 51'sd1; #10;
        $display("a=%d, b=%d -> sum=%d (expected=%d)", a, b, sum, expected_sum);

        // Test Case 4: Large values
        $display("--- Test Case 4: Large values ---");
        a = 27'h7FFFFFF; b = 51'h7FFFFFFFFFFFF; #10; // Max pos a, large pos b
        $display("a=%h, b=%h -> sum=%h (expected=%h)", a, b, sum, expected_sum);
        a = -27'h8000000; b = 51'd0; #10; // Min neg a
        $display("a=%h, b=%h -> sum=%h (expected=%h)", a, b, sum, expected_sum);
        a = -27'h8000000; b = 51'h7FFFFFFFFFFFF; #10; // Min neg a, large pos b
        $display("a=%h, b=%h -> sum=%h (expected=%h)", a, b, sum, expected_sum);

        // Test Case 5: Random values
        $display("--- Test Case 5: Random values ---");
        repeat (5) begin
            a = {$random, $random};
            b = {$random, $random, $random};
            #10;
            $display("a=%d, b=%d -> sum=%d (expected=%d)", a, b, sum, expected_sum);
        end

        // Test Case 6: Negative 'b'
        $display("--- Test Case 6: Negative 'b' ---");
        a = 27'sd1000; b = -51'sd500; #10;
        $display("a=%d, b=%d -> sum=%d (expected=%d)", a, b, sum, expected_sum);
        a = -27'sd1000; b = -51'sd500; #10;
        $display("a=%d, b=%d -> sum=%d (expected=%d)", a, b, sum, expected_sum);
        a = 27'sd123; b = -51'sd456789; #10;
        $display("a=%d, b=%d -> sum=%d (expected=%d)", a, b, sum, expected_sum);

        #20;
        $finish;
    end

endmodule