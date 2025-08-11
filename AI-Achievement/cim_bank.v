// cim_bank.v
// 功能: 8x24-bit 的SRAM 存储体 

/*module cim_bank (
    input                   clk,
    input      [7:0]        WA,   // 存储器写地址 (one-hot) 
    input      [23:0]       D,    // 写入的数据
    input                   WE,   // 写使能
    output     [95:0]       WB_a, // 并行读出端口 a
    output     [95:0]       WB_b  // 并行读出端口 b
);

    // 包含一个8x24-bit的寄存器数组mem 
    reg [23:0] mem [0:7];

    // 通过 case 语句响应 WA (one-hot 编码)来写入数据D 
    always @(posedge clk) begin
        if (WE) begin
            case(WA)
                8'b00000001: mem[0] <= D;
                8'b00000010: mem[1] <= D;
                8'b00000100: mem[2] <= D;
                8'b00001000: mem[3] <= D;
                8'b00010000: mem[4] <= D;
                8'b00100000: mem[5] <= D;
                8'b01000000: mem[6] <= D;
                8'b10000000: mem[7] <= D;
                default:;
            endcase
        end
    end

    // 组合逻辑，将mem中的数据整理后并行读出 
    // 假设WB_a输出低4个地址的数据，WB_b输出高4个地址的数据
    // 4 words * 24 bits/word = 96 bits
    assign WB_a = {mem[3], mem[2], mem[1], mem[0]};
    assign WB_b = {mem[7], mem[6], mem[5], mem[4]};

endmodule*/

// cim_bank.v: 8x24-bit SRAM 存储体
/*module cim_bank(
    input clk,
    input [7:0] WA,      // 写地址 (one-hot 编码) [cite: 71]
    input [23:0] D,       // 写入数据 [cite: 71]
    output [95:0] wb_a,   // 并行读出权重总线A (8个12-bit权重)
    output [95:0] wb_b    // 并行读出权重总线B (8个12-bit权重)
);

    // 8x24-bit 存储阵列 [cite: 70]
    reg [23:0] mem [0:7];

    // 写操作：通过 one-hot 编码的 WA 写入数据 [cite: 71]
    integer i;
    always @(posedge clk) begin
        for (i = 0; i < 8; i = i + 1) begin
            if (WA[i]) begin
                mem[i] <= D;
            end
        end
    end

    // 读操作：组合逻辑，将8x24-bit数据整理成两个96-bit总线 [cite: 72]
    // wb_a 由每行数据的低12位构成
    // wb_b 由每行数据的高12位构成
    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin
            assign wb_a[j*12 +: 12] = mem[j][11:0];
            assign wb_b[j*12 +: 12] = mem[j][23:12];
        end
    endgenerate

endmodule*/

// cim_bank.v: 8x24-bit SRAM 存储体 (支持高/低位分离输出)
// 职责: 存储24位权重, 并分离地提供其高12位和低12位的反相版本。
module cim_bank(
    input clk,
    input [7:0] WA,         // 写地址 (one-hot 编码)
    input [23:0] D,         // 输入的24位原始权重数据
    output [95:0] nW_low,   // 输出: 低12位权重的反相总线
    output [95:0] nW_high   // 输出: 高12位权重的反相总线
);

    // 存储阵列，用于存放完整的24位权重
    reg [23:0] mem [0:7];

    // 临时的内部连线，用于并行读出原始权重的高低位
    wire [95:0] W_low_internal;
    wire [95:0] W_high_internal;

    // 写操作：将输入的24位权重写入存储器
    integer i;
    always @(posedge clk) begin
        for (i = 0; i < 8; i = i + 1) begin
            if (WA[i]) begin
                mem[i] <= D;
            end
        end
    end

    // 读操作: 将存储的8个24-bit字拆分, 并整理成两个96-bit的内部总线
    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin
            // 提取所有权重的低12位
            assign W_low_internal[j*12 +: 12] = mem[j][11:0];
            // 提取所有权重的高12位
            assign W_high_internal[j*12 +: 12] = mem[j][23:12];
        end
    endgenerate

    // 输出最终需要的反相权重
    assign nW_low = ~W_low_internal;
    assign nW_high = ~W_high_internal;

endmodule