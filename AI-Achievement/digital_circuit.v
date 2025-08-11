// digital_circuit.v
// 功能: 包装所有核心数字逻辑 

/*module digital_circuit (
    input                   clk,
    input                   rstn,
    input                   start,
    input                   inwidth,
    input                   wwidth,
    input                   cima,
    input                   acm_en,
    input      [95:0]       xin,
    input      [95:0]       wb0,
    input      [95:0]       wb1,
    output     [50:0]       nout,
    output                  st
);
    
    wire [5:0]  sel;
    wire [7:0]  rwlb_row0;
    wire [7:0]  rwlb_row1;
    wire [14:0] macout_a;
    wire [14:0] macout_b;

    // 实例化全局控制器
    gctrl u_gctrl (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .inwidth(inwidth),
        .sel(sel),
        .st(st)
    );

    // 实例化读字线驱动
    rwldrv u_rwldrv (
        .sel(sel),
        .xin(xin),
        .cima(cima),
        .rwlb_row0(rwlb_row0),
        .rwlb_row1(rwlb_row1)
    );

    // 实例化两个local_mac以生成global_io所需的两个输入
    // 这是根据global_io的接口和描述所做的设计决策
    local_mac u_lmac_a (
        .wb0(wb0),
        .wb1(wb1), // wb1可能不被此实例使用，取决于OAI实现
        .rwlb_row0(rwlb_row0),
        .rwlb_row1(rwlb_row1),
        .sus(1'b1), // 假设有符号
        .mac_out(macout_a)
    );

    // 第二个local_mac实例。在实际设计中，它可能处理不同的权重或数据部分。
    // 这里为满足接口要求，暂时复制第一个实例的连接。
    local_mac u_lmac_b (
        .wb0(wb0),
        .wb1(wb1),
        .rwlb_row0(rwlb_row0),
        .rwlb_row1(rwlb_row1),
        .sus(1'b1),
        .mac_out(macout_b)
    );
    
    // 实例化全局IO
    global_io u_global_io (
        .clk(clk),
        .rstn(rstn),
        .acm_en(acm_en),
        .st(st),
        .wwidth(wwidth),
        .macout_a(macout_a),
        .macout_b(macout_b),
        .nout(nout)
    );

endmodule*/

// digital_circuit.v: 包含核心数字逻辑的子模块
/*module digital_circuit(
    input clk, rstn, start,
    input inwidth, wwidth, cima, acm_en,
    input [191:0] xin0,
    input [95:0] wb0_a, wb0_b, // from bank0
    input [95:0] wb1_a, wb1_b, // from bank1
    output [50:0] nout,
    output wire st
);

    wire [5:0] sel;
    wire sus;
    wire [7:0] rwlb_row0, rwlb_row1;
    wire [14:0] mac_out0, mac_out1;

    // 1. 全局控制器
    gctrl gctrl_inst (
        .clk(clk), .rstn(rstn), .start(start), .inwidth(inwidth),
        .sel(sel), .st(st), .sus(sus)
    );

    // 2. 读字线驱动
    rwldrv rwldrv_inst (
        .cima(cima), .sel(sel), .xin(xin0),
        .rwlb_row0(rwlb_row0), .rwlb_row1(rwlb_row1)
    );

    // 3. 两个并行的 Local MAC 单元
    // 一个连接到bank0，一个连接到bank1
    local_mac lmac0 (
        .sus(sus), .wb0(wb0_a), .wb1(wb0_b),
        .rwlb_row0(rwlb_row0), .rwlb_row1(8'hFF), // rwlb_row0 用于 bank0
        .mac_out(mac_out0)
    );
    
    local_mac lmac1 (
        .sus(sus), .wb0(wb1_a), .wb1(wb1_b),
        .rwlb_row0(8'hFF), .rwlb_row1(rwlb_row1), // rwlb_row1 用于 bank1
        .mac_out(mac_out1)
    );

    // 4. 全局IO，处理两个MAC的结果
    // 根据ping-pong操作，在任一时刻只有一个MAC在计算，另一个的输入是无效的
    // 我们将两个MAC的输出送入global_io
    global_io gio_inst (
        .clk(clk), .rstn(rstn), .st(st), .acm_en(acm_en), .wwidth(wwidth),
        .macout_a(mac_out0), .macout_b(mac_out1),
        .nout(nout)
    );

endmodule*/



// digital_circuit.v: 核心数字逻辑
module digital_circuit(
    input clk, rstn, start,
    input inwidth, wwidth, cima,
    input [191:0] xin0,
    input [95:0] nW0_low, nW0_high,
    input [95:0] nW1_low, nW1_high,
    output [50:0] nout,
    output wire st
);
    wire [5:0] sel;
    wire sus;
    wire [7:0] nX0, nX1;
    wire [14:0] mac_out_low, mac_out_high;
    wire [26:0] partial_sum;

    gctrl gctrl_inst (.clk(clk), .rstn(rstn), .start(start), .inwidth(inwidth), .sel(sel), .st(st), .sus(sus));
    rwldrv rwldrv_inst (.cima(cima), .inwidth(inwidth), .sel(sel), .xin(xin0), .rwlb_row0(nX0), .rwlb_row1(nX1));

    local_mac lmac_low (
        .sus(sus), .nW0(nW0_low), .nW1(nW1_low), .nX0(nX0), .nX1(nX1), .mac_out(mac_out_low)
    );
    local_mac lmac_high (
        .sus(sus), .nW0(nW0_high), .nW1(nW1_high), .nX0(nX0), .nX1(nX1), .mac_out(mac_out_high)
    );
    
    global_io gio_inst (
        .wwidth(wwidth), .macout_low(mac_out_low), .macout_high(mac_out_high), .partial_sum_out(partial_sum)
    );

    accumulator acc_inst (
        .clk(clk), .rstn(rstn), .st(st), .new_partial_sum(partial_sum), .nout(nout)
    );
endmodule