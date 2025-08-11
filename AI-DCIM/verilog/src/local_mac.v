// local_mac.v
// Performs local MAC operation for one bit-slice of weights.
// It multiplies 144 input bits with 144 weight bits and sums the results.

module local_mac #(
    parameter INPUT_WIDTH = 144,
    // The output width depends on the number of inputs.
    // log2(144) is approx 7.1, so we need at least 8 bits.
    // The paper mentions a 12b PSUM, let's use that.
    parameter PSUM_WIDTH = 12
)(
    input wire [INPUT_WIDTH-1:0] wb,   // Weight bits from cim_bank
    input wire [INPUT_WIDTH-1:0] rwlb, // Input bits from rwldrv

    output wire [PSUM_WIDTH-1:0] psum // Partial Sum output
);

    wire [INPUT_WIDTH-1:0] products;
    genvar i;

    // 1. Bitwise Multiplication Array
    // Instantiate 144 multipliers
    for (i = 0; i < INPUT_WIDTH; i = i + 1) begin: mult_gen
        oai_mult u_oai_mult (
            .wb(wb[i]),
            .rwlb(rwlb[i]),
            .out(products[i])
        );
    end

    // 2. Adder Tree
    // This combinatorially sums all the product bits.
    // For synthesis, this would be inferred as an adder tree.
    // A simple procedural block can model this behavior.
    integer j;
    reg [PSUM_WIDTH-1:0] sum_reg;

    always @(*) begin
        sum_reg = 0;
        for (j = 0; j < INPUT_WIDTH; j = j + 1) begin
            sum_reg = sum_reg + products[j];
        end
    end

    assign psum = sum_reg;

endmodule
