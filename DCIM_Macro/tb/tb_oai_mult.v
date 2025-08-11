`timescale 1ns / 1ps

module tb_oai_mult;

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

    initial begin
        // Initialize Inputs
        a = 0;
        b = 0;
        c = 0;
        d = 0;

        $dumpfile("tb_oai_mult.vcd");
        $dumpvars(0, tb_oai_mult);

        // Test Case 1: c=0, d=0 => e = ~(a & b) (NAND)
        $display("--- Test Case 1: c=0, d=0 (NAND logic) ---");
        c = 0; d = 0;
        a = 12'hFFF; b = 12'hFFF; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected 000)", a, b, c, d, e);
        a = 12'hFFF; b = 12'h000; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected FFF)", a, b, c, d, e);
        a = 12'h000; b = 12'hFFF; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected FFF)", a, b, c, d, e);
        a = 12'h000; b = 12'h000; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected FFF)", a, b, c, d, e);
        a = 12'hF0F; b = 12'h0F0; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected FFF)", a, b, c, d, e);
        a = 12'hA5A; b = 12'h5A5; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected FFF)", a, b, c, d, e);

        // Test Case 2: c=0, d=1 => e = ~a (NOT a)
        $display("--- Test Case 2: c=0, d=1 (NOT a logic) ---");
        c = 0; d = 1;
        a = 12'hFFF; b = 12'hFFF; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected 000)", a, b, c, d, e);
        a = 12'h000; b = 12'hFFF; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected FFF)", a, b, c, d, e);
        a = 12'hF0F; b = 12'hFFF; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected 0F0)", a, b, c, d, e);
        a = 12'hA5A; b = 12'hFFF; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected 5A5)", a, b, c, d, e);

        // Test Case 3: c=1, d=0 => e = ~b (NOT b)
        $display("--- Test Case 3: c=1, d=0 (NOT b logic) ---");
        c = 1; d = 0;
        a = 12'hFFF; b = 12'hFFF; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected 000)", a, b, c, d, e);
        a = 12'hFFF; b = 12'h000; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected FFF)", a, b, c, d, e);
        a = 12'hFFF; b = 12'hF0F; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected 0F0)", a, b, c, d, e);
        a = 12'hFFF; b = 12'hA5A; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected 5A5)", a, b, c, d, e);

        // Test Case 4: c=1, d=1 => e = 0
        $display("--- Test Case 4: c=1, d=1 (Output is always 0) ---");
        c = 1; d = 1;
        a = 12'hFFF; b = 12'hFFF; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected 000)", a, b, c, d, e);
        a = 12'h000; b = 12'h000; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected 000)", a, b, c, d, e);
        a = 12'hA5A; b = 12'h5A5; #10; $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected 000)", a, b, c, d, e);

        // Test Case 5: Random values
        $display("--- Test Case 5: Random values ---");
        repeat(5) begin
            a = $random;
            b = $random;
            c = $random;
            d = $random;
            #10;
            $display("a=%h, b=%h, c=%b, d=%b => e=%h (expected %h)", a, b, c, d, e, ~((a|c)&(b|d)));
        end

        #20;
        $finish;
    end

endmodule