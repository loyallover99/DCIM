module add #(
    parameter width = 12      // 默认位宽为12
)(
    input [width-1:0] a,      // 输入a
    input [width-1:0] b,      // 输入b
    input sus,                // 有符号/无符号控制
    output wire [width:0] sum // 加法结果
);

    // 有符号加法：进行符号位扩展
    wire [width:0] a_signed, b_signed;
    
    // 根据sus信号决定是否进行符号扩展
    assign a_signed = sus ? {a[width-1], a} : {1'b0, a};
    assign b_signed = sus ? {b[width-1], b} : {1'b0, b};
    
    // 执行加法
    assign sum = a_signed + b_signed;

endmodule 