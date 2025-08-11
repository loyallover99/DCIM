module oai_mult(
    input [11:0] a,           // 权重输入a
    input [11:0] b,           // 权重输入b
    input c,                  // 输入位c
    input d,                  // 输入位d
    output wire [11:0] e      // 乘法结果
);

    // OAI逻辑：e = ~((a | c) & (b | d))
    // 其中c和d是1位信号，需要扩展到12位
    wire [11:0] c_ext = {12{c}};  // 将c扩展到12位
    wire [11:0] d_ext = {12{d}};  // 将d扩展到12位
    
    // 实现OAI逻辑
    assign e = ~((a | c_ext) & (b | d_ext));

endmodule 