module rwldrv(
    input [191:0] xin0,       // 输入数据向量
    input [5:0] sel,          // 选择信号
    input cima,               // 片选信号
    input inwidth,            // 新增：输入位宽选择
    output reg [7:0] rwlb_row0, // 行驱动信号0
    output reg [7:0] rwlb_row1  // 行驱动信号1
);

    always @(*) begin : RWLDRV_LOGIC
        reg [7:0] selected_bits;
        integer i;
        reg [5:0] bit_to_select;

        // 根据sel和inwidth计算出从MSB开始的正确位索引
        if (inwidth) begin // 24-bit 模式
            bit_to_select = 23 - sel;
        end else begin // 12-bit 模式
            bit_to_select = 11 - sel;
        end

        // 遍历8个数据项
        for (i = 0; i < 8; i = i + 1) begin
            // 从第i个24-bit数据中，提取出正确的位
            selected_bits[i] = xin0[(i*24) + bit_to_select];
        end

        // 根据cima信号，将取反后的结果送到正确的bank，并屏蔽另一个
        if (cima == 1'b0) begin
            // 选择bank0，激活rwlb_row0，屏蔽rwlb_row1
            rwlb_row0 = ~selected_bits;
            rwlb_row1 = 8'hFF; // 强制为全1以屏蔽
        end else begin
            // 选择bank1，屏蔽rwlb_row0，激活rwlb_row1
            rwlb_row0 = 8'hFF; // 强制为全1以屏蔽
            rwlb_row1 = ~selected_bits;
        end
    end

endmodule