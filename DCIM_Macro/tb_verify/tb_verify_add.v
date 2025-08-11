`timescale 1ns / 1ps

module tb_verify_add;

    // Parameters
    localparam width = 12;

    // Inputs
    reg signed [width-1:0] a;  // 声明为有符号类型
    reg signed [width-1:0] b;   // 声明为有符号类型
    reg sus;

    // Outputs
    wire signed [width:0] sum;  // 声明为有符号类型

    // Instantiate the Unit Under Test (UUT)
    add #(.width(width)) uut (
        .a(a),
        .b(b),
        .sus(sus),
        .sum(sum)
    );

    integer errors = 0;

    initial begin
        // Initialize Inputs
        a = 0;
        b = 0;
        sus = 0;

        $dumpfile("tb_verify_add.vcd");
        $dumpvars(0, tb_verify_add);

        // --- Verification Case 1: Unsigned Addition (sus = 0) ---
        $display("--- Verification Case 1: Unsigned Addition (sus = 0) ---");
        sus = 0;
        a = 12'd10; b = 12'd20; #10; 
        if (sum !== 13'd30) begin
            errors = errors + 1;
            $display("Error: %d + %d = %d (expected 30)", a, b, sum);
        end
        
        a = 12'd4095; b = 12'd1; #10; 
        if (sum !== 13'd4096) begin
            errors = errors + 1;
            $display("Error: %d + %d = %d (expected 4096)", a, b, sum);
        end
        
        a = 12'hFFF; b = 12'hFFF; #10; 
        if (sum !== 13'h1FFE) begin
            errors = errors + 1;
            $display("Error: %h + %h = %h (expected 1FFE)", a, b, sum);
        end
        
        a = 12'h000; b = 12'h000; #10; 
        if (sum !== 13'd0) begin
            errors = errors + 1;
            $display("Error: %d + %d = %d (expected 0)", a, b, sum);
        end

        // --- Verification Case 2: Signed Addition (sus = 1) ---
        $display("--- Verification Case 2: Signed Addition (sus = 1) ---");
        sus = 1;
        
        // 正数+正数
        a = 12'sd10; b = 12'sd20; #10; 
        if (sum !== 13'sd30) begin 
            errors = errors + 1;
            $display("Error: %d + %d = %d (expected 30)", a, b, sum);
        end
        
        // 负数+正数
        a = -12'sd10; b = 12'sd20; #10; 
        if (sum !== 13'sd10) begin 
            errors = errors + 1;
            $display("Error: %d + %d = %d (expected 10)", a, b, sum);
        end
        
        // 正数+负数
        a = 12'sd10; b = -12'sd20; #10; 
        if (sum !== -13'sd10) begin 
            errors = errors + 1;
            $display("Error: %d + %d = %d (expected -10)", a, b, sum);
        end
        
        // 负数+负数
        a = -12'sd10; b = -12'sd20; #10; 
        if (sum !== -13'sd30) begin 
            errors = errors + 1;
            $display("Error: %d + %d = %d (expected -30)", a, b, sum);
        end
        
        // 边界测试
        a = 12'sd2047; b = 12'sd1; #10; 
        if (sum !== 13'sd2048) begin 
            errors = errors + 1;
            $display("Error: %d + %d = %d (expected 2048)", a, b, sum);
        end
        
        a = -12'sd2048; b = -12'sd1; #10; 
        if (sum !== -13'sd2049) begin 
            errors = errors + 1;
            $display("Error: %d + %d = %d (expected -2049)", a, b, sum);
        end
        
        a = 12'sh7FF; b = 12'sh7FF; #10; 
        if (sum !== 13'shFFE) begin 
            errors = errors + 1;
            $display("Error: %h + %h = %h (expected FFE)", a, b, sum);
        end
        
        a = 12'sh800; b = 12'sh800; #10; 
        if (sum !== 13'sh1000) begin 
            errors = errors + 1;
            $display("Error: %h + %h = %h (expected 1000)", a, b, sum);
        end

        // Final result
        #20;
        if (errors == 0)
            $display("--- VERIFICATION PASSED ---");
        else
            $display("--- VERIFICATION FAILED: %0d errors ---", errors);

        $finish;
    end

endmodule