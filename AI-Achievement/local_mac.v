// local_mac.v
// 功能: 本地乘累加单元 (Local MAC) 

/*module local_mac (
    input      [95:0]      wb0,           // 权重总线0 (来自 cim_array)
    input      [95:0]      wb1,           // 权重总线1 (来自 cim_array)
    input      [7:0]       rwlb_row0,     // 行驱动信号0 (来自 rwldrv)
    input      [7:0]       rwlb_row1,     // 行驱动信号1 (来自 rwldrv)
    input                  sus,           // 有符号/无符号加法控制
    output     [14:0]      mac_out        // 15-bit 乘累加结果
);

    wire [11:0] mul_out [0:7]; // 8个乘法器的输出
    
    // 实例化8个oai_mult模块，并行执行8次乘法 
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : mult_gen
            // 假设wb0/wb1的结构为8个12bit权重拼接而成
            // rwlb_row0/1 的每一位对应一个乘法器
            oai_mult u_oai_mult (
                .weight_a(wb0[i*12 +: 12]),
                .weight_b(wb1[i*12 +: 12]),
                .input_c(rwlb_row0[i]),
                .input_d(rwlb_row1[i]),
                .result(mul_out[i])
            );
        end
    endgenerate

    // 三级加法器树 (Adder Tree) 
    wire [12:0] add_stage1_out [0:3];
    wire [13:0] add_stage2_out [0:1];
    wire [14:0] add_stage3_out;

    // Stage 1: 4个13-bit加法器
    add #(12) add_s1_0 (.sus(sus), .a(mul_out[0]), .b(mul_out[1]), .sum(add_stage1_out[0]));
    add #(12) add_s1_1 (.sus(sus), .a(mul_out[2]), .b(mul_out[3]), .sum(add_stage1_out[1]));
    add #(12) add_s1_2 (.sus(sus), .a(mul_out[4]), .b(mul_out[5]), .sum(add_stage1_out[2]));
    add #(12) add_s1_3 (.sus(sus), .a(mul_out[6]), .b(mul_out[7]), .sum(add_stage1_out[3]));

    // Stage 2: 2个14-bit加法器
    add #(13) add_s2_0 (.sus(sus), .a(add_stage1_out[0]), .b(add_stage1_out[1]), .sum(add_stage2_out[0]));
    add #(13) add_s2_1 (.sus(sus), .a(add_stage1_out[2]), .b(add_stage1_out[3]), .sum(add_stage2_out[1]));

    // Stage 3: 1个15-bit加法器
    add #(14) add_s3_0 (.sus(sus), .a(add_stage2_out[0]), .b(add_stage2_out[1]), .sum(add_stage3_out));

    assign mac_out = add_stage3_out;

endmodule*/


// local_mac.v: 局部乘累加单元
/*module local_mac(
    input sus,                  // 有符号/无符号加法控制信号 [cite: 43]
    input [95:0] wb0,           // 权重总线0 (来自cim_bank) [cite: 42]
    input [95:0] wb1,           // 权重总线1 (来自cim_bank) [cite: 42]
    input [7:0] rwlb_row0,      // 输入激活信号0 [cite: 42]
    input [7:0] rwlb_row1,      // 输入激活信号1 [cite: 42]
    output wire [14:0] mac_out  // 15-bit乘累加结果 [cite: 43]
);

    wire [11:0] mult_out [0:7]; // 8个乘法器的输出
    wire [12:0] add1_out [0:3]; // 加法树第一级输出
    wire [13:0] add2_out [0:1]; // 加法树第二级输出

    // 1. 实例化8个并行的12-bit OAI乘法器 [cite: 90]
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            oai_mult mult_inst (
                .a(wb0[i*12 +: 12]),
                .b(wb1[i*12 +: 12]),
                .c({12{rwlb_row0[i]}}), // 1-bit 输入扩展为12-bit
                .d({12{rwlb_row1[i]}}), // 1-bit 输入扩展为12-bit
                .e(mult_out[i])
            );
        end
    endgenerate

    // 2. 三级加法器树 [cite: 91]
    // 第一级: 4个13-bit加法器
    add #(.width(12)) add_stage1_0 (.sus(sus), .a(mult_out[0]), .b(mult_out[1]), .sum(add1_out[0]));
    add #(.width(12)) add_stage1_1 (.sus(sus), .a(mult_out[2]), .b(mult_out[3]), .sum(add1_out[1]));
    add #(.width(12)) add_stage1_2 (.sus(sus), .a(mult_out[4]), .b(mult_out[5]), .sum(add1_out[2]));
    add #(.width(12)) add_stage1_3 (.sus(sus), .a(mult_out[6]), .b(mult_out[7]), .sum(add1_out[3]));

    // 第二级: 2个14-bit加法器
    add #(.width(13)) add_stage2_0 (.sus(sus), .a(add1_out[0]), .b(add1_out[1]), .sum(add2_out[0]));
    add #(.width(13)) add_stage2_1 (.sus(sus), .a(add1_out[2]), .b(add1_out[3]), .sum(add2_out[1]));

    // 第三级: 1个15-bit加法器
    add #(.width(14)) add_stage3_0 (.sus(sus), .a(add2_out[0]), .b(add2_out[1]), .sum(mac_out));

endmodule*/

