// accumulator.v
// Global accumulator with shifting for multi-cycle accumulation.

module accumulator #(
    parameter INPUT_WIDTH = 27, // Width of the input partial sum
    parameter OUTPUT_WIDTH = 51 // Width of the final accumulated output
)(
    input wire clk,
    input wire rst_n,             // Asynchronous reset, active low
    input wire start_acc,         // Signal from gctrl to start a new accumulation
    input wire [INPUT_WIDTH-1:0] psum_in, // Partial sum from global_io

    output reg [OUTPUT_WIDTH-1:0] nout   // Final accumulated result
);

    reg [OUTPUT_WIDTH-1:0] acc_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_reg <= 0;
            nout <= 0;
        end else begin
            if (start_acc) begin
                // When a new operation starts, reset the accumulator.
                acc_reg <= 0;
            end else begin
                // Accumulate on the subsequent cycles.
                // This ensures we don't miss the first psum.
                acc_reg <= (acc_reg << 1) + {{ (OUTPUT_WIDTH - INPUT_WIDTH){psum_in[INPUT_WIDTH-1]} }, psum_in};
            end
            nout <= acc_reg;
        end
    end

endmodule
