module cim_array(
    input [23:0] D,           // 写入数据
    input [7:0] WA0, WA1,     // 写地址
    output [95:0] wb0_a, wb0_b,       // bank0权重输出
    output [95:0] wb1_a, wb1_b        // bank1权重输出
);

    // 实例化两个cim_bank
    cim_bank bank0_inst(
        .D(D),
        .WA(WA0),
        .wb_a(wb0_a),
        .wb_b(wb0_b)
    );

    cim_bank bank1_inst(
        .D(D),
        .WA(WA1),
        .wb_a(wb1_a),
        .wb_b(wb1_b)
    );

endmodule