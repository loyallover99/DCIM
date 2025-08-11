// gctrl.v
// 功能: 全局控制器, 用于产生计算的步进控制信号 

/*module gctrl (
    input                   clk,
    input                   rstn,
    input                   start,    // 开始信号
    input                   inwidth,  // 输入位宽选择 (0 for 12-bit, 1 for 24-bit) 
    output reg [5:0]        sel,      // 输出的选择信号, 用于驱动 rwldrv 
    output reg              st        // 累加器启停信号 
);

    reg [5:0] count;
    reg active;
    wire [5:0] count_limit;

    // 根据inwidth决定计数上限 (11 for 12-bit, 23 for 24-bit) 
    assign count_limit = inwidth ? 23 : 11;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            count <= 6'b0;
            sel <= 6'b0;
            st <= 1'b1; // 默认停止
            active <= 1'b0;
        end else begin
            if (start && !active) begin // 检测到start信号，开始计数
                active <= 1'b1;
                st <= 1'b0; // st拉低，累加器开始工作 
                count <= 6'b0;
                sel <= 6'b0;
            end else if (active) begin
                if (count == count_limit) begin // 计数完成
                    st <= 1'b1;   // st拉高，累加结束 
                    sel <= 6'b0;  // sel复位 
                    active <= 1'b0;
                end else begin
                    count <= count + 1;
                    sel <= sel + 1; // sel递增 
                end
            end
        end
    end

endmodule*/

// gctrl.v: 全局控制器
module gctrl(
    input clk, rstn, start, inwidth,
    output reg [5:0] sel,
    output reg st,
    output wire sus
);
    wire [5:0] count_limit;
    reg computing;
    assign count_limit = inwidth ? 23 : 11;
    assign sus = (sel == count_limit) && computing;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sel <= 6'b0;
            st <= 1'b1;
            computing <= 1'b0;
        end else begin
            if (start && !computing) begin
                computing <= 1'b1;
                st <= 1'b0;
                sel <= 6'b0;
            end else if (computing) begin
                if (sel == count_limit) begin
                    computing <= 1'b0;
                    st <= 1'b1;
                    sel <= 6'b0;
                end else begin
                    sel <= sel + 1;
                end
            end
        end
    end
endmodule