`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/10 16:41:18
// Design Name: 
// Module Name: johoson_counter
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

//when we add some signals
//if we choose to save.
//clear all the information
module johoson_counter(
input clk,rst_n,output reg[3:0]out
    );
    always @(posedge clk,posedge rst_n)
    begin
    if(~rst_n)out=4'b0;
    else out={~out[0],out[3:1]};
    end
endmodule
