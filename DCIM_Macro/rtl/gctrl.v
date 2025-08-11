module gctrl(
    input clk,                // 时钟信号
    input rstn,               // 复位信号
    input start,              // 开始计算信号
    input inwidth,            // 输入位宽选择 (12-bit 或 24-bit)
    output reg [5:0] sel,     // 选择信号
    output reg st             // 累加器启停信号
);

    // 计数器上限：12-bit模式为11，24-bit模式为23
    wire [5:0] max_count = inwidth ? 6'd23 : 6'd11;
    
    // 状态机状态
    reg [1:0] state;
    parameter IDLE = 2'b00;   // 空闲状态
    parameter COUNT = 2'b01;  // 计数状态
    parameter DONE = 2'b10;   // 完成状态

    // 状态机逻辑
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            sel <= 6'b0;
            st <= 1'b1;  // 初始状态为高，表示累加器停止
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= COUNT;
                        sel <= 6'b0;
                        st <= 1'b0;  // 开始累加
                    end else begin
                        sel <= 6'b0;
                        st <= 1'b1;
                    end
                end
                
                COUNT: begin
                    if (sel >= max_count) begin
                        state <= DONE;
                        st <= 1'b1;  // 停止累加
                    end else begin
                        sel <= sel + 1'b1;
                        st <= 1'b0;  // 继续累加
                    end
                end
                
                DONE: begin
                    state <= IDLE;
                    sel <= 6'b0;
                    st <= 1'b1;
                end
                
                default: begin
                    state <= IDLE;
                    sel <= 6'b0;
                    st <= 1'b1;
                end
            endcase
        end
    end

endmodule 