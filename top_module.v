`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/15 18:30:02
// Design Name: 
// Module Name: top_module
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

module top_module(
    input clk, control_light, rst_n, return_to_initial_state,enable,
    input enable_for_modify_time,
    input display_configtime,rst_for_turn_on,
    input enable_for_display,
    input rst_for_key,
    input in1, in2, in3, in4, in5,
    input [1:0]query_what,//待机查询时间的时候查询什么
    input [2:0]modify_what,
    input clean_by_hand,//拨码开关上去就是手动查询
    output reg light,
    output reg total_time_light,I_use_hand_clean,
    output reg show_it_close,
    output reg [7:0]seg_data_left,seg_data_right,seg_data_cs,
    output led0,led1,led2,led3,led4,led5,led6,
    output state_for_open
);
//s0待机s1菜单s2一档s3二档s4三档s5自清洁s6调时间
parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100,s5=3'b101,s6=3'b110;
    reg [7:0] selfclean_countdown;//tmp均为中间变量
    reg [15:0] total_time,tmp_time;
    reg [7:0] current_time;
    reg [7:0] hurricane_countdown1;
    reg [7:0] hurricane_countdown2;
    reg [7:0] hand_gesture_countdown;
    reg enable_total_time,enable_gesture_time;
    wire [7:0]seg_data_left_modify,seg_data_right_modify;
    wire [7:0]seg_data_cs_modify;
    wire [7:0]seg_data_left_query1,seg_data_right_query1;
    wire [7:0]seg_data_cs_query1;
    wire [7:0]seg_data_left_query2,seg_data_right_query2;
    wire [7:0]seg_data_cs_query2;
    wire clk_bps;
    wire [4:0] tmp_hour;
    wire [5:0] tmp_minutes,tmp_seconds;
    //使用tmp作为中间变量，我每次传个tmp过去，然后收到tmp返回的信息就行
    wire [2:0] now_state, next_state;
    wire [4:0] gesture_tmp_hour,total_tmp_hour;
    wire [5:0] total_tmp_minutes;
    wire [5:0] total_tmp_seconds,gesture_tmp_minutes,gesture_tmp_seconds;
    // 设定初值
    divide_seconds_into_time div_total(
    .now_time(total_time),
    .hour(total_tmp_hour),
    .minute(total_tmp_minutes),
    .second(total_tmp_seconds)
    );
    divide_seconds_into_time div_gesture(
    .now_time(hand_gesture_countdown),
    .hour(gesture_tmp_hour),
    .minute(gesture_tmp_minutes),
    .second(gesture_tmp_seconds)
    );
    divide_seconds_into_time tmpthings(
    .now_time(tmp_time),
    .hour(tmp_hour),
    .minute(tmp_minutes),
    .second(tmp_seconds)
    );
    parameter [7:0] selfclean_countdown_st = 8'd10; // 设置自清洁倒计时
    parameter [7:0] hurricane_countdown1_st = 8'd10;  // 设置飓风倒计时1
    parameter [7:0] hurricane_countdown2_st = 8'd10;  // 设置s飓风倒计时2
    parameter [7:0] hand_gesture_countdown_st=8'd10;

    // 初始化计时器
    initial begin
     assign  total_time = 8'b0;
     assign selfclean_countdown = selfclean_countdown_st;
      assign  hurricane_countdown1 = hurricane_countdown1_st;
      assign  hurricane_countdown2 = hurricane_countdown2_st;
      assign  hand_gesture_countdown  = hand_gesture_countdown_st;
  end 

    // 状态机实例化
    state_machine state_machine_1(
        .enable(enable),
        .clk_bps(clk_bps),
        .clk(clk),
        .in1(in1),
        .in2(in2),
        .in3(in3),
        .in4(in4),
        .in5(in5),
        .selfclean_countdown(selfclean_countdown),
        .hurricane_countdown1(hurricane_countdown1),
        .hurricane_countdown2(hurricane_countdown2),
        .state(now_state),
        .next_state(next_state),
        .led0(led0),
        .led1(led1),
        .led2(led2),
        .led3(led3),
        .led4(led4),
        .led5(led5),
        .led6(led6)
    );

    // 生成时钟脉冲
    proceed_on_clock_bps proceed(
        .clk(clk),
        .rst_n(rst_n),
        .clk_bps(clk_bps)
    );
    //以上是初始化
    //这是实例化开机的模块
    turn_on_and_off turn_on(.clk(clk),
    .rst(rst_for_turn_on),
    .power_button(in3),
    .left_button(in1),
    .right_button(in5),
    .power_status(state_for_open)
    );
    always@(posedge clk_bps) begin
       if(!state_for_open)
       begin
          //这里写入关机状态，就是disable掉所有按钮
       //   now_state = 3'b111;
          show_it_close  =1'b1;
         // enable  = 1'b0;
       end
       else 
       begin
    //   now_state = s0;
       show_it_close = 1'b0;
       //enable = 1'b1;
       end
    end
    // 控制照明
    always @(posedge clk_bps) begin
        if (control_light) begin
            light = 1'b1;  // 开灯
        end else begin
            light = 1'b0;  // 关灯
        end
    end
    //对修改时间进行实例化
    
    //tmp这里是一个中间变量，以后每次可以把值赋给中间变量，再把东西读入回来
    // 计时器更新（例如自清洁和飓风倒计时）
    //需要进行修改，后续有一个状态记录
    
    always @(posedge clk_bps) begin
        if (return_to_initial_state) begin//这里连接一个拨码开关
            // 复位时重新初始化计时器
            selfclean_countdown <= selfclean_countdown_st;
            hurricane_countdown1 <= hurricane_countdown1_st;
            hurricane_countdown2 <= hurricane_countdown2_st;
            hand_gesture_countdown  = hand_gesture_countdown_st;
        end
    end
    //now_state等价
    always @(posedge clk_bps) begin//时间显示的enable
    //enable信号是高电频有效
            
        end
        reg [7:0]tmp_display_time;
        wire [4:0]tmp_display_hour;
        wire [5:0]tmp_display_minutes,tmp_display_seconds;
        divide_seconds_into_time div_display(
        .now_time(tmp_display_time),
        .hour(tmp_display_hour),
        .minute(tmp_display_minutes),
        .second(tmp_display_seconds)
        );
       /* number number3(
        .enable(query_what[1]),
        .modified_hours(tmp_display_hour),
        .minute(tmp_display_minutes),
        .second(tmp_display_seconds)
        );*///这里完成显示
        number number1(.enable(enable_total_time),
        .modified_hours(total_tmp_hour),
        .modified_minutes(total_tmp_minutes),
        .modified_seconds(total_tmp_seconds),
        .seg_data(seg_data_right_query1),
        .seg_data2(seg_data_left_query1),
        .seg_cs(seg_data_cs_query1)
        );
        number number2(.enable(enable_gesture_time),
        .modified_hours(gesture_tmp_hour),
        .modified_minutes(gesture_tmp_minutes),
        .modified_seconds(gesture_tmp_seconds),
        .seg_data(seg_data_right_query2),
        .seg_data2(seg_data_left_query2),
        .seg_cs(seg_data_cs_query2)
        );
        //从这里到上面最近的always,完成的是待机模式查询时间的功能
         //number
        //这里要实现一个total_time智能提醒的功能
        always @(posedge clk_bps)begin
        if(total_time>= selfclean_countdown)
        begin
            total_time_light=1'b1;//这个是智能提醒该清洁了
            if(clean_by_hand)//如果我按了这个clear,那么I_use_hand有提醒，智能提醒就会关掉，然后I_use_hand变成0
            begin
               I_use_hand_clean<=1'b1;
               total_time<=1'b0;
               total_time_light <= 1'b0;
             end
             else I_use_hand_clean<=1'b0;
        end
        else 
        begin
        total_time_light <= 1'b0;
        I_use_hand_clean<=1'b0;
        end
        end
        wire [4:0]tmp_accepted_hour;
        wire [5:0]tmp_accepted_minutes,tmp_accepted_seconds;
        wire [7:0]tmp_accepted_time;
        Key key1(
            .enable(enable_for_modify_time),
            //.enable(modify_what[2]);这样应该也行
            .clk(clk_bps),
            .rst(rst_for_key),
            .btn({in1,in2,in3,in4,in5}),
            .init_hours(tmp_hour),
            .init_minutes(tmp_minutes),
            .init_seconds(tmp_seconds),
            .modified_hours(tmp_accepted_hour),
            .modified_minutes(tmp_accepted_minutes),
            .modified_seconds(tmp_accepted_seconds),
            .modified_time(tmp_accepted_time),
            .seg_data(seg_data_right_modify),
            .seg_data2(seg_data_left_modify),
            .seg_cs(seg_data_cs_modify)
            );
          //enable_for_modify_time是根据外部的拨码开关控制的，query_what也是
always @(posedge clk_bps) begin
        case (now_state)
            s0: begin
            if(query_what[1])
            begin
             case(query_what)
                            2'b10:
                            begin
                            enable_total_time <= 1'b1;
                            enable_gesture_time <= 1'b0;
                            seg_data_cs <=seg_data_cs_query1;
                            seg_data_left <= seg_data_left_query1;
                            seg_data_right<=seg_data_right_query1;
                            end
                            2'b11:
                            begin
                            enable_gesture_time <= 1'b1;
                            enable_total_time <= 1'b0;
                            seg_data_cs <=seg_data_cs_query2;
                            seg_data_left <= seg_data_left_query2;
                            seg_data_right<=seg_data_right_query2;
                            end
                            default :begin
                            enable_total_time<=1'b0;
                            enable_gesture_time<=1'b0;
                            end
                            endcase
                 end
                // 这里应该是显示数据的逻辑，(已经解决)
                // 初步设想是用一个显示模块或数据寄存器来实现
            end
           s1:begin
           end
           s2:begin
                total_time <= total_time+1;
           end
           s3:begin
                total_time <= total_time+1;
           end
           s4:begin
                total_time <= total_time+1;
            end
            s5:begin
                total_time <= 0;
            end
            s6:begin//这里要实例化key,然后做一个enable
            if(modify_what[2])
            begin
            seg_data_cs <=seg_data_cs_modify;
            seg_data_left <= seg_data_left_modify;
            seg_data_right<=seg_data_right_modify;
            end
            case (modify_what)//控制modify_what的按钮不能和控制query_what的同时往上
            3'b100:
            begin//这里不能用<=赋值啊，要不然tmp_accepted_time还没得到
            //self_clean_countdown就上了
            tmp_time = selfclean_countdown;
            selfclean_countdown = tmp_accepted_time;
            end
            3'b101:
            begin
            tmp_time = hurricane_countdown1;
            hurricane_countdown1 = tmp_accepted_time;
            end
            3'b110:
            begin
            tmp_time = hurricane_countdown2;
            hurricane_countdown2 = tmp_accepted_time;
            end
            3'b111:
            begin
            tmp_time = hand_gesture_countdown;
            hand_gesture_countdown = tmp_accepted_time;
            end
           //做个无意义语句
            endcase
            end
        endcase
    end
 endmodule

