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
    input clk, control_light,return_to_initial_state,enable,rst,
    input enable_for_modify_time,
    input rst_for_turn_on,//hold_on_time解决displaytime里面的
    input enable_for_display,
    input rst_for_key,
    input in1, in2, in3, in4, in5,
    //待机查询时间的时候查询什么
    input [2:0]modify_what,
    input clean_by_hand,//拨码开关上去就是手动查询
    input rst_for_time_modify1,rst_for_time_modify2,//P5是空的
    output reg light,
    output reg total_time_light,I_use_hand_clean,
    output reg show_it_close,
    output reg [7:0]seg_data_left,seg_data_right,seg_data_cs,
    output led0,led1,led2,led3,led4,led5,led6,
    output state_for_open
);
//s0待机s1菜单s2一档s3二档s4三档s5自清洁s6调时间
parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100,s5=3'b101,s6=3'b110;
    reg [7:0] selfclean_countdown=8'd5;//tmp均为中间变量
    reg [15:0] total_time,tmp_time;
    reg [7:0] hurricane_countdown1;
    reg [7:0] hurricane_countdown2;
    reg [15:0] hand_gesture_countdown=16'd2;
    reg [15:0]total_time_limit=16'd2;
    //在这里赋初值,一定要注意顺序！
    reg enable_total_time,enable_gesture_time;
    wire [7:0]seg_data_left_modify,seg_data_right_modify;
    wire [7:0]seg_data_cs_modify;
    wire [7:0]seg_data_left_query1,seg_data_right_query1;
    wire [7:0]seg_data_cs_query1;
    wire [7:0]seg_data_left_query2,seg_data_right_query2;
    wire [7:0]seg_data_cs_query2;
    wire clk_bps,clk_aps;
    reg clk1,clk2;
    wire [4:0] tmp_hour;
    wire [5:0] tmp_minutes,tmp_seconds;
    //使用tmp作为中间变量，我每次传个tmp过去，然后收到tmp返回的信息就行
    wire [2:0] now_state, next_state;
    wire [4:0] gesture_tmp_hour,total_tmp_hour;
    wire [5:0] total_tmp_minutes;
    wire [5:0] total_tmp_seconds,gesture_tmp_minutes,gesture_tmp_seconds;
    // 设定初值
    //total_tmp_hour,total_tmp_minutes,total_tmp_seconds;
    //gesture_tmp_hour,gesture_tmp_minutes,gesture_tmp_seconds;
    divide_seconds_into_time div_total(
    .clk(clk),
    .now_time(total_time_limit),
    .hour(total_tmp_hour),
    .minute(total_tmp_minutes),
    .second(total_tmp_seconds)
    );
    divide_seconds_into_time div_gesture(
    .clk(clk),
    .now_time(hand_gesture_countdown),
    .hour(gesture_tmp_hour),
    .minute(gesture_tmp_minutes),
    .second(gesture_tmp_seconds)
    );
    
    parameter [7:0] selfclean_countdown_st = 8'd3; // 设置自清洁倒计时
    parameter [7:0] hurricane_countdown1_st = 8'd10;  // 设置飓风倒计时1
    parameter [7:0] hurricane_countdown2_st = 8'd10;  // 设置s飓风倒计时2
    parameter [15:0] hand_gesture_countdown_st=16'd10;
    parameter [15:0] total_time_limit_st= 16'd10;
    // 初始化计时器
    initial begin
     /*selfclean_countdown = selfclean_countdown_st;*/
     hurricane_countdown1 = hurricane_countdown1_st;
     hurricane_countdown2 = hurricane_countdown2_st;
  end 
    // 状态机实例化
    reg hold_on_now_state;
    always @(posedge clk)
    begin
    if(( now_state == s0 && enable) || (now_state==s6&&enable ))
    begin
    hold_on_now_state = 1'b1;
    end
    else
    hold_on_now_state = 1'b0;
     end
     
    state_machine state_machine_1(
        .enable(state_for_open),
        .hold_on_now_state(hold_on_now_state),
        .clk_bps(clk_bps),
        .rst(rst),
        .clk(clk_aps),
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
        .rst_n(state_for_open),//只有开机之后，功能才能正常实现
        .clk_bps(clk_bps)
    );
    proceed_on_clock_aps proceed1(
        .clk(clk),
        .rst_n(state_for_open),
        .clk_bps(clk_aps)
    );
    //以上是初始化
    //这是实例化开机的模块
    turn_on_and_off turn_on(.clk(clk),
    .COUNTDOWN_TIME(hand_gesture_countdown),
    .rst(rst_for_turn_on),
    .power_button(in3),
    .left_button(in1),
    .right_button(in5),
    .power_status(state_for_open)
    );
    always@(posedge clk_bps) begin
       if(!state_for_open)
       begin
          show_it_close  =1'b1;
       end
       else 
       begin
       show_it_close = 1'b0;
       end
    end
    // 控制照明(换成clk也行)
    always @(posedge clk) begin
        if (state_for_open&&control_light) begin
            light = 1'b1;  // 开灯
        end else begin
            light = 1'b0;  // 关灯
        end
    end
    //对修改时间进行实例化
    
    //tmp这里是一个中间变量，以后每次可以把值赋给中间变量，再把东西读入回来
    // 计时器更新（例如自清洁和飓风倒计时）
    //需要进行修改，后续有一个状态记录
    //now_state等价
        //对单个变量的所有赋值语句一定要放到同一个always语句块中
        always @(posedge clk_bps) begin
            case (now_state) 
                s2, s3, s4: begin
                    total_time <= total_time + 16'b1; // 非阻塞赋值
                end
                s5:
                begin
                total_time <= 0;
                end
            endcase
          //total_time_limit就是当前限制的值
            if (total_time > total_time_limit) begin
                total_time_light <= 1'b1; // 设置提醒
                if (clean_by_hand) begin
                    I_use_hand_clean <= 1'b1; // 手动清洁
                    total_time <= 16'b0; // 重置计时器
                    total_time_light <= 1'b0; // 关闭提醒
                end else begin
                    I_use_hand_clean <= 1'b0;
                end
            end else begin
                total_time_light <= 1'b0; // 重置提醒
                I_use_hand_clean <= 1'b0;
            end
        end

        wire [4:0]tmp_accepted_hour1;
        wire [5:0]tmp_accepted_minutes1,tmp_accepted_seconds1;
        reg [15:0]tmp_accepted_time1;
        wire [4:0]tmp_accepted_hour2;
        wire [5:0]tmp_accepted_minutes2,tmp_accepted_seconds2;
        reg [15:0]tmp_accepted_time2;
        wire [7:0]seg_data_left_open,seg_data_right_open,seg_data_cs_open;
        //enable for key 不要了
        Key key1(//这个直接在里面存就好
            .clk(clk),
            .rst(state_for_open),//开机才显示,为R3,
            .rst_for_key(rst_for_key),//是R3,按上去被锁，按下去就不锁
            .btn({in2,in1,in3,in4,in5}),
            .seg_data(seg_data_right_open),
            .seg_data2(seg_data_left_open),
            .seg_cs(seg_data_cs_open)
            );
                //total_tmp_hour,total_tmp_minutes,total_tmp_seconds;
                    //gesture_tmp_hour,gesture_tmp_minutes,gesture_tmp_seconds;
                    //我怀疑这里的initial_seconds传进去的是0
                    //为什么不能都调用key呢,我感觉Key很对
             Time_Modifier TM1(//这是和total_time绑定的
             .state(now_state),
             .clk(clk),
             .rst(rst_for_time_modify1),//G4
             .btn({in2,in1,in3,in4,in5}),
             .initial_second(total_tmp_seconds),
             .initial_minutes(total_tmp_minutes),
             .initial_hours(total_tmp_hour),
             .hours(tmp_accepted_hour1),
             .minutes(tmp_accepted_minutes1),
             .seconds(tmp_accepted_seconds1),
             .seg_data(seg_data_right_query1),
             .seg_data2(seg_data_left_query1),
             .seg_cs(seg_data_cs_query1)
             );
             Time_Modifier TM2(//这是和total_time绑定的
                          .state(now_state),
                          .clk(clk),
                          .rst(rst_for_time_modify2),//G3
                          .btn({in2,in1,in3,in4,in5}),
                          .initial_second(gesture_tmp_seconds),
                          .initial_minutes(gesture_tmp_minutes),
                          .initial_hours(gesture_tmp_hour),
                          .hours(tmp_accepted_hour2),
                          .minutes(tmp_accepted_minutes2),
                          .seconds(tmp_accepted_seconds2),
                          .seg_data(seg_data_right_query2),
                          .seg_data2(seg_data_left_query2),
                          .seg_cs(seg_data_cs_query2)
                          );
          //enable_for_modify_time是根据外部的拨码开关控制的，query_what也是
          //seg_data的赋值一定要全部在这里面！
