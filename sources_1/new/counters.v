`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/07 20:46:39
// Design Name: 
// Module Name: counters
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
/////////////////////////////////////////////////////////////////////////////////

module counters(
input clk,rst_n,
output clk_bps
    );
reg [13:0]cnt_first,cnt_second;
always @(posedge clk,negedge rst_n)
begin
    if(rst_n)cnt_first<=14'd00000;
    else if(cnt_first==14'd10000)cnt_first<=14'd00000;
    else cnt_first <= cnt_first+1'b1;
end
always @(posedge clk,negedge rst_n)
begin
   if(rst_n)cnt_first<=14'd0;
   else if(cnt_second==14'd10000)cnt_second<=14'd0;
   else if(cnt_first==14'd10000)cnt_second<=cnt_second+1'b1;
   else cnt_second <= cnt_second;
end
assign clk_bps = clk_bps ^ (cnt_second == 14'd10000);
endmodule
