// digital_circuit.v
// Integrates the main digital components: cim_array, global_io, and accumulator.

module digital_circuit #(
    parameter INPUT_WIDTH = 144,
    parameter WEIGHT_BITS = 12,
    parameter PSUM_WIDTH = 12,
    parameter GIO_OUT_WIDTH = 27,
    parameter ACC_WIDTH = 51
)(
    input wire clk,
    input wire rst_n,

    // Control signals from gctrl
    input wire [3:0] sel,
    input wire mac_on_pong_row,
    input wire write_to_pong_row,
    input wire start_acc,
    input wire signed_op,

    // Interface for weight updates
    input wire we,
    input wire [7:0] wa,
    input wire [WEIGHT_BITS-1:0] d_in,

    // Interface for input data
    input wire [INPUT_WIDTH-1:0] xin,

    // Final output
    output wire [ACC_WIDTH-1:0] nout
);

    wire [PSUM_WIDTH-1:0] macout_a;
    wire [PSUM_WIDTH-1:0] macout_b;
    wire [GIO_OUT_WIDTH-1:0] psum_to_acc;

    // Instantiate the CIM array
    cim_array #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .WEIGHT_BITS(WEIGHT_BITS),
        .PSUM_WIDTH(PSUM_WIDTH)
    ) u_cim_array (
        .clk(clk),
        .rst_n(rst_n),
        .sel(sel),
        .mac_on_pong_row(mac_on_pong_row),
        .write_to_pong_row(write_to_pong_row),
        .we(we),
        .wa(wa),
        .d_in(d_in),
        .xin(xin),
        .macout_a(macout_a),
        .macout_b(macout_b)
    );

    // Instantiate the Global I/O
    global_io #(
        .PSUM_WIDTH(PSUM_WIDTH),
        .GIO_OUT_WIDTH(GIO_OUT_WIDTH)
    ) u_global_io (
        .macout_a(macout_a),
        .macout_b(macout_b),
        .signed_op(signed_op),
        .psum_out(psum_to_acc)
    );

    // Instantiate the Accumulator
    accumulator #(
        .INPUT_WIDTH(GIO_OUT_WIDTH),
        .OUTPUT_WIDTH(ACC_WIDTH)
    ) u_accumulator (
        .clk(clk),
        .rst_n(rst_n),
        .start_acc(start_acc),
        .psum_in(psum_to_acc),
        .nout(nout)
    );

endmodule
