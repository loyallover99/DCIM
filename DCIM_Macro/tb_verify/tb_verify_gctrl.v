`timescale 1ns / 1ps

module tb_verify_gctrl;

    // Inputs
    reg clk;
    reg rstn;
    reg start;
    reg inwidth;

    // Outputs
    wire [5:0] sel;
    wire st;

    // Instantiate the Unit Under Test (UUT)
    gctrl uut (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .inwidth(inwidth),
        .sel(sel),
        .st(st)
    );

    integer errors = 0;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Verification task
    task check_output;
        input [5:0] expected_sel;
        input st_val;
        begin
            #1; // Allow for combinational logic to settle
            if (sel !== expected_sel || st !== st_val) begin
                $display("ERROR @ Time=%0t: sel = %d (expected %d), st = %b (expected %b)", $time, sel, expected_sel, st, st_val);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Initialize Inputs
        rstn = 0;
        start = 0;
        inwidth = 0;

        $dumpfile("tb_verify_gctrl.vcd");
        $dumpvars(0, tb_verify_gctrl);

        // Test Case 1: Reset
        $display("--- Verification Case 1: Reset ---");
        #10;
        rstn = 1;
        #10;
        check_output(0, 1);

        // Test Case 2: 12-bit mode (inwidth=0)
        $display("--- Verification Case 2: 12-bit mode (inwidth=0) ---");
        inwidth = 0;
        start = 1;
        @(posedge clk); #1;
        start = 0;
        @(posedge clk); #1;
        wait (st == 1);
        check_output(11, 1);
        #20;

        // Test Case 3: 24-bit mode (inwidth=1)
        $display("--- Verification Case 3: 24-bit mode (inwidth=1) ---");
        inwidth = 1;
        start = 1;
        @(posedge clk); #1;
        start = 0;
        @(posedge clk); #1;
        wait (st == 1);
        check_output(23, 1);
        #20;

        // Test Case 4: Start during operation (should be ignored)
        $display("--- Verification Case 4: Start during operation ---");
        inwidth = 0;
        start = 1;
        @(posedge clk); #1;
        start = 0;
        @(posedge clk); #1;
        #30;
        start = 1;
        @(posedge clk); #1;
        start = 0;
        wait (st == 1);
        check_output(11, 1);

        // Test Case 5: Reset during operation
        $display("--- Verification Case 5: Reset during operation ---");
        inwidth = 1; // 24-bit mode
        start = 1;
        @(posedge clk); #1;
        start = 0;
        @(posedge clk); #1;
        #50; // Let it run for a while
        rstn = 0;
        #10;
        rstn = 1;
        #10;
        check_output(0, 1);

        // Final result
        #20;
        if (errors == 0)
            $display("--- VERIFICATION PASSED ---");
        else
            $display("--- VERIFICATION FAILED: %0d errors ---", errors);

        $finish;
    end

endmodule