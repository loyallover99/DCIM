// oai_mult.v
// 功能: 一个定制的12-bit OAI (OR-AND-Invert) 乘法器 
// 逻辑: 实现 e = ~((a|c) & (b|d)) 的按位操作 
//       这里的a, b来自存储器(权重), c, d来自输入(激活) 

module oai_mult (
    input      [11:0]       weight_a, // 来自存储器的权重 a
    input      [11:0]       weight_b, // 来自存储器的权重 b
    input      [11:0]       input_c,  // 来自输入的激活 c
    input      [11:0]       input_d,  // 来自输入的激活 d
    output     [11:0]       result    // 位乘法结果 e
);

    // 将1位的输入c和d扩展到12位
    wire [11:0] extended_c = {12{input_c}};
    wire [11:0] extended_d = {12{input_d}};

    // 执行12位并行的 OAI 逻辑运算 
    assign result = ~((weight_a | extended_c) & (weight_b | extended_d));

endmodule