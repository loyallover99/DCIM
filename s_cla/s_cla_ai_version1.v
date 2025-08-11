// s_cla.v
// 功能: 24-bit 有符号先行进位加法器 (Signed Carry-Lookahead Adder) 

/*module s_cla (
    input      [23:0]      a,
    input      [23:0]      b,
    input                  cin, // 输入进位
    output     [23:0]      sum,
    output                 cout // 输出进位
);

    wire [23:0] p; // Propagate
    wire [23:0] g; // Generate
    wire [24:0] c; // Carry

    assign p = a ^ b;
    assign g = a & b;

    assign c[0] = cin;

    genvar i;
    generate
        for (i = 0; i < 24; i = i + 1) begin : cla_logic
            assign c[i+1] = g[i] | (p[i] & c[i]);
        end
    endgenerate

    assign sum = p ^ c[23:0];
    assign cout = c[24];

endmodule*/


// s_cla.v: 24-bit 有符号先行进位加法器 (使用循环结构实现)
/*module s_cla (
    input [23:0] a,
    input [23:0] b,
    input cin,
    output [23:0] sum
);
    wire [23:0] p, g;
    wire [24:0] c;

    genvar i;
    generate
        for (i = 0; i < 24; i = i + 1) begin : bit_level_pg
            assign p[i] = a[i] ^ b[i];
            assign g[i] = a[i] & b[i];
        end
    endgenerate

    // 为保证功能正确性和可综合性，此处保留最直接的行为级描述
    // 综合工具会自动将其优化为高性能的先行进位加法器
    wire [24:0] full_sum;
    assign full_sum = $signed(a) + $signed(b) + cin;
    assign sum = full_sum[23:0];
    
endmodule*/

// s_cla.v: 24-bit 有符号先行进位加法器 (使用循环结构实现)
module s_cla (
    input [23:0] a,
    input [23:0] b,
    input cin,
    output [23:0] sum
);
    // 内部信号定义
    wire [23:0] p, g;       // 位传递(propagate)和位产生(generate)信号
    wire [5:0] P, G;        // 组传递和组产生信号 (每组4位)
    wire [24:0] c;          // 进位信号

    // =================================================================
    // 步骤 1: 使用 generate-for 循环生成所有位的 p 和 g 信号
    // =================================================================
    genvar i;
    generate
        for (i = 0; i < 24; i = i + 1) begin : bit_level_pg
            assign p[i] = a[i] ^ b[i];
            assign g[i] = a[i] & b[i];
        end
    endgenerate

    // =================================================================
    // 步骤 2: 使用 generate-for 循环生成6个4位小组的 P 和 G 信号
    // =================================================================
    genvar j;
    generate
        for (j = 0; j < 6; j = j + 1) begin : group_level_pg
            localparam base = j * 4;
            assign G[j] = g[base+3] | (p[base+3] & g[base+2]) | (p[base+3] & p[base+2] & g[base+1]) | (p[base+3] & p[base+2] & p[base+1] & g[base+0]);
            assign P[j] = p[base+3] & p[base+2] & p[base+1] & p[base+0];
        end
    endgenerate

    // =================================================================
    // 步骤 3: 并行计算组间进位 (Lookahead Logic)
    // =================================================================
    assign c[0] = cin;
    assign c[4] = G[0] | (P[0] & c[0]);
    assign c[8] = G[1] | (P[1] & c[4]);
    assign c[12] = G[2] | (P[2] & c[8]);
    assign c[16] = G[3] | (P[3] & c[12]);
    assign c[20] = G[4] | (P[4] & c[16]);
    
    // 并行计算组内进位
    genvar k;
    generate
        for (k = 0; k < 6; k = k + 1) begin : internal_carries
            localparam base = k * 4;
            assign c[base+1] = g[base+0] | (p[base+0] & c[base]);
            assign c[base+2] = g[base+1] | (p[base+1] & g[base+0]) | (p[base+1] & p[base+0] & c[base]);
            assign c[base+3] = g[base+2] | (p[base+2] & g[base+1]) | (p[base+2] & p[base+1] & g[base+0]) | (p[base+2] & p[base+1] & p[base+0] & c[base]);
        end
    endgenerate


    // =================================================================
    // 步骤 4: 使用 generate-for 循环生成最终的和
    // =================================================================
    genvar m;
    generate
        for (m = 0; m < 24; m = m + 1) begin : final_sum
            assign sum[m] = p[m] ^ c[m];
        end
    endgenerate

endmodule