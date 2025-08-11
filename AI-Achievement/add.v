//version 1.0
// add.v
// 功能: 参数化的通用加法器 
// 参数:
//   width: 加法器的位宽 
// 端口:
//   a, b: 输入操作数
//   sus: 控制信号, sus=1为有符号加法, sus=0为无符号加法 
//   sum: 加法结果

/*module add #(
    parameter width = 8
) (
    input                       sus,
    input      [width-1:0]      a,
    input      [width-1:0]      b,
    output     [width:0]        sum
);

    // 根据sus信号对输入进行符号位扩展（有符号）或补零（无符号）
    wire [width:0] extended_a = sus ? {a[width-1], a} : {1'b0, a};
    wire [width:0] extended_b = sus ? {b[width-1], b} : {1'b0, b};

    assign sum = extended_a + extended_b;

endmodule*/


//version 2.0
// add.v: 参数化的通用加法器
// 根据sus信号控制有符号(sus=1)或无符号(sus=0)加法
module add #(
    parameter width = 12 // 定义加法器的位宽 [cite: 122]
) (
    input sus, // 1'b1: 有符号加法, 1'b0: 无符号加法 [cite: 123]
    input [width-1:0] a,
    input [width-1:0] b,
    output [width:0] sum
);

    // 根据sus的值，输入被视为有符号数或无符号数进行加法操作
    // Verilog的 $signed() 系统函数可以用于类型转换
    assign sum = sus ? ($signed(a) + $signed(b)) : (a + b);

endmodule