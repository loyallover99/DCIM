`timescale 1ns / 1ps

module tb_add;

    // Parameters
    localparam width = 12;

    // Inputs
    reg [width-1:0] a;
    reg [width-1:0] b;
    reg sus;

    // Outputs
    wire [width:0] sum;

    // Instantiate the Unit Under Test (UUT)
    add #(.width(width)) uut (
        .a(a),
        .b(b),
        .sus(sus),
        .sum(sum)
    );

    integer unsigned_errors = 0;
    integer signed_errors = 0;

    initial begin
        // Initialize Inputs
        a = 0;
        b = 0;
        sus = 0;

        $dumpfile("tb_add.vcd");
        $dumpvars(0, tb_add);

        // --- Test Case 1: Unsigned Addition (sus = 0) ---
        $display("\n--- Test Case 1: Unsigned Addition (sus = 0) ---");
        sus = 0;
        
        // Basic addition
        a = 12'd10; b = 12'd20; #10; 
        $display("Unsigned: %d + %d = %d", a, b, sum);
        if (sum !== 13'd30) begin
            unsigned_errors++;
            $display("  ERROR: Expected 30");
        end
        
        // Overflow case
        a = 12'd4095; b = 12'd1; #10; 
        $display("Unsigned: %d + %d = %d (overflow)", a, b, sum);
        if (sum !== 13'd4096) begin
            unsigned_errors++;
            $display("  ERROR: Expected 4096");
        end
        
        // Max values
        a = 12'hFFF; b = 12'hFFF; #10; 
        $display("Unsigned: %h + %h = %h (max values)", a, b, sum);
        if (sum !== 13'h1FFE) begin
            unsigned_errors++;
            $display("  ERROR: Expected 1FFE");
        end
        
        // Zero values
        a = 12'h000; b = 12'h000; #10; 
        $display("Unsigned: %h + %h = %h (zero values)", a, b, sum);
        if (sum !== 13'd0) begin
            unsigned_errors++;
            $display("  ERROR: Expected 0");
        end

        // --- Test Case 2: Signed Addition (sus = 1) ---
        $display("\n--- Test Case 2: Signed Addition (sus = 1) ---");
        sus = 1;
        
        // Positive + Positive
        a = 12'sd10; b = 12'sd20; #10; 
        $display("Signed: %d + %d = %d", $signed(a), $signed(b), $signed(sum));
        if ($signed(sum) !== 13'sd30) begin
            signed_errors++;
            $display("  ERROR: Expected 30");
        end
        
        // Negative + Positive
        a = -12'sd10; b = 12'sd20; #10; 
        $display("Signed: %d + %d = %d", $signed(a), $signed(b), $signed(sum));
        if ($signed(sum) !== 13'sd10) begin
            signed_errors++;
            $display("  ERROR: Expected 10");
        end
        
        // Positive + Negative
        a = 12'sd10; b = -12'sd20; #10; 
        $display("Signed: %d + %d = %d", $signed(a), $signed(b), $signed(sum));
        if ($signed(sum) !== -13'sd10) begin
            signed_errors++;
            $display("  ERROR: Expected -10");
        end
        
        // Negative + Negative
        a = -12'sd10; b = -12'sd20; #10; 
        $display("Signed: %d + %d = %d", $signed(a), $signed(b), $signed(sum));
        if ($signed(sum) !== -13'sd30) begin
            signed_errors++;
            $display("  ERROR: Expected -30");
        end
        
        // Positive Overflow
        a = 12'sd2047; b = 12'sd1; #10; 
        $display("Signed: %d + %d = %d (pos overflow)", $signed(a), $signed(b), $signed(sum));
        if ($signed(sum) !== 13'sd2048) begin
            signed_errors++;
            $display("  ERROR: Expected 2048");
        end
        
        // Negative Overflow
        a = -12'sd2048; b = -12'sd1; #10; 
        $display("Signed: %d + %d = %d (neg overflow)", $signed(a), $signed(b), $signed(sum));
        if ($signed(sum) !== -13'sd2049) begin
            signed_errors++;
            $display("  ERROR: Expected -2049");
        end
        
        // Max positive values
        a = 12'h7FF; b = 12'h7FF; #10; 
        $display("Signed: %h + %h = %h (max pos)", a, b, sum);
        if ($signed(sum) !== 13'sh0FFE) begin
            signed_errors++;
            $display("  ERROR: Expected 0FFE");
        end
        
        // Max negative values
        a = 12'h800; b = 12'h800; #10; 
        $display("Signed: %h + %h = %h (max neg)", a, b, sum);
        if ($signed(sum) !== 13'sh1000) begin
            signed_errors++;
            $display("  ERROR: Expected 1000");
        end

        // --- Test Case 3: Random Unsigned Addition ---
        $display("\n--- Test Case 3: Random Unsigned Addition ---");
        sus = 0;
        repeat(5) begin
            a = $random;
            b = $random;
            #10;
            $display("Random Unsigned: %d + %d = %d (expected %d)", 
                     a, b, sum, a + b);
            if (sum !== (a + b)) begin
                unsigned_errors++;
                $display("  ERROR: Mismatch detected");
            end
        end

        // --- Test Case 4: Random Signed Addition ---
        $display("\n--- Test Case 4: Random Signed Addition ---");
        sus = 1;
        repeat(5) begin
            a = $random;
            b = $random;
            #10;
            $display("Random Signed: %d + %d = %d (expected %d)", 
                     $signed(a), $signed(b), $signed(sum), 
                     $signed(a) + $signed(b));
            if ($signed(sum) !== ($signed(a) + $signed(b))) begin
                signed_errors++;
                $display("  ERROR: Mismatch detected");
            end
        end

        // Final results
        #20;
        $display("\n--- Test Summary ---");
        $display("Unsigned tests: %0d errors", unsigned_errors);
        $display("Signed tests: %0d errors", signed_errors);
        
        if ((unsigned_errors == 0) && (signed_errors == 0)) begin
            $display("--- ALL TESTS PASSED ---");
        end else begin
            $display("--- TEST FAILURES DETECTED ---");
        end

        $finish;
    end

endmodule