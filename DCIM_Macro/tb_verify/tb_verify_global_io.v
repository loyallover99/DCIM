`timescale 1ns / 1ps

module tb_verify_global_io;

    // Inputs
    reg [14:0] macout_a;
    reg [14:0] macout_b;
    reg clk;
    reg acm_en;
    reg rstn;
    reg st;
    reg wwidth;

    // Outputs
    wire [50:0] nout;

    // Instantiate the Unit Under Test (UUT)
    global_io uut (
        .macout_a(macout_a),
        .macout_b(macout_b),
        .clk(clk),
        .acm_en(acm_en),
        .rstn(rstn),
        .st(st),
        .wwidth(wwidth),
        .nout(nout)
    );

    integer errors = 0;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Verification task
    task check_output;
        input [50:0] expected_nout;
        begin
            #1; // Allow for combinational logic to settle
            if (nout !== expected_nout) begin
                $display("ERROR @ Time=%0t: nout = %d (expected %d)", $time, nout, expected_nout);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Initialize Inputs
        macout_a = 0;
        macout_b = 0;
        acm_en = 0;
        rstn = 0;
        st = 1;
        wwidth = 0;

        $dumpfile("tb_verify_global_io.vcd");
        $dumpvars(0, tb_verify_global_io);

        // Test Case 1: Reset
        $display("--- Verification Case 1: Reset ---");
        #10;
        rstn = 1;
        #10;
        check_output(0);

        // Test Case 2: 12-bit weight mode (wwidth=0)
        $display("--- Verification Case 2: 12-bit weight mode (wwidth=0) ---");
        st = 1; @(posedge clk); #1;
        st = 0;
        acm_en = 1;
        wwidth = 0;
        macout_a = 10; macout_b = 999; @(posedge clk); check_output(10);
        macout_a = 20; macout_b = 888; @(posedge clk); check_output(40);
        macout_a = 30; macout_b = 777; @(posedge clk); check_output(110);

        // Test Case 3: 24-bit weight mode (wwidth=1)
        $display("--- Verification Case 3: 24-bit weight mode (wwidth=1) ---");
        st = 1; @(posedge clk); #1;
        st = 0;
        wwidth = 1;
        macout_a = 10; macout_b = 1; @(posedge clk); check_output(4106);
        macout_a = 20; macout_b = 2; @(posedge clk); check_output(16424);

        // Test Case 4: acm_en disable/enable
        $display("--- Verification Case 4: acm_en disable/enable ---");
        st = 1; @(posedge clk); #1;
        st = 0;
        wwidth = 0;
        acm_en = 1;
        macout_a = 100; @(posedge clk); check_output(100);
        acm_en = 0;
        macout_a = 50; @(posedge clk); check_output(100);
        acm_en = 1;
        macout_a = 5; @(posedge clk); check_output(205);

        // Test Case 5: st during operation
        $display("--- Verification Case 5: st during operation ---");
        st = 0;
        wwidth = 0;
        acm_en = 1;
        macout_a = 1; @(posedge clk); check_output(411);
        macout_a = 2; @(posedge clk); check_output(824);
        st = 1; @(posedge clk); check_output(0);
        st = 0;
        macout_a = 99; @(posedge clk); check_output(99);

        // Final result
        #20;
        if (errors == 0)
            $display("--- VERIFICATION PASSED ---");
        else
            $display("--- VERIFICATION FAILED: %0d errors ---", errors);

        $finish;
    end

endmodule