// top.v
// 功能: 系统的顶层模块, 连接并协调所有子模块 

/*module top (
    input      [23:0]       D,        // 写入存储器的数据 
    input                   clk,      // 时钟信号 
    input                   rstn,     // 复位信号 
    input                   cima,     // 控制信号，用于bank选择和ping-pong操作 
    input                   acm_en,   // 控制信号，累加器使能 
    input      [7:0]        WA,       // 存储器写地址 
    input                   inwidth,  // 输入位宽配置 
    input                   wwidth,   // 权重位宽配置 
    input                   start,    // 启动计算信号
    input      [95:0]       xin0,     // 输入的计算数据向量 
    output     [50:0]       nout,     // 最终计算结果 
    output                  st        // 累加器状态信号 
);

    wire [23:0] d_to_array;
    wire [7:0]  wa0_to_array;
    wire [7:0]  wa1_to_array;

    wire [95:0] wb0_from_array;
    wire [95:0] wb1_from_array;

    // 实例化存储阵列控制器 
    cim_array_ctrl u_cim_array_ctrl (
        .cima(cima),
        .D(D),
        .WA(WA),
        .D1(d_to_array),
        .WA0(wa0_to_array),
        .WA1(wa1_to_array)
    );

    // 实例化存储阵列 
    cim_array u_cim_array (
        .clk(clk),
        .WE(start), // 简单地使用start作为写使能，实际设计可能更复杂
        .D(d_to_array),
        .WA0(wa0_to_array),
        .WA1(wa1_to_array),
        .wb0(wb0_from_array),
        .wb1(wb1_from_array)
    );

    // 实例化数字逻辑电路 
    digital_circuit u_digital_circuit (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .inwidth(inwidth),
        .wwidth(wwidth),
        .cima(cima),
        .acm_en(acm_en),
        .xin(xin0),
        .wb0(wb0_from_array),
        .wb1(wb1_from_array),
        .nout(nout),
        .st(st)
    );

endmodule*/


// top.v: 系统顶层模块
/*module top(
    input clk, rstn,
    input start,
    input cima, acm_en,
    input inwidth, wwidth,
    input [7:0] WA,
    input [23:0] D,
    input [191:0] xin0, // 输入激活向量 [cite: 28]
    output [50:0] nout, // 最终计算结果 [cite: 28]
    output wire st      // 累加器状态信号 [cite: 28]
);

    wire [7:0] wa0, wa1;
    wire [95:0] wb0_a, wb0_b, wb1_a, wb1_b;

    // 1. 存算阵列控制器
    cim_array_ctrl array_ctrl_inst (
        .cima(cima), .WA(WA), .D(D),
        .WA0(wa0), .WA1(wa1), .D1() // D1 is broadcast to cim_array, not used here
    );

    // 2. 存算阵列 (包含两个bank)
    cim_array array_inst (
        .clk(clk), .WA0(wa0), .WA1(wa1), .D(D),
        .wb0_a(wb0_a), .wb0_b(wb0_b),
        .wb1_a(wb1_a), .wb1_b(wb1_b)
    );
    
    // 3. 数字逻辑电路
    digital_circuit digital_inst (
        .clk(clk), .rstn(rstn), .start(start),
        .inwidth(inwidth), .wwidth(wwidth), .cima(cima), .acm_en(acm_en),
        .xin0(xin0),
        .wb0_a(wb0_a), .wb0_b(wb0_b),
        .wb1_a(wb1_a), .wb1_b(wb1_b),
        .nout(nout),
        .st(st)
    );

endmodule*/




// top.v: 系统顶层模块
module top(
    input clk, rstn,
    input start,
    input cima,
    input inwidth, wwidth,
    input [7:0] WA,
    input [23:0] D,
    input [191:0] xin0,
    output [50:0] nout,
    output wire st
);
    wire [7:0] wa0, wa1;
    wire [95:0] nW0_low, nW0_high, nW1_low, nW1_high;

    cim_array_ctrl array_ctrl_inst (
        .cima(cima), .WA(WA), .WA0(wa0), .WA1(wa1)
    );

    cim_array array_inst (
        .clk(clk), .WA0(wa0), .WA1(wa1), .D(D),
        .nW0_low(nW0_low), .nW0_high(nW0_high),
        .nW1_low(nW1_low), .nW1_high(nW1_high)
    );
    
    digital_circuit digital_inst (
        .clk(clk), .rstn(rstn), .start(start),
        .inwidth(inwidth), .wwidth(wwidth), .cima(cima),
        .xin0(xin0),
        .nW0_low(nW0_low), .nW0_high(nW0_high),
        .nW1_low(nW1_low), .nW1_high(nW1_high),
        .nout(nout),
        .st(st)
    );
endmodule