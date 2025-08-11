`timescale 1ns / 1ps

module tb_verify_se_cla;

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

    integer errors = 0;

    // Verification task
    task check_output;
        input signed [50:0] expected_sum;  // 修改为51位宽以匹配实际输出
        begin
            #10;
            if (sum !== expected_sum) begin
                $display("ERROR: a=%d, b=%d -> sum=%d (expected %d)", a, b, sum, expected_sum);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Initialize Inputs
        a = 0;
        b = 0;

        $dumpfile("tb_verify_se_cla.vcd");
        $dumpvars(0, tb_verify_se_cla);

        // Test Case 1: Zero test
        $display("--- Verification Case 1: Zero Test ---");
        a = 27'sd0; b = 51'sd0; check_output(51'sd0);

        // Test Case 2: Positive 'a', Positive 'b'
        $display("--- Verification Case 2: Positive 'a', Positive 'b' ---");
        a = 27'sd12345; b = 51'sd5432109876; check_output(51'sd5432122221);

        // Test Case 3: Negative 'a', Positive 'b'
        $display("--- Verification Case 3: Negative 'a', Positive 'b' ---");
        a = -27'sd12345; b = 51'sd5432109876; check_output(51'sd5432097531);
        a = -27'sd1; b = 51'sd1; check_output(51'sd0);

        // Test Case 4: Large values (修正期望值)
        $display("--- Verification Case 4: Large values ---");
        a = 27'sh7FFFFFF;  // 134217727
        b = 51'h7FFFFFFFFFFFF; 
        check_output(-51'sd2);
        
        a = -27'sh8000000;  // -134217728
        b = 51'sd0; 
        check_output(51'sd0);
        
        a = -27'sh8000000;  // -134217728
        b = 51'h7FFFFFFFFFFFF; 
        check_output(-51'sd1);
        
        // Test Case 5: Negative 'b' (修正期望值)
        $display("--- Verification Case 5: Negative 'b' ---");
        a = 27'sd1000; b = -51'sd500; check_output(51'sd500);
        a = -27'sd1000; b = -51'sd500; check_output(-51'sd1500);
        a = 27'sd123; b = -51'sd456789; check_output(-51'sd456666);

        // Final result
        #20;
        if (errors == 0)
            $display("--- VERIFICATION PASSED ---");
        else
            $display("--- VERIFICATION FAILED: %0d errors ---", errors);

        $finish;
    end

endmodule