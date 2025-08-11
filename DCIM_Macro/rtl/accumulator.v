// 最终的、实例化se_cla的、电路稳定的累加器
module accumulator(
    input [26:0] a,
    input clk,
    input acm_en,
    input rstn,
    input st,
    output [50:0] nout
);

    // 内部累加寄存器
    reg [50:0] nout_1;
    
    // 模块输出直接来自寄存器
    assign nout = nout_1;

    // --- 用于计算的中间信号 ---
    wire [50:0] shifted_nout_1; // 用于存放 nout_1 << 1 的结果
    wire [50:0] sum_result;     // 加法器的输出

    // --- 组合逻辑部分 ---
    // 1. 对当前寄存器的值进行左移一位
    assign shifted_nout_1 = {nout_1[49:0], 1'b0};

    // 2. 实例化 se_cla 加法器来计算：(nout_1 << 1) + a
    se_cla se_cla_inst (
        .a(a),
        .b(shifted_nout_1),
        .sum(sum_result)
    );

    // --- 时序逻辑部分 ---
    // 在时钟边沿，用预先计算好的、稳定的加法结果来更新寄存器
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            nout_1 <= 51'b0;
        end else if (acm_en) begin
            if (st) begin
                nout_1 <= 51'b0;
            end else begin
                // 锁存稳定的加法结果
                nout_1 <= sum_result;
            end
        end
    end

endmodule