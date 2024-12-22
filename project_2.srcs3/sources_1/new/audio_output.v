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
    input clk,            // FPGA��ʱ������
    input rst,            // ��λ�źţ��ߵ�ƽ��λ��
    input enable,         // ������ʹ���źţ�1��������0��������
    output reg BUZZER_PWM // ��������PWM�ź����
);

    // ��������
    parameter CLOCK_FREQ = 100000000;          // FPGA��ʱ��Ƶ�ʣ�����Ϊ100MHz��
    parameter TARGET_FREQ = 440;               // �̶�Ŀ��Ƶ�ʣ�440Hz������ A4��
    parameter MAX_COUNT = CLOCK_FREQ / (TARGET_FREQ * 2); // ���������ֵ

    // �ڲ��Ĵ���
    reg [31:0] counter;

    // ����PWM�ź�
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // ��λ�߼�
            counter <= 0;
            BUZZER_PWM <= 0;
        end else if (enable) begin
            // ���enableΪ1������������PWM�ź�
            if (counter < MAX_COUNT - 1) begin
                counter <= counter + 1;
            end else begin
                counter <= 0;
                BUZZER_PWM <= ~BUZZER_PWM; // ��תPWM�źţ����ɷ���
            end
        end else begin
            // ���enableΪ0��������PWM�źŹ̶�Ϊ�͵�ƽ��
            counter <= 0;
            BUZZER_PWM <= 0;
        end
    end
endmodule

