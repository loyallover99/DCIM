`timescale 1ns / 1ps

module tb_cim_array_ctrl;

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

    initial begin
        // Initialize Inputs
        D = 0;
        WA = 0;
        cima = 0;

        $dumpfile("tb_cim_array_ctrl.vcd");
        $dumpvars(0, tb_cim_array_ctrl);

        // Test Case 1: cima = 0 (select bank 0)
        $display("--- Test Case 1: cima = 0 (select bank 0) ---");
        D = 24'hABCDEF;
        WA = 8'hA5;
        cima = 0;
        #10;
        $display("D=%h, WA=%h, cima=%b -> D1=%h, WA0=%h, WA1=%h", D, WA, cima, D1, WA0, WA1);
        if (D1 === D && WA0 === WA && WA1 === 8'b0)
            $display("PASSED");
        else
            $display("FAILED");

        // Test Case 2: cima = 1 (select bank 1)
        $display("--- Test Case 2: cima = 1 (select bank 1) ---");
        D = 24'h123456;
        WA = 8'h5A;
        cima = 1;
        #10;
        $display("D=%h, WA=%h, cima=%b -> D1=%h, WA0=%h, WA1=%h", D, WA, cima, D1, WA0, WA1);
        if (D1 === D && WA0 === 8'b0 && WA1 === WA)
            $display("PASSED");
        else
            $display("FAILED");

        // Test Case 3: Change D and WA while cima=0
        $display("--- Test Case 3: Change D and WA while cima=0 ---");
        cima = 0;
        D = 24'hFFFFFF;
        WA = 8'hFF;
        #10;
        $display("D=%h, WA=%h, cima=%b -> D1=%h, WA0=%h, WA1=%h", D, WA, cima, D1, WA0, WA1);
        if (D1 === D && WA0 === WA && WA1 === 8'b0)
            $display("PASSED");
        else
            $display("FAILED");

        // Test Case 4: Change cima while D and WA are stable
        $display("--- Test Case 4: Change cima while D and WA are stable ---");
        D = 24'hC0FFEE;
        WA = 8'hC3;
        cima = 0;
        #10;
        $display("D=%h, WA=%h, cima=%b -> D1=%h, WA0=%h, WA1=%h", D, WA, cima, D1, WA0, WA1);
        cima = 1;
        #10;
        $display("D=%h, WA=%h, cima=%b -> D1=%h, WA0=%h, WA1=%h", D, WA, cima, D1, WA0, WA1);
        if (D1 === D && WA0 === 8'b0 && WA1 === WA)
            $display("PASSED");
        else
            $display("FAILED");


        #20;
        $finish;
    end

endmodule