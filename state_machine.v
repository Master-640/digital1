`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 15:42:44
// Design Name: 
// Module Name: state_machine
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
//

module state_machine(
input  enable,in1,in2,in3,in4,in5,
input clk,
input [5:0]hurricane_countdown1,hurricane_countdown2,//��������ʱ 1�����ض�����2�����ش���
input [7:0]selfclean_countdown,//����൹��ʱ
output reg [2:0] state,next_state,
output reg led0,reg led1,reg led2,reg led3,reg led4,reg led5
    );//s0����s1�˵�s2һ��s3����s4����s5�����s6��ʱ��
parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100,s5=3'b101,s6=3'b110;
wire [5:0]in;
assign in={enable,in1,in2,in3,in4,in5};
reg [5:0] timer_s4_1 = 0; // 60 seconds for hurricane mode
reg [5:0] timer_s4_2 = 0;
reg [7:0] timer_s5 = 0; // 3 minutes for self-cleaning mode
reg hurricane_used=1'b1;//�Ƿ�ʹ�ù�쫷�ģʽ
reg back_to_standby=1'b0;//�Ƿ�ص�����
always @(posedge clk) begin
    if (state == s4 && timer_s4_1 > 0) begin
        timer_s4_1 <= timer_s4_1- 1;
    end
    if (state == s5 && timer_s5 > 0) begin
        timer_s5 <= timer_s5 - 1;
    end
    state <= next_state;
end


always @* begin
    case (state)
        s0: begin // ����ģʽ
            case (in)
                6'b110000: next_state = s1; // �˵�����׼���л�ģʽ
                default: next_state = s0;
            endcase
        end
        s1: begin // �˵�ģʽ
            case (in)
                6'b110000: next_state = s2; // 1����������1��������ģʽ
                6'b101000: next_state = s3; // 2����������2��������ģʽ
                6'b100100: 
                    if(hurricane_used)begin
                        next_state = s4; // 3����������3��������ģʽ��쫷�ģʽ��
                        hurricane_used=1'b0;
                    end
                6'b100010: next_state = s5; // ����ఴ�������������ģʽ
                default: next_state = s1;
            endcase
        end
        s2: begin // 1��������ģʽ
            case (in)
                6'b110000: next_state = s1; // �˵��������ش���ģʽ
                6'b101000: next_state = s3;//2��
                default: next_state = s2;
            endcase
        end
        s3: begin // 2��������ģʽ
            case (in)
                6'b110000: next_state = s1; // �˵��������ش���ģʽ
                6'b101000: next_state = s2;//1��
                default: next_state = s3;
            endcase
        end
        s4: begin // 3��������ģʽ��쫷�ģʽ��
            case (in)
                6'b100000: 
                    if(timer_s4_1==0) begin
                        timer_s4_1=hurricane_countdown1;
                        next_state = s4;
                    end
                    else if(!back_to_standby && timer_s4_1==1)begin
                        next_state=s3;
                    end
                    else if(back_to_standby && timer_s4_2==1)begin
                        next_state=s0;
                    end
                    else next_state = s4;
                6'b110000:
                    if(timer_s4_2==0) begin
                        timer_s4_2=hurricane_countdown2;
                        next_state = s4;
                        back_to_standby=1'b1;
                    end
//                    else if(timer_s4_2==1)begin
//                        next_state=s0;
//                    end
//                    else next_state = s4;
                default: next_state = s4;
            endcase
        end
        s5: begin // �����ģʽ
            case (in)
                6'b100000: 
                if(timer_s5==0) begin
                    timer_s5=selfclean_countdown;
                    next_state = s5;
                end
                else if(timer_s5==1)begin
                    next_state=s0;
                end
                else next_state = s5;
                default: next_state = s5;
            endcase
        end
        default: next_state = s0; // Ĭ�Ϸ��ش���ģʽ
    endcase
end


always @(state) begin
    led0 = (state == s0); 
    led1 = (state == s1); 
    led2 = (state == s2); 
    led3 = (state == s3); 
    led4 = (state == s4); 
    led5 = (state == s5); 
end

endmodule