always @(posedge clk)//不要用clk_bps!因为打印是必须实时打印的.
begin
     case(now_state)
     s0:
     begin
     seg_data_left = seg_data_left_open;
     seg_data_right = seg_data_right_open;
     seg_data_cs = seg_data_cs_open;
     end
     s6:
     begin
     tmp_accepted_time1 = 16'd3600*tmp_accepted_hour1+16'd60*tmp_accepted_minutes1+tmp_accepted_seconds1;
     tmp_accepted_time2 = 16'd3600*tmp_accepted_hour2+16'd60*tmp_accepted_minutes2+tmp_accepted_seconds2;
     case(modify_what)
     3'b110:
     begin
     if(return_to_initial_state)//这个按钮接到了P5上去
     begin
     //P5的时候,按理说会这样，但是total_time_limit = total_time_limit_st;
     //问题出在哪里?
     total_time_limit = 16'b10;
     seg_data_left = seg_data_left_query1;
     seg_data_right = seg_data_right_query1;
     seg_data_cs = seg_data_cs_query1;
     end
     else
     begin
     total_time_limit = tmp_accepted_time1;//注意
     seg_data_left = seg_data_left_query1;
     seg_data_right = seg_data_right_query1;
     seg_data_cs = seg_data_cs_query1;
     end
     end
     3'b100:
     begin
     if(return_to_initial_state)
     begin
     hand_gesture_countdown = 16'b10;
     seg_data_left = seg_data_left_query2;
     seg_data_right = seg_data_right_query2;
     seg_data_cs = seg_data_cs_query2;
     end
     else
     begin
     hand_gesture_countdown = tmp_accepted_time2;
     seg_data_left = seg_data_left_query2;
     seg_data_right = seg_data_right_query2;
     seg_data_cs = seg_data_cs_query2;
     end
     end
     default://按理来说，不显示这个的时候，都会显示8'b0000_0000
     begin
     seg_data_left = 8'b1111_1111;
     seg_data_right = 8'b1111_1111;
     seg_data_cs = 8'b1111_1111;
     end
     endcase
     end
     endcase
end

 endmodule

