module global_io(
    input [14:0] macout_a,    // MAC输出A
    input [14:0] macout_b,    // MAC输出B
    input clk,                // 时钟信号
    input acm_en,             // 累加器使能
    input rstn,               // 复位信号
    input st,                 // 累加器状态信号
    input wwidth,             // 权重位宽选择
    output [50:0] nout        // 最终输出
);

    // 内部信号
    wire [26:0] add_out;          // 27位加法器输出
    wire [26:0] adder_a_input;    // 加法器a端口的输入
    wire [26:0] adder_b_input;    // 加法器b端口的输入

    // 准备加法器的两个输入
    // adder_a_input 是零扩展后的 macout_a (低12位权重的结果)
    assign adder_a_input = {12'b0, macout_a};

    // adder_b_input 是移位后的 macout_b (高12位权重的结果, 仅在24b模式下有效)
    assign adder_b_input = wwidth ? {macout_b, 12'b0} : 27'b0;

    // 实例化一个27位的加法器
    add #(.width(27)) add_inst(
        .a(adder_a_input),
        .b(adder_b_input),
        .sus(1'b0),  // 无符号加法
        .sum(add_out)
    );
    
    // 扩展高位
    //assign add_out[26:16] = 11'b0;
    
    // 实例化累加器
    accumulator acc_inst(
        .a(add_out),
        .clk(clk),
        .acm_en(acm_en),
        .rstn(rstn),
        .st(st),
        .nout(nout)
    );

endmodule 