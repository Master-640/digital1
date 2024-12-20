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
    input [1:0]query_what,//������ѯʱ���ʱ���ѯʲô
    input [2:0]modify_what,
    input clean_by_hand,//���뿪����ȥ�����ֶ���ѯ
    output reg light,
    output reg total_time_light,I_use_hand_clean,
    output reg show_it_close,
    output reg [7:0]seg_data_left,seg_data_right,seg_data_cs,
    output led0,led1,led2,led3,led4,led5,led6,
    output state_for_open
);
//s0����s1�˵�s2һ��s3����s4����s5�����s6��ʱ��
parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100,s5=3'b101,s6=3'b110;
    reg [7:0] selfclean_countdown;//tmp��Ϊ�м����
    reg [15:0] total_time,tmp_time;
    reg [7:0] current_time;
    reg [5:0] hurricane_countdown1;
    reg [5:0] hurricane_countdown2;
    reg [5:0] hand_gesture_countdown;
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
    //ʹ��tmp��Ϊ�м��������ÿ�δ���tmp��ȥ��Ȼ���յ�tmp���ص���Ϣ����
    wire [2:0] now_state, next_state;
    wire [4:0] gesture_tmp_hour,total_tmp_hour;
    wire [5:0] total_tmp_minutes;
    wire [5:0] total_tmp_seconds,gesture_tmp_minutes,gesture_tmp_seconds;
    // �趨��ֵ
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
    parameter [7:0] selfclean_countdown_st = 8'd3; // ��������൹��ʱ
    parameter [5:0] hurricane_countdown1_st = 6'd3;  // ����쫷絹��ʱ1
    parameter [5:0] hurricane_countdown2_st = 6'd3;  // ����s쫷絹��ʱ2
    parameter [5:0] hand_gesture_countdown_st=6'd3;

    // ��ʼ����ʱ��
    initial begin
     assign  total_time = 8'b0;
     assign selfclean_countdown = selfclean_countdown_st;
      assign  hurricane_countdown1 = hurricane_countdown1_st;
      assign  hurricane_countdown2 = hurricane_countdown2_st;
      assign  hand_gesture_countdown  = hand_gesture_countdown_st;
  end 

    // ״̬��ʵ����
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

    // ����ʱ������
    proceed_on_clock_bps proceed(
        .clk(clk),
        .rst_n(rst_n),
        .clk_bps(clk_bps)
    );
    //�����ǳ�ʼ��
    //����ʵ����������ģ��
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
          //����д��ػ�״̬������disable�����а�ť
       //   now_state = 3'b111;
          show_it_close  =1'b0;
         // enable  = 1'b0;
       end
       else 
       begin
    //   now_state = s0;
       show_it_close = 1'b1;
       //enable = 1'b1;
       end
    end
    // ��������
    always @(posedge clk_bps) begin
        if (control_light) begin
            light = 1'b1;  // ����
        end else begin
            light = 1'b0;  // �ص�
        end
    end
    //���޸�ʱ�����ʵ����
    
    //tmp������һ���м�������Ժ�ÿ�ο��԰�ֵ�����м�������ٰѶ����������
    // ��ʱ�����£�����������쫷絹��ʱ��
    //��Ҫ�����޸ģ�������һ��״̬��¼
    
    always @(posedge clk_bps) begin
        if (return_to_initial_state) begin//��������һ�����뿪��
            // ��λʱ���³�ʼ����ʱ��
            selfclean_countdown <= selfclean_countdown_st;
            hurricane_countdown1 <= hurricane_countdown1_st;
            hurricane_countdown2 <= hurricane_countdown2_st;
            hand_gesture_countdown  = hand_gesture_countdown_st;
        end
    end
    //now_state�ȼ�
    always @(posedge clk_bps) begin//ʱ����ʾ��enable
    //enable�ź��Ǹߵ�Ƶ��Ч
            
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
        );*///���������ʾ
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
        //�����ﵽ���������always,��ɵ��Ǵ���ģʽ��ѯʱ��Ĺ���
         //number
        //����Ҫʵ��һ��total_time�������ѵĹ���
        always @(posedge clk_bps)begin
        if(total_time>= selfclean_countdown)
        begin
            total_time_light=1'b1;//������������Ѹ������
            if(clean_by_hand)//����Ұ������clear,��ôI_use_hand�����ѣ��������Ѿͻ�ص���Ȼ��I_use_hand���0
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
            //.enable(modify_what[2]);����Ӧ��Ҳ��
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
          //enable_for_modify_time�Ǹ����ⲿ�Ĳ��뿪�ؿ��Ƶģ�query_whatҲ��
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
                // ����Ӧ������ʾ���ݵ��߼���(�Ѿ����)
                // ������������һ����ʾģ������ݼĴ�����ʵ��
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
            s6:begin//����Ҫʵ����key,Ȼ����һ��enable
            if(modify_what[2])
            begin
            seg_data_cs <=seg_data_cs_modify;
            seg_data_left <= seg_data_left_modify;
            seg_data_right<=seg_data_right_modify;
            end
            case (modify_what)//����modify_what�İ�ť���ܺͿ���query_what��ͬʱ����
            3'b100:
            begin//���ﲻ����<=��ֵ����Ҫ��Ȼtmp_accepted_time��û�õ�
            //self_clean_countdown������
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
           //�������������
            endcase
            end
        endcase
    end
 endmodule

