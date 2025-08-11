// gctrl.v
// Global controller for the DCIM macro.
// Generates timing, control, and configuration signals.

module gctrl #(
    parameter SEL_WIDTH = 4,
    parameter WWIDTH_WIDTH = 1, // 0 for 12b, 1 for 24b weights
    parameter INWIDTH_WIDTH = 1 // 0 for 12b, 1 for 24b inputs
)(
    input wire clk,
    input wire rst_n,
    input wire start_op, // External signal to start a new MAC operation

    input wire [WWIDTH_WIDTH-1:0] wwidth,   // Weight width configuration
    input wire [INWIDTH_WIDTH-1:0] inwidth,  // Input width configuration

    output reg [SEL_WIDTH-1:0] sel,       // Cycle selection signal for rwldrv
    output reg start_acc,                  // Start signal for the accumulator
    output reg mac_on_pong_row,           // Control for ping-pong MAC
    output reg write_to_pong_row,         // Control for ping-pong write
    output wire signed_op,                 // Control for signed operations in global_io
    output wire op_done                    // Signal to indicate MAC operation is complete
);

    // Internal state machine or counters to control the operation flow
    reg [SEL_WIDTH:0] cycle_counter; // Counter for the MAC cycles
    reg [2:0] start_delay_counter;
    reg is_running;

    // Determine the number of cycles based on input width
    // 0: 12 cycles for 12b input
    // 1: 24 cycles for 24b input
    wire [SEL_WIDTH:0] max_cycles = inwidth ? 24 : 12;

    // The paper mentions the first 4 cycles are signed, the rest are unsigned.
    // This logic will be used to control the signed_op signal.
    assign signed_op = (cycle_counter >= 4);

    assign op_done = !is_running && (cycle_counter == max_cycles);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sel <= 0;
            cycle_counter <= 0;
            start_acc <= 1'b0;
            is_running <= 1'b0;
            mac_on_pong_row <= 1'b0;
            write_to_pong_row <= 1'b1; // Default to writing to the other row
            start_delay_counter <= 0;
        end else begin
            if (start_op && !is_running) begin
                is_running <= 1'b1;
                cycle_counter <= 0;
                sel <= 0;
                start_acc <= 1'b0; // Don't start immediately
                start_delay_counter <= 3; // Wait 3 cycles
                // Swap the roles of the ping-pong buffers
                mac_on_pong_row <= ~mac_on_pong_row;
                write_to_pong_row <= mac_on_pong_row;
            end else if (is_running) begin
                if (start_delay_counter > 0) begin
                    start_delay_counter <= start_delay_counter - 1;
                    if (start_delay_counter == 1) begin
                        start_acc <= 1'b1; // Assert start_acc after delay
                    end else {
                        start_acc <= 1'b0;
                    }
                end else {
                    start_acc <= 1'b0;
                }

                if (cycle_counter < max_cycles) begin
                    cycle_counter <= cycle_counter + 1;
                    sel <= sel + 1;
                end else {
                    is_running <= 1'b0; // Operation finished
                }
            end
        end
    end

endmodule