module local_mac(
    input [95:0] wb0,         // 权重输入0
    input [95:0] wb1,         // 权重输入1
    input [7:0] rwlb_row0,    // 行驱动信号0
    input [7:0] rwlb_row1,    // 行驱动信号1
    input sus,                // 有符号/无符号控制
    output wire [14:0] mac_out // MAC输出
);

    // 8个OAI乘法器的输出
    wire [11:0] mult_out [7:0];
    
    // 实例化8个OAI乘法器
    oai_mult mult0(.a(wb0[11:0]), .b(wb1[11:0]), .c(rwlb_row0[0]), .d(rwlb_row1[0]), .e(mult_out[0]));
    oai_mult mult1(.a(wb0[23:12]), .b(wb1[23:12]), .c(rwlb_row0[1]), .d(rwlb_row1[1]), .e(mult_out[1]));
    oai_mult mult2(.a(wb0[35:24]), .b(wb1[35:24]), .c(rwlb_row0[2]), .d(rwlb_row1[2]), .e(mult_out[2]));
    oai_mult mult3(.a(wb0[47:36]), .b(wb1[47:36]), .c(rwlb_row0[3]), .d(rwlb_row1[3]), .e(mult_out[3]));
    oai_mult mult4(.a(wb0[59:48]), .b(wb1[59:48]), .c(rwlb_row0[4]), .d(rwlb_row1[4]), .e(mult_out[4]));
    oai_mult mult5(.a(wb0[71:60]), .b(wb1[71:60]), .c(rwlb_row0[5]), .d(rwlb_row1[5]), .e(mult_out[5]));
    oai_mult mult6(.a(wb0[83:72]), .b(wb1[83:72]), .c(rwlb_row0[6]), .d(rwlb_row1[6]), .e(mult_out[6]));
    oai_mult mult7(.a(wb0[95:84]), .b(wb1[95:84]), .c(rwlb_row0[7]), .d(rwlb_row1[7]), .e(mult_out[7]));

    // 三级加法器树
    // 第一级：4个加法器
    wire [12:0] add1_out [3:0];
    add #(.width(12)) add1_0(.a(mult_out[0]), .b(mult_out[1]), .sus(sus), .sum(add1_out[0]));
    add #(.width(12)) add1_1(.a(mult_out[2]), .b(mult_out[3]), .sus(sus), .sum(add1_out[1]));
    add #(.width(12)) add1_2(.a(mult_out[4]), .b(mult_out[5]), .sus(sus), .sum(add1_out[2]));
    add #(.width(12)) add1_3(.a(mult_out[6]), .b(mult_out[7]), .sus(sus), .sum(add1_out[3]));

    // 第二级：2个加法器
    wire [13:0] add2_out [1:0];
    add #(.width(13)) add2_0(.a(add1_out[0]), .b(add1_out[1]), .sus(sus), .sum(add2_out[0]));
    add #(.width(13)) add2_1(.a(add1_out[2]), .b(add1_out[3]), .sus(sus), .sum(add2_out[1]));

    // 第三级：1个加法器
    add #(.width(14)) add3_0(.a(add2_out[0]), .b(add2_out[1]), .sus(sus), .sum(mac_out));

endmodule 