// rwldrv.v
// Read Word Line Driver
// This module selects the active input bits based on the cycle count (sel)
// and generates the row-driving signals for the MAC operation.

module rwldrv #(
    parameter INPUT_WIDTH = 144,
    parameter SEL_WIDTH = 4 // To select one of up to 16 groups of inputs
)(
    input wire [SEL_WIDTH-1:0] sel,      // Selection signal from gctrl, indicates current cycle
    input wire [INPUT_WIDTH-1:0] xin,    // The full input vector

    // Since we have a ping-pong structure, we need two sets of rwlb signals.
    // One for the row being used for MAC, the other is idle.
    input wire mac_on_pong_row, // 0: MAC on ping (row0), 1: MAC on pong (row1)

    output wire [INPUT_WIDTH-1:0] rwlb_ping, // Row driving signals for ping row
    output wire [INPUT_WIDTH-1:0] rwlb_pong  // Row driving signals for pong row
);

    // For this implementation, we assume the 144 inputs are processed in 12 cycles of 12 bits each.
    // This is a simplification based on the paper's description of bit-serial processing.
    // The exact grouping can be adjusted based on detailed architecture specs.
    localparam GROUP_SIZE = 12;
    localparam NUM_GROUPS = INPUT_WIDTH / GROUP_SIZE; // 144 / 12 = 12

    wire [INPUT_WIDTH-1:0] active_rwlb;
    reg [INPUT_WIDTH-1:0] generated_rwlb;

    // Decoder logic: activate one group of 12 bits based on 'sel'
    always @(*) begin
        generated_rwlb = {INPUT_WIDTH{1'b0}};
        if (sel < NUM_GROUPS) begin
            generated_rwlb[(sel * GROUP_SIZE) +: GROUP_SIZE] = xin[(sel * GROUP_SIZE) +: GROUP_SIZE];
        end
    end

    // Assign the generated rwlb to the correct output based on ping/pong control
    assign active_rwlb = generated_rwlb;

    assign rwlb_ping = mac_on_pong_row ? {INPUT_WIDTH{1'b0}} : active_rwlb;
    assign rwlb_pong = mac_on_pong_row ? active_rwlb : {INPUT_WIDTH{1'b0}};

endmodule
