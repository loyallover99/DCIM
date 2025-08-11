module se_cla(
    input [26:0] a,           // 27位输入
    input [50:0] b,           // 51位输入
    output [50:0] sum         // 51位输出
);

    // 对27位输入a进行符号位扩展
    wire [50:0] a_ext;
    assign a_ext = {{24{a[26]}}, a};  // 符号位扩展
    
    // 低27位加法
    wire [26:0] sum_low;
    wire carry_out;
    
    add #(.width(27)) add_low(
        .a(a),
        .b(b[26:0]),
        .sus(1'b0),  // 无符号加法
        .sum({carry_out, sum_low})
    );
    
    // 高24位加法（考虑进位）
    wire [23:0] sum_high;
    
    s_cla s_cla_inst(
        .a(a_ext[50:27]),
        .b(b[50:27]),
        .cin(carry_out),
        .sum(sum_high)
    );
    
    // 拼接结果
    assign sum = {sum_high, sum_low};

endmodule 