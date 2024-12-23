module countdown_timer(
    input clk,              // 时钟信号
    input reset,            // 复位信号
    input start,            // 开始倒计时信号
    input [7:0] countdown,  // 倒计时初始值
    output reg done,        // 倒计时完成信号
    output reg [7:0] time_left // 剩余时间
);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            time_left <= 0;
            done <= 1'b0;
        end else if (start) begin
            if (time_left == 0) begin
                time_left <= countdown;
                done <= 1'b0;
            end else if (time_left == 1) begin
               // time_left <= 0;
                done <= 1'b1; // 倒计时完成
            end else begin
                time_left <= time_left - 1;  
                done <= 1'b0;
            end
        end
    end

endmodule
