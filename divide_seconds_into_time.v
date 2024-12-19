`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/17 16:59:32
// Design Name: 
// Module Name: divide_seconds_into_time
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

//���ǰѵ�ǰʱ����ʱ���֣���
module divide_seconds_into_time(
input [7:0]now_time,
output reg [4:0]hour,
output reg [5:0]minute,second
    );
initial begin
    hour = now_time / 4'd3600;
    minute = (now_time) % 4'd3600 / 2'd60;
    second = (now_time) % 2'd60;
 end
endmodule
