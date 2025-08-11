`timescale 1ns / 1ps

module tb_local_mac;

    // Inputs
    reg [95:0] wb0;
    reg [95:0] wb1;
    reg [7:0] rwlb_row0;
    reg [7:0] rwlb_row1;
    reg sus;

    // Outputs
    wire [14:0] mac_out;

    // Instantiate the Unit Under Test (UUT)
    local_mac uut (
        .wb0(wb0),
        .wb1(wb1),
        .rwlb_row0(rwlb_row0),
        .rwlb_row1(rwlb_row1),
        .sus(sus),
        .mac_out(mac_out)
    );

    initial begin
        // Initialize Inputs
        wb0 = 0;
        wb1 = 0;
        rwlb_row0 = 0;
        rwlb_row1 = 0;
        sus = 0;

        $display("// --- Generated Verification Code ---");

        // Test Case 1: Zero inputs, unsigned
        $display("// Test Case 1: Zero inputs, unsigned");
        sus = 0;
        wb0 = 0;
        wb1 = 0;
        rwlb_row0 = 0;
        rwlb_row1 = 0;
        #10;
        $display("check_output(15'h%h);", mac_out);

        // Test Case 2: One active multiplier, unsigned
        $display("// Test Case 2: One active multiplier, unsigned");
        sus = 0;
        wb0 = 96'hFFFFFFFFFFFFFFFFFFFFFF;
        wb1 = 96'hFFFFFFFFFFFFFFFFFFFFFF;
        rwlb_row0 = 8'b00000001;
        rwlb_row1 = 8'b00000001;
        #10;
        $display("check_output(15'h%h);", mac_out);

        // Test Case 3: Simple signed case
        $display("// Test Case 3: Simple signed case");
        sus = 1;
        wb0 = {96-24{1'b1}} | 24'hFFF000;
        wb1 = {96-24{1'b1}} | 24'hFFE000;
        rwlb_row0 = 8'b11111100;
        rwlb_row1 = 8'b0;
        #10;
        $display("check_output(15'h%h);", mac_out);

        #20;
        $finish;
    end

endmodule
