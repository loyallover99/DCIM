// se_cla.v
// 功能: 符号扩展先行进位加法器 (Sign-Extend Carry-Lookahead Adder) 
//       将一个27-bit数和一个51-bit数相加 

/*module se_cla (
    input      [26:0]      a, // 27-bit 输入
    input      [50:0]      b, // 51-bit 输入
    output     [50:0]      sum
);
    
    wire [50:0] extended_a;
    wire [27:0] low_sum;
    wire [23:0] high_sum;
    wire        carry_out_low;

    // 对27-bit输入a进行符号位扩展到51位 
    assign extended_a = {{24{a[26]}}, a};

    // 使用add模块计算低27位 
    // 注意：这里的add模块需要处理27位输入，输出28位（含进位）
    add #(27) low_adder (
        .sus(1'b0), // 无符号加法，因为符号扩展已完成
        .a(extended_a[26:0]),
        .b(b[26:0]),
        .sum(low_sum)
    );
    assign carry_out_low = low_sum[27];

    // 使用s_cla模块计算高24位 
    s_cla high_adder (
        .a(extended_a[50:27]),
        .b(b[50:27]),
        .cin(carry_out_low),
        .sum(high_sum)
        // .cout is not used here
    );

    // 拼接高位和低位结果 
    assign sum = {high_sum, low_sum[26:0]};

endmodule*/

// se_cla.v: 符号扩展先行进位加法器
module se_cla (
    input [26:0] a,         // 27-bit 输入 
    input [50:0] b,         // 51-bit 输入 
    output [50:0] sum
);
    wire [50:0] a_extended;
    wire [26:0] low_sum;
    wire low_carry;
    wire [23:0] high_sum;

    // 1. 对27-bit输入a进行符号位扩展 [cite: 112]
    assign a_extended = {{24{a[26]}}, a};

    // 2. 使用一个add模块计算低27位，并产生进位 [cite: 113]
    add #(.width(27)) low_adder (
        .sus(1'b1), // 有符号
        .a(a[26:0]),
        .b(b[26:0]),
        .sum({low_carry, low_sum})
    );
    
    // 3. 使用一个s_cla模块计算高24位 [cite: 114]
    s_cla high_adder (
        .a(a_extended[50:27]),
        .b(b[50:27]),
        .cin(low_carry),
        .sum(high_sum)
    );

    // 4. 拼接高位和低位结果 [cite: 115]
    assign sum = {high_sum, low_sum};
endmodule