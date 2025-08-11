`timescale 1ns / 1ps

module tb_verify_accumulator;

    // Inputs
    reg [26:0] a;
    reg clk;
    reg acm_en;
    reg rstn;
    reg st;

    // Outputs
    wire [50:0] nout;

    // Instantiate the Unit Under Test (UUT)
    accumulator uut (
        .a(a),
        .clk(clk),
        .acm_en(acm_en),
        .rstn(rstn),
        .st(st),
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
        a = 0;
        acm_en = 0;
        rstn = 0;
        st = 1;

        $dumpfile("tb_verify_accumulator.vcd");
        $dumpvars(0, tb_verify_accumulator);

        // Test Case 1: Reset
        $display("--- Verification Case 1: Reset ---");
        #10;
        rstn = 1;
        #10;
        check_output(0);

        // Test Case 2: Accumulation disabled
        $display("--- Verification Case 2: Accumulation disabled (acm_en=0) ---");
        acm_en = 0;
        st = 0;
        a = 100;
        #20; // Wait for a few clock cycles
        check_output(0);

        // Test Case 3: Accumulation enabled and running
        $display("--- Verification Case 3: Accumulation enabled and running ---");
        acm_en = 1;
        st = 0;
        a = 10; @(posedge clk); check_output(10);
        a = 20; @(posedge clk); check_output(40);
        a = 30; @(posedge clk); check_output(110);
        a = 0;  @(posedge clk); check_output(220);

        // Test Case 4: 'st' signal stops and resets accumulation
        $display("--- Verification Case 4: 'st' signal high ---");
        st = 1;
        a = 999; // This value should be ignored
        @(posedge clk);
        check_output(0);
        st = 0;
        a = 5;
        @(posedge clk);
        check_output(5);

        // Test Case 5: Negative reset
        $display("--- Verification Case 5: Negative reset (rstn=0) ---");
        rstn = 0;
        #10;
        check_output(0);

        // Final result
        #20;
        if (errors == 0)
            $display("--- VERIFICATION PASSED ---");
        else
            $display("--- VERIFICATION FAILED: %0d errors ---", errors);

        $finish;
    end

endmodule
