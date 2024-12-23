`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/22 17:41:26
// Design Name: 
// Module Name: audio_output
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module audio_output (
    input clk,            // FPGA主时钟输入
    input rst,            // 复位信号（高电平复位）
    input enable,         // 蜂鸣器使能信号（1：发声，0：静音）
    output reg BUZZER_PWM // 蜂鸣器的PWM信号输出
);

    // 参数定义
    parameter CLOCK_FREQ = 100000000;          // FPGA主时钟频率（假设为100MHz）
    parameter TARGET_FREQ = 440;               // 固定目标频率：440Hz（音符 A4）
    parameter MAX_COUNT = CLOCK_FREQ / (TARGET_FREQ * 2); // 计数器最大值

    // 内部寄存器
    reg [31:0] counter;

    // 生成PWM信号
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 复位逻辑
            counter <= 0;
            BUZZER_PWM <= 0;
        end else if (enable) begin
            // 如果enable为1，则正常生成PWM信号
            if (counter < MAX_COUNT - 1) begin
                counter <= counter + 1;
            end else begin
                counter <= 0;
                BUZZER_PWM <= ~BUZZER_PWM; // 翻转PWM信号，生成方波
            end
        end else begin
            // 如果enable为0，则静音（PWM信号固定为低电平）
            counter <= 0;
            BUZZER_PWM <= 0;
        end
    end
endmodule

