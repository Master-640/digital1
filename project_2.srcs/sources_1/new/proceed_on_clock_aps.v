`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/17 16:15:59
// Design Name: 
// Module Name: proceed_on_clock_bps
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
module proceed_on_clock_aps(
input clk,
input rst_n,
output clk_bps
    );
    reg [13:0] cnt_first,cnt_second;
    always@(posedge clk,negedge rst_n)
        if(!rst_n)
            cnt_first<=14'd0;
        else if(cnt_first==14'd7000)
            cnt_first<=14'd0;
        else
            cnt_first<=cnt_first+1'b1;
    always@(posedge clk,negedge rst_n)
        if(!rst_n)
                cnt_second<=14'd0;
        else if(cnt_second==14'd7000)
                cnt_second<=14'd0;
        else if(cnt_first==14'd7000)
                cnt_second<=cnt_second+1'b1;
        else
                cnt_second<=cnt_second;
     assign clk_bps=(cnt_second==14'd7000);       
endmodule

//这个模块执行了一个分频的功能，会加入rst_n,clk,输出clk_bps
/*module proceed_on_clock_bps(
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
   if(rst_n)cnt_second<=14'd0;
   else if(cnt_second==14'd10000)cnt_second<=14'd0;
   else if(cnt_first==14'd10000)cnt_second<=cnt_second+1'b1;
   else cnt_second <= cnt_second;
end
assign clk_bps = clk_bps ^ (cnt_second == 14'd10000);
endmodule
*/