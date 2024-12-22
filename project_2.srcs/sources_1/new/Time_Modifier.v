`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////


module Time_Modifier(

    input   clk,                      // 时钟信号输入

    input   rst,                      // 重置信号输入

    input   [5:0] initial_second,     // 初始秒数输入

    input   [5:0] initial_minutes,    // 初始分钟输入

    input   [4:0] initial_hours,      // 初始小时输入
     
    input  [2:0]state,
    
    output  reg [5:0] seconds,        // 输出修改后秒数

    output  reg [5:0] minutes,        // 输出修改后分钟

    output  reg [4:0] hours,          // 输出修改后小时

    input   [4:0] btn,                // 按钮输入
     
    
    output  [7:0] seg_data,           // 分钟和秒的显示数据

    output  [7:0] seg_data2,          // 小时的显示数据

    output  [7:0] seg_cs              // 显示位置控制信号
   
);

    reg [4:0] key_vc;                 // 当前按钮状态

    reg [4:0] key_vp;                 // 先前按钮状态

    reg [19:0] keycnt;                // 按钮消抖计数器

    // 按钮边缘检测

    wire [4:0] key_rise_edge;

    assign key_rise_edge = (~key_vp) & key_vc; // 检测上升沿

    // 按钮参数定义

    parameter Sm = 5'b00100;          // 中间按钮

    parameter Su = 5'b10000;          // 增加按钮

    parameter Sd = 5'b00010;          // 减少按钮

    parameter Sl = 5'b01000;          // 左移按钮

    parameter Sr = 5'b00001;          // 右移按钮

    // 时间初始化
    always @(posedge clk)
    begin
       
    end
   

    reg [5:0] location = 5'b000001;   // 当前位置

    // 按钮状态更新，进行消抖

    always @(posedge clk or negedge rst) begin

        if (!rst) begin

            keycnt <= 0;               // 复位计数器

            key_vc <= 5'b0;            // 复位当前按钮状态

        end else begin

            if (keycnt >= 20'd999_999) begin

                keycnt <= 0;            // 达到计数上限，复位计数器

                key_vc <= btn;          // 更新当前按钮状态

            end else begin

                keycnt <= keycnt + 1;   // 增加计数器

            end

        end

    end

    // 更新先前按钮值

    always @(posedge clk) begin

        key_vp <= key_vc;              // 将当前状态记为先前状态

    end

    // 使用按钮调整时间的逻辑
   // 如果使用Time_Modifier,请打P5;不使用请关闭P5;
    always @(posedge clk or negedge rst) begin //这里的是rst_for_time_modify(P5);

        if (!rst) begin

            seconds <= seconds;  // 停在秒数

            minutes <= minutes;  // 复位分钟

            hours   <= hours;    // 复位小时

        end 
        else 
        begin
        if(state == 3'b110 && btn[2]== 1'b1)
               begin
               seconds <= initial_second;
               minutes <= initial_minutes;
               hours  <= initial_hours;
               end
          else
          begin
            case (key_rise_edge)

                Sl: begin
                    location[5:0] = {location[4:0], location[5]}; // 左移动编辑位置
                end

                Sr: begin
                    location[5:0] = {location[0], location[5:1]}; // 右移动编辑位置
                end

                Su: // 增加时间
                    case(location)
                        6'b000001: begin // 秒的个位
                            if(seconds >= 59) begin 
                              seconds = 0; 
                                if(minutes >= 59) begin 
                                    minutes = 0; 
                                    hours = 0; 
                                end else minutes = minutes + 1; 
                            end else seconds = seconds + 1; 
                        end

                        6'b000010: begin // 秒的十位
                            if(seconds / 10 >= 5) begin 
                                seconds = seconds % 10; 
                                if(minutes >= 59) begin 
                                    minutes = 0; 
                                    hours = 0; 
                                end else minutes = minutes + 1; 
                            end else seconds = seconds + 10; 
                        end

                        6'b000100: begin // 分钟的个位
                            if(minutes >= 59) begin 
                                minutes = 0; 
                                if(hours >= 23) hours = 0; 
                                else hours = hours + 1; 
                            end else minutes = minutes + 1; 
                        end

                        6'b001000: begin // 分钟的十位
                            if(minutes / 10 >= 5) begin 
                                minutes = minutes % 10; 
                                if(hours >= 23) hours = 0; 
                                else hours = hours + 1; 
                            end else minutes = minutes + 10; 
                        end

                        6'b010000: begin // 小时的个位
                            if(hours >= 23) begin 
                                hours = 0; 
                            end else hours = hours + 1; 
                        end

                        6'b100000: begin // 小时的十位
                            if(hours / 10 >= 2) begin 
                                hours = hours % 10; 
                            end else begin 
                                hours = hours + 10; 
                                if(hours > 23) hours = 23; 
                            end 
                        end
                    endcase  

                Sd: // 减少时间
                    case(location) 
                        6'b000001: begin // 秒的个位
                            if(seconds == 0) begin 
                                seconds = 59; 
                                if(minutes == 0) begin 
                                    minutes = 59; 
                                    hours = 23; 
                                end else minutes = minutes - 1; 
                            end else seconds = seconds - 1; 
                        end

                        6'b000010: begin // 秒的十位
                            if(seconds / 10 == 0) begin 
                                seconds = seconds % 10 + 50; 
                                if(minutes == 0) begin 
                                    minutes = 59; 
                                    hours = 23; 
                                end else minutes = minutes - 1; 
                            end else seconds = seconds - 10; 
                        end

                        6'b000100: begin // 分钟的个位
                            if(minutes == 0) begin 
                                minutes = 59; 
                                if(hours == 0) hours = 23; 
                                else hours = hours - 1; 
                            end else minutes = minutes - 1; 
                        end

                        6'b001000: begin // 分钟的十位
                            if(minutes / 10 == 0) begin 
                                minutes = minutes % 10 + 50; 
                                if(hours == 0) hours = 23; 
                                else hours = hours - 1; 
                            end else minutes = minutes - 10; 
                        end

                        6'b010000: begin // 小时的个位
                            if(hours == 0) begin 
                                hours = 23; 
                            end else hours = hours - 1; 
                        end

                        6'b100000: begin // 小时的十位
                            if(hours / 10 == 0) begin 
                                hours = hours % 10 + 20; 
                            end else hours = hours - 10; 
                        end
                    endcase
            endcase
        end
        end
    end

    

    reg [31:0] data;

    always @(posedge clk) begin
        data[31:28] = hours / 10;     // 小时十位
        data[27:24] = hours % 10;     // 小时个位
        data[23:20] = 4'hF;           // 分隔符
        data[19:16] = minutes / 10;   // 分钟十位
        data[15:12] = minutes % 10;   // 分钟个位
        data[11:8]  = 4'hF;           // 分隔符
        data[7:4]   = seconds / 10;   // 秒钟十位
        data[3:0]   = seconds % 10;   // 秒钟个位
    end

    // 显示控制

    number u2(
        .clk(clk),
        .rst(rst),
        .data(data),
        .seg_data(seg_data),
        .seg_data2(seg_data2),
        .seg_cs(seg_cs)
    );

endmodule
