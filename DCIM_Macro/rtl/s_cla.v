// 最终的、高性能的24位分块先行进位加法器 (s_cla) - 完全展开版本
module s_cla(
    input [23:0] a,
    input [23:0] b,
    input cin,
    output [23:0] sum
);

    // --- 信号定义 ---
    wire [23:0] g, p;
    wire [5:0]  bg, bp;
    wire [6:0]  c_block;
    wire [24:0] c; // 最终的逐位进位

    // --- 1. 计算每一位的 g 和 p ---
    assign g = a & b;
    assign p = a ^ b;

    // --- 2. 计算每个4-bit块的 bg 和 bp ---
    assign bg[0] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);
    assign bp[0] = p[3] & p[2] & p[1] & p[0];
    assign bg[1] = g[7] | (p[7] & g[6]) | (p[7] & p[6] & g[5]) | (p[7] & p[6] & p[5] & g[4]);
    assign bp[1] = p[7] & p[6] & p[5] & p[4];
    assign bg[2] = g[11] | (p[11] & g[10]) | (p[11] & p[10] & g[9]) | (p[11] & p[10] & p[9] & g[8]);
    assign bp[2] = p[11] & p[10] & p[9] & p[8];
    assign bg[3] = g[15] | (p[15] & g[14]) | (p[15] & p[14] & g[13]) | (p[15] & p[14] & p[13] & g[12]);
    assign bp[3] = p[15] & p[14] & p[13] & p[12];
    assign bg[4] = g[19] | (p[19] & g[18]) | (p[19] & p[18] & g[17]) | (p[19] & p[18] & p[17] & g[16]);
    assign bp[4] = p[19] & p[18] & p[17] & p[16];
    assign bg[5] = g[23] | (p[23] & g[22]) | (p[23] & p[22] & g[21]) | (p[23] & p[22] & p[21] & g[20]);
    assign bp[5] = p[23] & p[22] & p[21] & p[20];

    // --- 3. 计算块间进位 ---
    assign c_block[0] = cin;
    assign c_block[1] = bg[0] | (bp[0] & c_block[0]);
    assign c_block[2] = bg[1] | (bp[1] & c_block[1]);
    assign c_block[3] = bg[2] | (bp[2] & c_block[2]);
    assign c_block[4] = bg[3] | (bp[3] & c_block[3]);
    assign c_block[5] = bg[4] | (bp[4] & c_block[4]);
    assign c_block[6] = bg[5] | (bp[5] & c_block[5]);

    // --- 4. 计算最终的逐位进位 c[24:0] ---
    assign c[0] = c_block[0];
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & c[1]);
    assign c[3] = g[2] | (p[2] & c[2]);
    assign c[4] = c_block[1];
    assign c[5] = g[4] | (p[4] & c[4]);
    assign c[6] = g[5] | (p[5] & c[5]);
    assign c[7] = g[6] | (p[6] & c[6]);
    assign c[8] = c_block[2];
    assign c[9] = g[8] | (p[8] & c[8]);
    assign c[10] = g[9] | (p[9] & c[9]);
    assign c[11] = g[10] | (p[10] & c[10]);
    assign c[12] = c_block[3];
    assign c[13] = g[12] | (p[12] & c[12]);
    assign c[14] = g[13] | (p[13] & c[13]);
    assign c[15] = g[14] | (p[14] & c[14]);
    assign c[16] = c_block[4];
    assign c[17] = g[16] | (p[16] & c[16]);
    assign c[18] = g[17] | (p[17] & c[17]);
    assign c[19] = g[18] | (p[18] & c[18]);
    assign c[20] = c_block[5];
    assign c[21] = g[20] | (p[20] & c[20]);
    assign c[22] = g[21] | (p[21] & c[21]);
    assign c[23] = g[22] | (p[22] & c[22]);
    assign c[24] = c_block[6]; // Final carry-out

    // --- 5. 计算最终的和 (sum) ---
    assign sum = p ^ c[23:0];

endmodule