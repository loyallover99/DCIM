// cim_bank.v
// Models a single bit-slice of the SRAM weight memory for all 144 inputs.
// It includes two rows (ping-pong buffer) to allow simultaneous
// weight updates and MAC operations.

module cim_bank #(
    parameter ROWS = 144,
    parameter ADDR_WIDTH = 8 // ceil(log2(ROWS))
)(
    input wire clk,
    input wire we,                  // Write Enable
    input wire [ADDR_WIDTH-1:0] wa, // Write Address
    input wire d_in,                // Write Data In
    input wire write_to_pong_row,   // 0: write to ping (row0), 1: write to pong (row1)

    output wire [ROWS-1:0] wb_out_ping, // Ping row weight bits
    output wire [ROWS-1:0] wb_out_pong  // Pong row weight bits
);

    // Memory array: 2 rows for ping-pong, ROWS bits per row
    reg [ROWS-1:0] mem_ping; // row0
    reg [ROWS-1:0] mem_pong; // row1

    // Write Logic
    always @(posedge clk) begin
        if (we) begin
            if (write_to_pong_row) begin
                mem_pong[wa] <= d_in;
            end else begin
                mem_ping[wa] <= d_in;
            end
        end
    end

    // Read Logic (combinational)
    // Output the entire memory content.
    // The selection of which bit to use for multiplication will be handled
    // by the local_mac using the rwlb signals.
    assign wb_out_ping = mem_ping;
    assign wb_out_pong = mem_pong;

endmodule
