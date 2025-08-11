// top.v
// Top-level module for the entire DCIM macro.
// It instantiates the global controller and the main digital circuit.

module top #(
    parameter INPUT_WIDTH = 144,
    parameter WEIGHT_BITS = 12,
    parameter WWIDTH_WIDTH = 1,
    parameter INWIDTH_WIDTH = 1,
    parameter ACC_WIDTH = 51
)(
    input wire clk,
    input wire rst_n,

    // External interface
    input wire start_op, // Start a new MAC operation
    input wire [WWIDTH_WIDTH-1:0] wwidth,   // Weight width config
    input wire [INWIDTH_WIDTH-1:0] inwidth,  // Input width config

    // Weight update interface
    input wire we,
    input wire [7:0] wa,
    input wire [WEIGHT_BITS-1:0] d_in,

    // Input data interface
    input wire [INPUT_WIDTH-1:0] xin,

    // Output interface
    output wire [ACC_WIDTH-1:0] nout,
    output wire op_done
);

    // Internal control signals
    wire [3:0] sel;
    wire start_acc;
    wire mac_on_pong_row;
    wire write_to_pong_row;
    wire signed_op;

    // Instantiate the Global Controller
    gctrl #(
        .WWIDTH_WIDTH(WWIDTH_WIDTH),
        .INWIDTH_WIDTH(INWIDTH_WIDTH)
    ) u_gctrl (
        .clk(clk),
        .rst_n(rst_n),
        .start_op(start_op),
        .wwidth(wwidth),
        .inwidth(inwidth),
        .sel(sel),
        .start_acc(start_acc),
        .mac_on_pong_row(mac_on_pong_row),
        .write_to_pong_row(write_to_pong_row),
        .signed_op(signed_op),
        .op_done(op_done)
    );

    // Instantiate the Digital Circuit
    digital_circuit #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .WEIGHT_BITS(WEIGHT_BITS),
        .ACC_WIDTH(ACC_WIDTH)
    ) u_digital_circuit (
        .clk(clk),
        .rst_n(rst_n),
        .sel(sel),
        .mac_on_pong_row(mac_on_pong_row),
        .write_to_pong_row(write_to_pong_row),
        .start_acc(start_acc),
        .signed_op(signed_op),
        .we(we),
        .wa(wa),
        .d_in(d_in),
        .xin(xin),
        .nout(nout)
    );

endmodule
