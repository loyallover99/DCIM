// cim_array.v
// 功能: CIM 存储阵列, 由两个cim_bank组成 

/*module cim_array (
    input               clk,
    input               WE,
    input      [23:0]   D,
    input      [7:0]    WA0,
    input      [7:0]    WA1,
    output     [95:0]   wb0, // 来自bank0的权重
    output     [95:0]   wb1  // 来自bank1的权重
);

    wire [95:0] wb0_a, wb0_b;
    wire [95:0] wb1_a, wb1_b;

    // 实例化两个cim_bank 
    cim_bank u_bank0 (
        .clk(clk),
        .WA(WA0),
        .D(D),
        .WE(WE),
        .WB_a(wb0_a),
        .WB_b(wb0_b)
    );

    cim_bank u_bank1 (
        .clk(clk),
        .WA(WA1),
        .D(D),
        .WE(WE),
        .WB_a(wb1_a),
        .WB_b(wb1_b)
    );
    
    // 假设local_mac需要两个96位的权重总线
    // 这里将每个bank的两个输出简单拼接
    assign wb0 = {wb0_b, wb0_a};
    assign wb1 = {wb1_b, wb1_a};

endmodule*/

// cim_array.v: CIM 存储阵列, 由两个 cim_bank 组成
/*module cim_array(
    input clk,
    input [7:0] WA0,      // bank 0 写地址
    input [7:0] WA1,      // bank 1 写地址
    input [23:0] D,       // 写入数据
    output [95:0] wb0_a,  // bank 0 输出
    output [95:0] wb0_b,
    output [95:0] wb1_a,  // bank 1 输出
    output [95:0] wb1_b
);

    // 实例化两个cim_bank模块 [cite: 66]
    cim_bank bank0 (
        .clk(clk),
        .WA(WA0),
        .D(D),
        .wb_a(wb0_a),
        .wb_b(wb0_b)
    );

    cim_bank bank1 (
        .clk(clk),
        .WA(WA1),
        .D(D),
        .wb_a(wb1_a),
        .wb_b(wb1_b)
    );

endmodule*/


// cim_array.v: CIM 存储阵列, 由两个 cim_bank 组成
module cim_array(
    input clk,
    input [7:0] WA0,
    input [7:0] WA1,
    input [23:0] D,
    output [95:0] nW0_low, nW0_high,
    output [95:0] nW1_low, nW1_high
);
    cim_bank bank0 (
        .clk(clk), .WA(WA0), .D(D),
        .nW_low(nW0_low), .nW_high(nW0_high)
    );

    cim_bank bank1 (
        .clk(clk), .WA(WA1), .D(D),
        .nW_low(nW1_low), .nW_high(nW1_high)
    );
endmodule