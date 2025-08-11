// cim_array_ctrl.v
// 功能: CIM 存储阵列的控制器 

/*module cim_array_ctrl (
    input                   cima, // 片选信号, 用于选择两个cim_bank中的一个 
    input      [23:0]       D,    // 输入的数据
    input      [7:0]        WA,   // 输入的地址
    output     [23:0]       D1,   // 输出给cim_array的数据
    output     [7:0]        WA0,  // 输出给bank0的地址
    output     [7:0]        WA1   // 输出给bank1的地址
);

    // 将D直接传递给D1 
    assign D1 = D;

    // 根据cima信号, 将输入的WA路由到WA0或WA1 
    assign WA0 = cima ? 8'b0 : WA;
    assign WA1 = cima ? WA : 8'b0;

endmodule*/


// cim_array_ctrl.v: CIM 存储阵列的控制器
module cim_array_ctrl(
    input cima,
    input [7:0] WA,
    output [7:0] WA0,
    output [7:0] WA1
);
    assign WA0 = (cima == 1'b0) ? WA : 8'b0;
    assign WA1 = (cima == 1'b1) ? WA : 8'b0;
endmodule