// accumulator.v
// 功能: 51-bit 累加器 

/*module accumulator (
    input                   clk,
    input                   rstn,
    input                   st,       // 累加器启停信号 
    input      [26:0]       din,      // 来自global_io的27位加法结果
    output reg [50:0]       nout      // 最终累加输出
);

    reg [50:0] nout_1; // 存储上一个周期的累加结果
    wire [50:0] se_cla_sum;

    // 实例化符号扩展CLA加法器 
    se_cla u_se_cla (
        .a(din),
        .b(nout_1),
        .sum(se_cla_sum)
    );

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            nout <= 51'b0;
            nout_1 <= 51'b0;
        end else if (st) begin // 当st为高时，清零累加结果 
            nout <= 51'b0;
            nout_1 <= 51'b0;
        end else begin // 当st为低时，执行累加 
            // 将se_cla加法器的输出 nout左移一位并寄存到nout_1, 用于下一次累加 
            nout_1 <= {se_cla_sum[49:0], 1'b0}; 
            nout <= se_cla_sum;
        end
    end

endmodule*/


// accumulator.v: 51-bit 累加器 (内含移位累加逻辑)
module accumulator(
    input clk, rstn, st,
    input [26:0] new_partial_sum,
    output [50:0] nout
);
    reg [50:0] total_sum;
    wire [50:0] next_sum;

    se_cla adder_for_acc (
        .a(new_partial_sum), .b(total_sum << 1), .sum(next_sum)
    );

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            total_sum <= 51'b0;
        end else begin
            if (st) begin
                total_sum <= 51'b0;
            end else begin
                total_sum <= next_sum;
            end
        end
    end

    assign nout = total_sum;
endmodule