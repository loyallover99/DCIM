`timescale 1ns / 1ps

module tb_verify_local_mac;

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

    integer errors = 0;

    // Verification task
    task check_output;
        input [14:0] expected_mac_out;
        begin
            #1; // Settle time
            if (mac_out !== expected_mac_out) begin
                $display("ERROR: sus=%b, wb0=%h, wb1=%h, rwlb_row0=%b, rwlb_row1=%b -> mac_out=%h (expected %h)",
                         sus, wb0, wb1, rwlb_row0, rwlb_row1, mac_out, expected_mac_out);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Initialize Inputs
        wb0 = 0;
        wb1 = 0;
        rwlb_row0 = 0;
        rwlb_row1 = 0;
        sus = 0;

        $dumpfile("tb_verify_local_mac.vcd");
        $dumpvars(0, tb_verify_local_mac);

        // Test Case 1: Zero inputs, unsigned
        $display("--- Verification Case 1: Zero inputs, unsigned ---");
        sus = 0;
        wb0 = 0;
        wb1 = 0;
        rwlb_row0 = 0;
        rwlb_row1 = 0;
        #10;
        check_output(15'h7ff8);

        // Test Case 2: One active multiplier, unsigned
        $display("--- Verification Case 2: One active multiplier, unsigned ---");
        sus = 0;
        wb0 = 96'hFFFFFFFFFFFFFFFFFFFFFF;
        wb1 = 96'hFFFFFFFFFFFFFFFFFFFFFF;
        rwlb_row0 = 8'b00000001;
        rwlb_row1 = 8'b00000001;
        #10;
        check_output(15'h0ff0);

        // Test Case 3: Simple signed case
        $display("--- Verification Case 3: Simple signed case ---");
        sus = 1;
        wb0 = {96-24{1'b1}} | 24'hFFF000;
        wb1 = {96-24{1'b1}} | 24'hFFE000;
        rwlb_row0 = 8'b11111100;
        rwlb_row1 = 8'b0;
        #10;
        check_output(15'h7ffe);

        // Final result
        #20;
        if (errors == 0)
            $display("--- VERIFICATION PASSED ---");
        else
            $display("--- VERIFICATION FAILED: %0d errors ---", errors);

        $finish;
    end

endmodule
