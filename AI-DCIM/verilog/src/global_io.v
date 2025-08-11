// global_io.v
// Handles the global data path, combining results from local MACs
// and feeding them to the accumulator.

module global_io #(
    parameter PSUM_WIDTH = 12, // Width of the partial sum from each local_mac
    parameter GIO_OUT_WIDTH = 27 // Output width to the accumulator
)(
    input wire [PSUM_WIDTH-1:0] macout_a, // Output from the first local_mac
    input wire [PSUM_WIDTH-1:0] macout_b, // Output from the second local_mac
    input wire signed_op,                 // Control signal for signed/unsigned operation

    output wire [GIO_OUT_WIDTH-1:0] psum_out // Combined partial sum to accumulator
);

    // The project description says "进行一次加法/减法操作".
    // This suggests the two mac outputs are combined.
    // The width of the result will be larger.
    // Let's assume a simple addition for now. The signedness will be important.

    // We need to extend the inputs to the output width before adding.
    // The paper mentions signed operations, so we perform sign extension.
    wire [GIO_OUT_WIDTH-1:0] extended_a;
    wire [GIO_OUT_WIDTH-1:0] extended_b;

    // Sign extend based on the MSB of the input psums
    assign extended_a = {{ (GIO_OUT_WIDTH - PSUM_WIDTH){macout_a[PSUM_WIDTH-1]} }, macout_a};
    assign extended_b = {{ (GIO_OUT_WIDTH - PSUM_WIDTH){macout_b[PSUM_WIDTH-1]} }, macout_b};

    // The operation can be addition or subtraction, controlled by a signal.
    // 0=add, 1=sub
    assign psum_out = signed_op ? (extended_a - extended_b) : (extended_a + extended_b);

endmodule
