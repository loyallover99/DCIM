`timescale 1ns / 1ps

module tb_s_cla;

    // Inputs
    reg [23:0] a;
    reg [23:0] b;
    reg cin;

    // Outputs
    wire [23:0] sum;
    wire cout; // Not an output of the module, but we can calculate expected cout

    // Instantiate the Unit Under Test (UUT)
    s_cla uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum)
    );

    // Verification logic
    wire [24:0] expected_sum = a + b + cin;
    assign cout = expected_sum[24];

    initial begin
        // Initialize Inputs
        a = 0;
        b = 0;
        cin = 0;

        $dumpfile("tb_s_cla.vcd");
        $dumpvars(0, tb_s_cla);

        // Test Case 1: Zero test
        $display("--- Test Case 1: Zero Test ---");
        a = 24'd0; b = 24'd0; cin = 0; #10;
        $display("a=%h, b=%h, cin=%b -> sum=%h (expected=%h)", a, b, cin, sum, expected_sum[23:0]);

        // Test Case 2: Basic addition
        $display("--- Test Case 2: Basic Addition ---");
        a = 24'd12345; b = 24'd54321; cin = 0; #10;
        $display("a=%d, b=%d, cin=%b -> sum=%d (expected=%d)", a, b, cin, sum, expected_sum[23:0]);
        a = 24'd10; b = 24'd20; cin = 1; #10;
        $display("a=%d, b=%d, cin=%b -> sum=%d (expected=%d)", a, b, cin, sum, expected_sum[23:0]);

        // Test Case 3: Max values and overflow
        $display("--- Test Case 3: Max values and overflow ---");
        a = 24'hFFFFFF; b = 24'h000000; cin = 0; #10;
        $display("a=%h, b=%h, cin=%b -> sum=%h (expected=%h)", a, b, cin, sum, expected_sum[23:0]);
        a = 24'hFFFFFF; b = 24'h000001; cin = 0; #10;
        $display("a=%h, b=%h, cin=%b -> sum=%h (expected=%h) -> COUT should be 1 (is %b)", a, b, cin, sum, expected_sum[23:0], cout);
        a = 24'hFFFFFF; b = 24'hFFFFFF; cin = 1; #10;
        $display("a=%h, b=%h, cin=%b -> sum=%h (expected=%h) -> COUT should be 1 (is %b)", a, b, cin, sum, expected_sum[23:0], cout);

        // Test Case 4: Random values
        $display("--- Test Case 4: Random values ---");
        repeat (5) begin
            a = {$random, $random} & 24'hFFFFFF;
            b = {$random, $random} & 24'hFFFFFF;
            cin = $random & 1;
            #10;
            $display("a=%h, b=%h, cin=%b -> sum=%h (expected=%h)", a, b, cin, sum, expected_sum[23:0]);
        end

        // Test Case 5: Signed-like addition (pos + neg)
        $display("--- Test Case 5: Signed-like addition ---");
        a = 24'd100; b = -24'sd50; cin = 0; #10; // 100 + (-50) = 50
        $display("a=%d, b=%d, cin=%b -> sum=%d (expected=%d)", $signed(a), $signed(b), cin, $signed(sum), $signed(expected_sum[23:0]));
        a = -24'sd100; b = 24'd50; cin = 0; #10; // -100 + 50 = -50
        $display("a=%d, b=%d, cin=%b -> sum=%d (expected=%d)", $signed(a), $signed(b), cin, $signed(sum), $signed(expected_sum[23:0]));
        a = -24'sd100; b = -24'sd50; cin = 0; #10; // -100 + -50 = -150
        $display("a=%d, b=%d, cin=%b -> sum=%d (expected=%d)", $signed(a), $signed(b), cin, $signed(sum), $signed(expected_sum[23:0]));

        #20;
        $finish;
    end

endmodule