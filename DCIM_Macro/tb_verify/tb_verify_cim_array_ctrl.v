`timescale 1ns / 1ps

module tb_verify_cim_array_ctrl;

    // Inputs
    reg [23:0] D;
    reg [7:0] WA;
    reg cima;

    // Outputs
    wire [23:0] D1;
    wire [7:0] WA0;
    wire [7:0] WA1;

    // Instantiate the Unit Under Test (UUT)
    cim_array_ctrl uut (
        .D(D),
        .WA(WA),
        .cima(cima),
        .D1(D1),
        .WA0(WA0),
        .WA1(WA1)
    );

    integer error_count;
    task check_outputs;
        input [23:0] expected_D1;
        input [7:0] expected_WA0;
        input [7:0] expected_WA1;
        begin
            #1; // Allow combinational logic to settle
            if (D1 !== expected_D1 || WA0 !== expected_WA0 || WA1 !== expected_WA1) begin
                $display("FAIL: D=%h, WA=%h, cima=%b -> D1=%h(exp:%h), WA0=%h(exp:%h), WA1=%h(exp:%h)",
                         D, WA, cima, D1, expected_D1, WA0, expected_WA0, WA1, expected_WA1);
                error_count = error_count + 1;
            end else begin
                $display("PASS: D=%h, WA=%h, cima=%b", D, WA, cima);
            end
        end
    endtask

    initial begin
        // Initialize
        D = 0;
        WA = 0;
        cima = 0;
        error_count = 0;

        $display("--- Verification for cim_array_ctrl starting ---");

        // Test Case 1: cima = 0 (select bank 0) - from log
        D = 24'hABCDEF;
        WA = 8'hA5;
        cima = 0;
        #10;
        check_outputs(24'hABCDEF, 8'hA5, 8'h00);

        // Test Case 2: cima = 1 (select bank 1) - from log
        D = 24'h123456;
        WA = 8'h5A;
        cima = 1;
        #10;
        check_outputs(24'h123456, 8'h00, 8'h5A);

        // Test Case 3: Zero inputs
        D = 24'h0;
        WA = 8'h0;
        cima = 0;
        #10;
        check_outputs(24'h0, 8'h0, 8'h0);

        // Test Case 4: Zero inputs, bank 1
        D = 24'h0;
        WA = 8'h0;
        cima = 1;
        #10;
        check_outputs(24'h0, 8'h0, 8'h0);

        #20;
        if (error_count == 0) begin
            $display("--- All cim_array_ctrl checks PASSED ---");
        end else begin
            $display("--- cim_array_ctrl verification FAILED with %d errors ---", error_count);
        end
        $finish;
    end

endmodule
