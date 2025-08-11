module cim_bank(
    input [23:0] D,           // 写入数据
    input [7:0] WA,           // 写地址 (one-hot编码)
    output [95:0] wb_a,       // 权重输出A
    output [95:0] wb_b        // 权重输出B
);

    // 8x24-bit存储器数组
    reg [23:0] mem [7:0];

    // Initialize memory
    integer i;
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            mem[i] = 0;
        end
    end

    // 写操作 - 根据one-hot地址写入数据
    always @(*) begin
        case (WA)
            8'b00000001: mem[0] = D;
            8'b00000010: mem[1] = D;
            8'b00000100: mem[2] = D;
            8'b00001000: mem[3] = D;
            8'b00010000: mem[4] = D;
            8'b00100000: mem[5] = D;
            8'b01000000: mem[6] = D;
            8'b10000000: mem[7] = D;
            default: ; // 无操作
        endcase
    end

    // 读操作 - 持续输出所有存储单元内容的反相值，以实现AND逻辑
    // 将每个24-bit存储单元的低12位拼接并取反，作为 wb_a
    assign wb_a = ~{mem[7][11:0], mem[6][11:0], mem[5][11:0], mem[4][11:0],
                    mem[3][11:0], mem[2][11:0], mem[1][11:0], mem[0][11:0]};

    // 将每个24-bit存储单元的高12位拼接并取反，作为 wb_b
    assign wb_b = ~{mem[7][23:12], mem[6][23:12], mem[5][23:12], mem[4][23:12],
                    mem[3][23:12], mem[2][23:12], mem[1][23:12], mem[0][23:12]};

endmodule