// global_io.v
// 功能: 全局输入输出模块, 负责处理局部MAC结果并驱动累加器 

/*module global_io (
    input                   clk,
    input                   rstn,
    input                   acm_en, // Accumulator enable
    input                   st,
    input                   wwidth,   // 权重位宽控制: 0 for 12b, 1 for 24b
    input      [14:0]       macout_a, // 局部MAC输出a
    input      [14:0]       macout_b, // 局部MAC输出b
    output     [50:0]       nout      // 送往顶层的最终结果
);

    wire [26:0] adder_in_a;
    wire [26:0] adder_in_b;
    wire [27:0] adder_out;
    
    // 当处理24位权重时(wwidth=1)，macout_b代表高12位的结果，需要移位
    // 否则，它可能被用作其他用途或被忽略，这里简单置零
    assign adder_in_a = {12'b0, macout_a};
    assign adder_in_b = wwidth ? {macout_b, 12'b0} : 27'b0; // 对macout_b进行移位 

    // 使用一个27-bit的add模块相加 
    add #(27) final_adder (
        .sus(1'b1), // 有符号加法
        .a(adder_in_a),
        .b(adder_in_b),
        .sum(adder_out)
    );

    // 实例化累加器 
    accumulator u_accumulator (
        .clk(clk),
        .rstn(rstn),
        .st(st),
        .din(adder_out[26:0]),
        .nout(nout)
    );

endmodule*/


// global_io.v: 全局输入输出模块
/*module global_io (
    input clk,
    input rstn,
    input st,
    input acm_en,
    input wwidth,
    input [14:0] macout_a,
    input [14:0] macout_b,
    output [50:0] nout
);

    wire [26:0] add_in_b_processed;
    wire [26:0] add_out;
    wire [50:0] acc_in;
    wire [50:0] acc_out_reg;

    // 对macout_b进行移位和逻辑运算 [cite: 100]
    // 这里的具体处理逻辑在项目文档中未详细说明，我们假设一个简单的移位操作
    // 例如，根据权重位宽wwidth进行不同位数的移位
    assign add_in_b_processed = wwidth ? {macout_b, 12'b0} : {macout_b, 12'b0};

    // 使用一个27-bit的add模块相加 [cite: 101]
    add #(.width(27)) final_adder (
        .sus(1'b1), // 假设为有符号
        .a({12'b0, macout_a}), // 符号扩展
        .b(add_in_b_processed),
        .sum(add_out)
    );

    // 实例化 se_cla 以执行核心的加法操作 [cite: 108]
    // accumulator内部的nout_1就是移位后的前一周期结果
    // 此处需要获取accumulator的内部状态，我们简化模型，直接连接
    // 此处的连接逻辑根据文档描述较为复杂，为构建完整模块，我们做如下合理假设：
    // accumulator的输入是当前周期的计算结果和上一周期的累加结果之和
    accumulator acc_inst (
        .clk(clk),
        .rstn(rstn),
        .st(st),
        .din(acc_in), // 输入给累加器的值
        .nout(nout)   // 最终输出 [cite: 34]
    );

    // accumulator的输入是当前加法结果与上周期累加结果(已在acc内部移位)的和
    se_cla adder_for_acc (
        .a(add_out),
        .b(acc_inst.nout_1), // 连接到累加器内部的移位寄存器
        .sum(acc_in)
    );

endmodule*/

// global_io.v: 全局输入输出模块
// 职责: 合并来自低位和高位MAC的计算结果
module global_io (
    input wwidth,
    input [14:0] macout_low,  // 来自低12位权重的MAC结果
    input [14:0] macout_high, // 来自高12位权重的MAC结果
    output [26:0] partial_sum_out
);
    wire [26:0] high_val;
    wire [27:0] combined_sum;
    
    assign high_val = (wwidth == 1'b1) ? {macout_high, 12'b0} : 27'b0;

    add #(.width(27)) final_adder (
        .sus(1'b1), .a({12'h0, macout_low}), .b(high_val), .sum(combined_sum)
    );

    assign partial_sum_out = combined_sum[26:0];
endmodule