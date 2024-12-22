`timescale 1ns / 1ps

module turn_on_and_off(
    input clk,
    input rst,
    input power_button,  // 开关机按键
    input left_button,
    input right_button,
    input [15:0]COUNTDOWN_TIME,
    output reg power_status, // 开关机状态 (1: 开机, 0: 关机)
    output [7:0] selection,
    output [7:0] left_time,
    output [7:0] right_time
);
    parameter LONG_PRESS_TIME = 300_000_000; // 长按 3 秒 (假设 100 MHz 时钟)
    parameter DEBOUNCE_TIME = 20_000_000;    // 去抖延时 200 ms

    // 内部信号
    wire button_stable;     // 去抖后的按键信号
    wire left_stable;       // 去抖后的左键信号
    wire right_stable;      // 去抖后的右键信号
    reg [31:0] counter;     // 长按计数器
    reg [31:0] countdown;   // 倒计时计数器
    reg countdown_active;   // 倒计时激活标志
    reg is_long_press;      // 长按标志
    reg button_prev;        // 上一次按键状态
    reg left_prev, right_prev;
    reg [31:0] countdown_for_time;
    // 去抖模块
    debouncer #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) db_power (
        .clk(clk),
        .rst(rst),
        .button_in(power_button),
        .button_out(button_stable)
    );

    debouncer #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) db_left (
        .clk(clk),
        .rst(rst),
        .button_in(left_button),
        .button_out(left_stable)
    );

    debouncer #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) db_right (
        .clk(clk),
        .rst(rst),
        .button_in(right_button),
        .button_out(right_stable)
    );

    // 主逻辑
    always @(posedge clk or negedge rst) begin
       countdown_for_time = COUNTDOWN_TIME * 1000_0000_0;
        if (!rst) begin
            power_status <= 0; // 初始状态为关机
            counter <= 0;
            is_long_press <= 0;
            countdown <= 0;
            countdown_active <= 0;
            button_prev <= 0;
            left_prev <= 0;
            right_prev <= 0;
        end else begin
            // 短按/长按逻辑
            if (button_stable) begin
                if (counter < LONG_PRESS_TIME) begin
                    counter <= counter + 1; // 长按计数
                end else begin
                    is_long_press <= 1; // 标记为长按
                end
            end else begin
                if (button_prev && !is_long_press) begin
                    power_status <= 1'b1; // 短按开机
                end else if (is_long_press) begin
                    power_status <= 1'b0; // 长按关机
                end
                counter <= 0;
                is_long_press <= 0;
            end

            // 手势逻辑
            if (!power_status) begin // 关机状态
                if (left_stable && !left_prev) begin
                    countdown_active <= 1;
                    countdown <= 0;
                end
                if (countdown_active && right_stable && !right_prev) begin
                    power_status <= 1; // 左键 + 右键 开机
                    countdown_active <= 0;
                    countdown <= 0;
                end
            end else begin // 开机状态
                if (right_stable && !right_prev) begin
                    countdown_active <= 1;
                    countdown <= 0;
                end
                if (countdown_active && left_stable && !left_prev) begin
                    power_status <= 0; // 右键 + 左键 关机
                    countdown_active <= 0;
                    countdown <= 0;
                end
            end

            // 倒计时逻辑
            if (countdown_active) begin
                if (countdown < countdown_for_time) begin
                    countdown <= countdown + 1;
                end else begin
                    countdown_active <= 0; // 倒计时结束
                    countdown <= 0;
                end
            end

            // 更新按键状态
            button_prev <= button_stable;
            left_prev <= left_stable;
            right_prev <= right_stable;
        end
    end
    
endmodule

// 去抖模块
module debouncer #(
    parameter DEBOUNCE_TIME = 20_000_000 // 去抖延时 (默认 200 ms)
)(
    input clk,
    input rst,
    input button_in,
    output reg button_out
);
    reg [24:0] counter;  // 去抖计数器
    reg button_sync;     // 同步后的按键信号

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            button_sync <= 0;
            button_out <= 0;
        end else begin
            button_sync <= button_in;
            if (button_sync == button_out) begin
                counter <= 0;
            end else begin
                counter <= counter + 1; // 相当于 button_sync 的信号过了一会再读入
                if (counter >= DEBOUNCE_TIME) begin
                    button_out <= button_sync;
                    counter <= 0;
                end
            end
        end
    end
endmodule
