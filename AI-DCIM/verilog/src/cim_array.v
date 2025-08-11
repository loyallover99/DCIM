// cim_array.v
// A complete Compute-In-Memory array, integrating memory banks,
// local MAC units, and row drivers.

module cim_array #(
    parameter INPUT_WIDTH = 144,
    parameter WEIGHT_BITS = 12, // Number of bit-slices for weights
    parameter PSUM_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,

    // Control signals from gctrl
    input wire [3:0] sel,
    input wire mac_on_pong_row,
    input wire write_to_pong_row,

    // Interface for weight updates
    input wire we, // Write enable
    input wire [7:0] wa, // Write address for the bank
    input wire [WEIGHT_BITS-1:0] d_in, // Weight data in (one slice)

    // Interface for input data
    input wire [INPUT_WIDTH-1:0] xin,

    // Output partial sums
    // The paper implies multiple MAC units operating in parallel.
    // Let's assume two for now, as suggested by the global_io description.
    output wire [PSUM_WIDTH-1:0] macout_a,
    output wire [PSUM_WIDTH-1:0] macout_b
);

    // We need to instantiate multiple bit-slices of the cim_bank and local_mac
    // to handle the full 12-bit or 24-bit weights.
    // This creates a 3D structure: 144 inputs, N weight bits, 2 rows (ping/pong)

    // For now, let's model a single bit-slice to keep it simple.
    // A full implementation would have a generate block for all WEIGHT_BITS.

    wire [INPUT_WIDTH-1:0] wb_out_ping_0;
    wire [INPUT_WIDTH-1:0] wb_out_pong_0;
    wire [INPUT_WIDTH-1:0] rwlb_ping;
    wire [INPUT_WIDTH-1:0] rwlb_pong;

    // Instantiate the row driver
    rwldrv #(.INPUT_WIDTH(INPUT_WIDTH)) u_rwldrv (
        .sel(sel),
        .xin(xin),
        .mac_on_pong_row(mac_on_pong_row),
        .rwlb_ping(rwlb_ping),
        .rwlb_pong(rwlb_pong)
    );

    // Instantiate the first bit-slice of the memory bank
    cim_bank #(.ROWS(INPUT_WIDTH)) u_cim_bank_0 (
        .clk(clk),
        .we(we),
        .wa(wa),
        .d_in(d_in[0]),
        .write_to_pong_row(write_to_pong_row),
        .wb_out_ping(wb_out_ping_0),
        .wb_out_pong(wb_out_pong_0)
    );

    // Instantiate the first local MAC unit
    local_mac #(.INPUT_WIDTH(INPUT_WIDTH), .PSUM_WIDTH(PSUM_WIDTH)) u_local_mac_a (
        .wb(mac_on_pong_row ? wb_out_pong_0 : wb_out_ping_0),
        .rwlb(mac_on_pong_row ? rwlb_pong : rwlb_ping),
        .psum(macout_a)
    );

    // In a full design, we would have another local_mac (macout_b) connected
    // to a different set of cim_banks or processing different data.
    // For this simplified model, we can tie macout_b to zero or another source.
    // Let's assume for now it processes the same data for simplicity.
    // This will be refined when the full parallel architecture is defined.
    local_mac #(.INPUT_WIDTH(INPUT_WIDTH), .PSUM_WIDTH(PSUM_WIDTH)) u_local_mac_b (
        .wb(mac_on_pong_row ? wb_out_pong_0 : wb_out_ping_0), // Placeholder
        .rwlb(mac_on_pong_row ? rwlb_pong : rwlb_ping),
        .psum(macout_b)
    );


endmodule
