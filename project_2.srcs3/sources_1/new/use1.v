`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/07 20:54:35
// Design Name: 
// Module Name: use1
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

//we need to find the wrong in the afternoon.
module use1(
input clk,rst_n,
output reg light,
output clk_bps
    );
counters count1(.clk(clk),.rst_n(rst_n),.clk_bps(clk_bps));
always @(posedge clk_bps,posedge rst_n)
begin
    if(rst_n)
    light=1'b0;
    else
    light=~light;
end
endmodule
