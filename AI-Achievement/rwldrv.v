// rwldrv.v
// 功能: 读字线驱动 (Row/Word Line Driver) 

/*module rwldrv (
    input      [5:0]        sel,    // 来自gctrl的选择信号
    input      [95:0]       xin,    // 输入的计算数据向量 
    input                   cima,   // 用于选择输出到row0还是row1
    output reg [7:0]        rwlb_row0,
    output reg [7:0]        rwlb_row1
);
    
    wire [7:0] xin_w [0:11];

    // 首先将96-bit的xin分解为12组8-bit的xin_w 
    genvar i;
    generate
        for(i = 0; i < 12; i = i + 1) begin: xin_decompose
            assign xin_w[i] = xin[i*8 +: 8];
        end
    endgenerate
    
    // 使用case语句, 根据sel的值, 从xin_w中选择一组 
    always @(*) begin
        case(sel)
            0:  setSelected(~xin_w[0]);
            1:  setSelected(~xin_w[1]);
            2:  setSelected(~xin_w[2]);
            3:  setSelected(~xin_w[3]);
            4:  setSelected(~xin_w[4]);
            5:  setSelected(~xin_w[5]);
            6:  setSelected(~xin_w[6]);
            7:  setSelected(~xin_w[7]);
            8:  setSelected(~xin_w[8]);
            9:  setSelected(~xin_w[9]);
            10: setSelected(~xin_w[10]);
            11: setSelected(~xin_w[11]);
            // 对于24-bit输入，sel会继续增长，这里假设复用前12组输入
            // 或者可以扩展xin到192位
            12: setSelected(~xin_w[0]); // 示例：简单复用
            13: setSelected(~xin_w[1]);
            14: setSelected(~xin_w[2]);
            15: setSelected(~xin_w[3]);
            16: setSelected(~xin_w[4]);
            17: setSelected(~xin_w[5]);
            18: setSelected(~xin_w[6]);
            19: setSelected(~xin_w[7]);
            20: setSelected(~xin_w[8]);
            21: setSelected(~xin_w[9]);
            22: setSelected(~xin_w[10]);
            23: setSelected(~xin_w[11]);
            // ...以此类推
            default: setSelected(8'b0);
        endcase
    end
    
    // 根据cima信号决定输出到哪一个端口 
    task setSelected;
        input [7:0] selected_val;
        begin
            if (cima) begin
                rwlb_row1 = selected_val;
                rwlb_row0 = 8'b0;
            end else begin
                rwlb_row0 = selected_val;
                rwlb_row1 = 8'b0;
            end
        end
    endtask

endmodule*/


// rwldrv.v: 读字线驱动
/*module rwldrv(
    input cima,                 // bank选择信号 [cite: 85]
    input [5:0] sel,            // 周期选择信号
    input [191:0] xin,          // 192-bit 输入向量 (支持24bit模式)
    output [7:0] rwlb_row0,     // 行驱动信号0
    output [7:0] rwlb_row1      // 行驱动信号1
);

    wire [7:0] xin_w [0:23];    // 将192-bit输入分解为24组8-bit向量
    wire [7:0] selected_xin_w;

    // 将192-bit的xin分解为24组8-bit的xin_w
    genvar i;
    generate
        for (i = 0; i < 24; i = i + 1) begin
            assign xin_w[i] = xin[i*8 +: 8];
        end
    endgenerate

    // 根据sel的值，从xin_w中选择一组 [cite: 85]
    assign selected_xin_w = xin_w[sel];

    // cima信号决定输出到哪个bank的驱动信号 [cite: 85]
    // 输出取反 [cite: 85]
    assign rwlb_row0 = (cima == 1'b0) ? ~selected_xin_w : 8'hFF;
    assign rwlb_row1 = (cima == 1'b1) ? ~selected_xin_w : 8'hFF;

endmodule*/


// rwldrv.v: 读字线驱动 (通过内部地址变址实现MSB优先)
module rwldrv(
    // 控制信号
    input cima,
    input inwidth,              // **新增**: 用于判断当前运算位宽
    input [5:0] sel,

    // 数据输入
    input [191:0] xin,

    // 输出
    output [7:0] rwlb_row0,
    output [7:0] rwlb_row1
);

    wire [7:0] selected_x_bits;
    wire [5:0] max_index;
    wire [5:0] effective_index;

    // 1. 根据 inwidth 判断最大索引值 (11 或 23)
    assign max_index = inwidth ? 23 : 11;
    
    // 2. 计算实际有效的地址索引，实现倒序读取
    assign effective_index = max_index - sel;

    // 3. 从8个通道中提取需要的比特位
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            assign selected_x_bits[i] = xin[i*24 + effective_index];
        end
    endgenerate
    
    // 4. 为活动路径输出~X，为非活动路径输出1 (逻辑不变)
    assign rwlb_row0 = (cima == 1'b0) ? ~selected_x_bits : 8'hFF;
    assign rwlb_row1 = (cima == 1'b1) ? ~selected_x_bits : 8'hFF;

endmodule