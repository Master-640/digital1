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
    input rst_for_turn_on,//hold_on_time���displaytime�����
    input enable_for_display,
    input rst_for_key,
    input in1, in2, in3, in4, in5,
    //������ѯʱ���ʱ���ѯʲô
    input [2:0]modify_what,
    input clean_by_hand,//���뿪����ȥ�����ֶ���ѯ
    input rst_for_time_modify1,rst_for_time_modify2,//P5�ǿյ�
    output reg light,
    output reg total_time_light,I_use_hand_clean,
    output reg show_it_close,
    output reg [7:0]seg_data_left,seg_data_right,seg_data_cs,
    output led0,led1,led2,led3,led4,led5,led6,
    output state_for_open
);
//s0����s1�˵�s2һ��s3����s4����s5�����s6��ʱ��
parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100,s5=3'b101,s6=3'b110;
    reg [7:0] selfclean_countdown=8'd5;//tmp��Ϊ�м����
    reg [15:0] total_time,tmp_time;
    reg [7:0] hurricane_countdown1;
    reg [7:0] hurricane_countdown2;
    reg [15:0] hand_gesture_countdown=16'd2;
    reg [15:0]total_time_limit=16'd2;
    //�����︳��ֵ,һ��Ҫע��˳��
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
    //ʹ��tmp��Ϊ�м��������ÿ�δ���tmp��ȥ��Ȼ���յ�tmp���ص���Ϣ����
    wire [2:0] now_state, next_state;
    wire [4:0] gesture_tmp_hour,total_tmp_hour;
    wire [5:0] total_tmp_minutes;
    wire [5:0] total_tmp_seconds,gesture_tmp_minutes,gesture_tmp_seconds;
    // �趨��ֵ
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
    
    parameter [7:0] selfclean_countdown_st = 8'd3; // ��������൹��ʱ
    parameter [7:0] hurricane_countdown1_st = 8'd10;  // ����쫷絹��ʱ1
    parameter [7:0] hurricane_countdown2_st = 8'd10;  // ����s쫷絹��ʱ2
    parameter [15:0] hand_gesture_countdown_st=16'd10;
    parameter [15:0] total_time_limit_st= 16'd10;
    // ��ʼ����ʱ��
    initial begin
     /*selfclean_countdown = selfclean_countdown_st;*/
     hurricane_countdown1 = hurricane_countdown1_st;
     hurricane_countdown2 = hurricane_countdown2_st;
  end 
    // ״̬��ʵ����
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

    // ����ʱ������
    proceed_on_clock_bps proceed(
        .clk(clk),
        .rst_n(state_for_open),//ֻ�п���֮�󣬹��ܲ�������ʵ��
        .clk_bps(clk_bps)
    );
    proceed_on_clock_aps proceed1(
        .clk(clk),
        .rst_n(state_for_open),
        .clk_bps(clk_aps)
    );
    //�����ǳ�ʼ��
    //����ʵ����������ģ��
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
    // ��������(����clkҲ��)
    always @(posedge clk) begin
        if (state_for_open&&control_light) begin
            light = 1'b1;  // ����
        end else begin
            light = 1'b0;  // �ص�
        end
    end
    //���޸�ʱ�����ʵ����
    
    //tmp������һ���м�������Ժ�ÿ�ο��԰�ֵ�����м�������ٰѶ����������
    // ��ʱ�����£�����������쫷絹��ʱ��
    //��Ҫ�����޸ģ�������һ��״̬��¼
    //now_state�ȼ�
        //�Ե������������и�ֵ���һ��Ҫ�ŵ�ͬһ��always������
        always @(posedge clk_bps) begin
            case (now_state) 
                s2, s3, s4: begin
                    total_time <= total_time + 16'b1; // ��������ֵ
                end
                s5:
                begin
                total_time <= 0;
                end
            endcase
          //total_time_limit���ǵ�ǰ���Ƶ�ֵ
            if (total_time > total_time_limit) begin
                total_time_light <= 1'b1; // ��������
                if (clean_by_hand) begin
                    I_use_hand_clean <= 1'b1; // �ֶ����
                    total_time <= 16'b0; // ���ü�ʱ��
                    total_time_light <= 1'b0; // �ر�����
                end else begin
                    I_use_hand_clean <= 1'b0;
                end
            end else begin
                total_time_light <= 1'b0; // ��������
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
        //enable for key ��Ҫ��
        Key key1(//���ֱ���������ͺ�
            .clk(clk),
            .rst(state_for_open),//��������ʾ,ΪR3,
            .rst_for_key(rst_for_key),//��R3,����ȥ����������ȥ�Ͳ���
            .btn({in2,in1,in3,in4,in5}),
            .seg_data(seg_data_right_open),
            .seg_data2(seg_data_left_open),
            .seg_cs(seg_data_cs_open)
            );
                //total_tmp_hour,total_tmp_minutes,total_tmp_seconds;
                    //gesture_tmp_hour,gesture_tmp_minutes,gesture_tmp_seconds;
                    //�һ��������initial_seconds����ȥ����0
                    //Ϊʲô���ܶ�����key��,�Ҹо�Key�ܶ�
             Time_Modifier TM1(//���Ǻ�total_time�󶨵�
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
             Time_Modifier TM2(//���Ǻ�total_time�󶨵�
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
          //enable_for_modify_time�Ǹ����ⲿ�Ĳ��뿪�ؿ��Ƶģ�query_whatҲ��
          //seg_data�ĸ�ֵһ��Ҫȫ���������棡
always @(posedge clk)//��Ҫ��clk_bps!��Ϊ��ӡ�Ǳ���ʵʱ��ӡ��.
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
     if(return_to_initial_state)//�����ť�ӵ���P5��ȥ
     begin
     //P5��ʱ��,����˵������������total_time_limit = total_time_limit_st;
     //�����������?
     total_time_limit = 16'b10;
     seg_data_left = seg_data_left_query1;
     seg_data_right = seg_data_right_query1;
     seg_data_cs = seg_data_cs_query1;
     end
     else
     begin
     total_time_limit = tmp_accepted_time1;//ע��
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
     default://������˵������ʾ�����ʱ�򣬶�����ʾ8'b0000_0000
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

