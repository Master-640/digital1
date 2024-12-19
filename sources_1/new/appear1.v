`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 21:28:25
// Design Name: 
// Module Name: appear1
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

//solve this problem
module appear1(
num,now_state
    );
input wire [7:0]num;
output reg [15:0]now_state;
parameter open_state=16'b1000_0000_0000_0000;
parameter close_state=16'b0000_0000_0000_0000;
parameter quite_state=16'b1100_0000_0000_0000;
parameter self_clean_state0=16'b1010_0000_0000_0000;
parameter self_clean_state1=16'b1010_0000_1000_0000;
parameter self_clean_state2=16'b1010_0000_0100_0000;
parameter self_clean_state3=16'b1010_0000_0010_0000;
always @* begin
    case(num)
    default: now_state = 16'b0000_0000_0000_0000;
    endcase
end
endmodule