// local_mac.v: 局部乘累加单元 (已集成Ping-Pong选择逻辑)
/*module local_mac(
    // 控制信号
    input sus,
    input cima,                 // **新增**: 用于在内部选择数据源

    // 来自两个Bank的数据输入
    input [95:0] nW0,           // 来自 Bank 0 的反相权重 (~W)
    input [95:0] nW1,           // 来自 Bank 1 的反相权重 (~W)
    input [7:0] X0,             // 来自 rwldrv 的激活输入 (对应 Bank 0)
    input [7:0] X1,             // 来自 rwldrv 的激活输入 (对应 Bank 1)
    
    // 输出
    output wire [14:0] mac_out
);

    // 内部连线，用于存放被选中的数据
    wire [95:0] selected_nW;
    wire [7:0]  selected_X;

    wire [11:0] mult_out [0:7];
    wire [12:0] add1_out [0:3];
    wire [13:0] add2_out [0:1];
    
    // =================================================================
    // 步骤 1: 内部多路选择器 (MUX)
    // 根据 cima 信号选择当前有效的数据源
    // =================================================================
    assign selected_nW = cima ? nW1 : nW0;
    assign selected_X  = cima ? X1 : X0;

    // =================================================================
    // 步骤 2: OAI 乘法器阵列
    // 使用被选中的数据 (selected_nW 和 selected_X) 进行计算
    // =================================================================
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : oai_array
            oai_mult mult_inst (
                .a({12{selected_X[i]}}),    // a => 输入 X
                .b(12'hFFF),                // b => 固定为 1
                .c(selected_nW[i*12+:12]),  // c => 输入 ~W
                .d(12'h000),                // d => 固定为 0
                .e(mult_out[i])
            );
        end
    endgenerate
    
    // =================================================================
    // 步骤 3: 三级加法器树 (逻辑不变)
    // =================================================================
    add #(.width(12)) add_stage1_0 (.sus(sus), .a(mult_out[0]), .b(mult_out[1]), .sum(add1_out[0]));
    add #(.width(12)) add_stage1_1 (.sus(sus), .a(mult_out[2]), .b(mult_out[3]), .sum(add1_out[1]));
    add #(.width(12)) add_stage1_2 (.sus(sus), .a(mult_out[4]), .b(mult_out[5]), .sum(add1_out[2]));
    add #(.width(12)) add_stage1_3 (.sus(sus), .a(mult_out[6]), .b(mult_out[7]), .sum(add1_out[3]));

    add #(.width(13)) add_stage2_0 (.sus(sus), .a(add1_out[0]), .b(add1_out[1]), .sum(add2_out[0]));
    add #(.width(13)) add_stage2_1 (.sus(sus), .a(add1_out[2]), .b(add1_out[3]), .sum(add2_out[1]));

    add #(.width(14)) add_stage3_0 (.sus(sus), .a(add2_out[0]), .b(add2_out[1]), .sum(mac_out));

endmodule*/


// local_mac.v: 局部乘累加单元 (最终版 - 注释更新)
module local_mac(
    input sus,
    input [95:0] nW0,           // 来自 Bank 0 的 ~W
    input [95:0] nW1,           // 来自 Bank 1 的 ~W
    input [7:0] nX0,            // 来自 rwldrv 的 ~X (对应 Bank 0)
    input [7:0] nX1,            // 来自 rwldrv 的 ~X (对应 Bank 1, 含掩码)
    output wire [14:0] mac_out
);
    
    wire [11:0] mult_out [0:7];
    wire [12:0] add1_out [0:3];
    wire [13:0] add2_out [0:1];
    
    // OAI 阵列: 通过输入掩码, OAI门等效于对活动路径的输入执行 NOR(~W, ~X), 结果为 W & X
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : oai_array
            oai_mult mult_inst (
                .weight_a(nW0[i*12+:12]),        // a => ~W from bank 0
                .weight_b(nW1[i*12+:12]),        // b => ~W from bank 1
                .input_c({12{nX0[i]}}),         // c => ~X from rwldrv path 0
                .input_d({12{nX1[i]}}),         // d => ~X from rwldrv path 1
                .result(mult_out[i])           // 输出 e = W & X
            );
        end
    endgenerate
    
    // 三级加法器树
    add #(.width(12)) add_stage1_0 (.sus(sus), .a(mult_out[0]), .b(mult_out[1]), .sum(add1_out[0]));
    add #(.width(12)) add_stage1_1 (.sus(sus), .a(mult_out[2]), .b(mult_out[3]), .sum(add1_out[1]));
    add #(.width(12)) add_stage1_2 (.sus(sus), .a(mult_out[4]), .b(mult_out[5]), .sum(add1_out[2]));
    add #(.width(12)) add_stage1_3 (.sus(sus), .a(mult_out[6]), .b(mult_out[7]), .sum(add1_out[3]));

    add #(.width(13)) add_stage2_0 (.sus(sus), .a(add1_out[0]), .b(add1_out[1]), .sum(add2_out[0]));
    add #(.width(13)) add_stage2_1 (.sus(sus), .a(add1_out[2]), .b(add1_out[3]), .sum(add2_out[1]));

    add #(.width(14)) add_stage3_0 (.sus(sus), .a(add2_out[0]), .b(add2_out[1]), .sum(mac_out));

endmodule