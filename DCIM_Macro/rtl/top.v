// top.v (Corrected Architecture)
`timescale 1ns / 1ps

module top(
    input [23:0] D,           // 写入存储器的数据
    input clk, rstn,          // 时钟和复位信号
    input cima,               // 片选信号，选择两个cim_bank中的一个
    input acm_en,             // 累加器使能
    input [7:0] WA,           // 存储器写地址
    input inwidth,            // 输入位宽选择 (12-bit 或 24-bit)
    input wwidth,             // 权重位宽选择 (12-bit 或 24-bit)
    input start,              // 开始计算信号
    input [191:0] xin0,       // 输入的计算数据向量
    output [50:0] nout,       // 最终计算结果
    output wire st            // 累加器状态信号
);

    // --- 内部信号定义 ---
    // 控制与地址信号
    wire [23:0] D1;
    wire [7:0] WA0, WA1;
    wire [5:0] sel;
    wire sus;

    // 存储阵列输出
    wire [95:0] wb0_a, wb0_b; // bank0 权重输出 (a: low 12, b: high 12)
    wire [95:0] wb1_a, wb1_b; // bank1 权重输出

    // MUXed 权重: 根据cima选择要计算的bank
    wire [95:0] active_wb_a, active_wb_b;

    // 行驱动信号
    wire [7:0] rwlb_row0, rwlb_row1;

    // MAC输出
    wire [14:0] mac_out_low, mac_out_high;

    // --- 模块实例化 ---

    // 1. 写地址控制器
    cim_array_ctrl ctrl_inst(
        .D(D), .WA(WA), .cima(cima),
        .D1(D1), .WA0(WA0), .WA1(WA1)
    );

    // 2. 存储阵列 (包含两个bank)
    cim_array array_inst(
        .D(D1), .WA0(WA0), .WA1(WA1),
        .wb0_a(wb0_a), .wb0_b(wb0_b),
        .wb1_a(wb1_a), .wb1_b(wb1_b)
    );

    // 3. 主时序控制器
    gctrl gctrl_inst(
        .clk(clk), .rstn(rstn), .start(start), .inwidth(inwidth),
        .sel(sel), .st(st)
    );

    // 4. 行驱动生成器
    rwldrv rwldrv_inst(
        .xin0(xin0), .sel(sel), .cima(cima), .inwidth(inwidth),
        .rwlb_row0(rwlb_row0), .rwlb_row1(rwlb_row1)
    );

    // --- Ping-Pong MUX --- 
    // 根据 cima 信号选择当前要计算的 bank 的权重
    assign active_wb_a = cima ? wb1_a : wb0_a;
    assign active_wb_b = cima ? wb1_b : wb0_b;

    // --- 计算核心 --- 
    // 5. 实例化两个local_mac，一个算低12位，一个算高12位
    // mac_out_low: 使用 active_wb_a (低12位权重) 计算
    local_mac mac_low_bits_inst(
        .wb0(active_wb_a), // a=~W_low
        .wb1(active_wb_a), // b=~W_low (b端被d=1屏蔽,所以无影响)
        .rwlb_row0(rwlb_row0), // c=~X
        .rwlb_row1(rwlb_row1), // d=1 or ~X
        .sus(sus),
        .mac_out(mac_out_low)
    );

    // mac_out_high: 使用 active_wb_b (高12位权重) 计算
    local_mac mac_high_bits_inst(
        .wb0(active_wb_b), // a=~W_high
        .wb1(active_wb_b), // b=~W_high (b端被d=1屏蔽,所以无影响)
        .rwlb_row0(rwlb_row0), // c=~X
        .rwlb_row1(rwlb_row1), // d=1 or ~X
        .sus(sus),
        .mac_out(mac_out_high)
    );

    // 6. 全局IO与累加器
    global_io global_io_inst(
        .macout_a(mac_out_low),  // 低12位的结果
        .macout_b(mac_out_high), // 高12位的结果
        .clk(clk), .acm_en(acm_en), .rstn(rstn), .st(st), .wwidth(wwidth),
        .nout(nout)
    );

    // 有符号/无符号控制逻辑
    assign sus = (sel < 4) ? 1'b1 : 1'b0;

endmodule