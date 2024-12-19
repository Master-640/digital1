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
input [5:0]hurricane_countdown1,hurricane_countdown2,//三档倒计时 1：返回二档；2：返回待机
input [7:0]selfclean_countdown,//自清洁倒计时
output reg [2:0] state,next_state,
output reg led0,reg led1,reg led2,reg led3,reg led4,reg led5
    );//s0待机s1菜单s2一档s3二档s4三档s5自清洁s6调时间
parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100,s5=3'b101,s6=3'b110;
wire [5:0]in;
assign in={enable,in1,in2,in3,in4,in5};
reg [5:0] timer_s4_1 = 0; // 60 seconds for hurricane mode
reg [5:0] timer_s4_2 = 0;
reg [7:0] timer_s5 = 0; // 3 minutes for self-cleaning mode
reg hurricane_used=1'b1;//是否使用过飓风模式
reg back_to_standby=1'b0;//是否回到待机
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
        s0: begin // 待机模式
            case (in)
                6'b110000: next_state = s1; // 菜单键，准备切换模式
                default: next_state = s0;
            endcase
        end
        s1: begin // 菜单模式
            case (in)
                6'b110000: next_state = s2; // 1档键，进入1档抽油烟模式
                6'b101000: next_state = s3; // 2档键，进入2档抽油烟模式
                6'b100100: 
                    if(hurricane_used)begin
                        next_state = s4; // 3档键，进入3档抽油烟模式（飓风模式）
                        hurricane_used=1'b0;
                    end
                6'b100010: next_state = s5; // 自清洁按键，进入自清洁模式
                default: next_state = s1;
            endcase
        end
        s2: begin // 1档抽油烟模式
            case (in)
                6'b110000: next_state = s1; // 菜单键，返回待机模式
                6'b101000: next_state = s3;//2档
                default: next_state = s2;
            endcase
        end
        s3: begin // 2档抽油烟模式
            case (in)
                6'b110000: next_state = s1; // 菜单键，返回待机模式
                6'b101000: next_state = s2;//1档
                default: next_state = s3;
            endcase
        end
        s4: begin // 3档抽油烟模式（飓风模式）
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
        s5: begin // 自清洁模式
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
        default: next_state = s0; // 默认返回待机模式
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
