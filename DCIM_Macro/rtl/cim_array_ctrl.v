module cim_array_ctrl(
    input [23:0] D,           // 输入数据
    input [7:0] WA,           // 写地址
    input cima,               // 片选信号
    output reg [23:0] D1,     // 输出数据
    output reg [7:0] WA0,     // bank0地址
    output reg [7:0] WA1      // bank1地址
);

    // 数据直接传递
    always @(*) begin
        D1 = D;
    end

    // 地址路由逻辑
    always @(*) begin
        if (cima == 1'b0) begin
            // 选择bank0
            WA0 = WA;
            WA1 = 8'b0;  // bank1不使能
        end else begin
            // 选择bank1
            WA0 = 8'b0;  // bank0不使能
            WA1 = WA;
        end
    end

endmodule 