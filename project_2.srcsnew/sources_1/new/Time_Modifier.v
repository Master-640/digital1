`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////


module Time_Modifier(

    input   clk,                      // ʱ���ź�����

    input   rst,                      // �����ź�����

    input   [5:0] initial_second,     // ��ʼ��������

    input   [5:0] initial_minutes,    // ��ʼ��������

    input   [4:0] initial_hours,      // ��ʼСʱ����
     
    input  [2:0]state,
    
    output  reg [5:0] seconds,        // ����޸ĺ�����

    output  reg [5:0] minutes,        // ����޸ĺ����

    output  reg [4:0] hours,          // ����޸ĺ�Сʱ

    input   [4:0] btn,                // ��ť����
     
    
    output  [7:0] seg_data,           // ���Ӻ������ʾ����

    output  [7:0] seg_data2,          // Сʱ����ʾ����

    output  [7:0] seg_cs              // ��ʾλ�ÿ����ź�
   
);

    reg [4:0] key_vc;                 // ��ǰ��ť״̬

    reg [4:0] key_vp;                 // ��ǰ��ť״̬

    reg [19:0] keycnt;                // ��ť����������

    // ��ť��Ե���

    wire [4:0] key_rise_edge;

    assign key_rise_edge = (~key_vp) & key_vc; // ���������

    // ��ť��������

    parameter Sm = 5'b00100;          // �м䰴ť

    parameter Su = 5'b10000;          // ���Ӱ�ť

    parameter Sd = 5'b00010;          // ���ٰ�ť

    parameter Sl = 5'b01000;          // ���ư�ť

    parameter Sr = 5'b00001;          // ���ư�ť

    // ʱ���ʼ��
    always @(posedge clk)
    begin
       
    end
   

    reg [5:0] location = 5'b000001;   // ��ǰλ��

    // ��ť״̬���£���������

    always @(posedge clk or negedge rst) begin

        if (!rst) begin

            keycnt <= 0;               // ��λ������

            key_vc <= 5'b0;            // ��λ��ǰ��ť״̬

        end else begin

            if (keycnt >= 20'd999_999) begin

                keycnt <= 0;            // �ﵽ�������ޣ���λ������

                key_vc <= btn;          // ���µ�ǰ��ť״̬

            end else begin

                keycnt <= keycnt + 1;   // ���Ӽ�����

            end

        end

    end

    // ������ǰ��ťֵ

    always @(posedge clk) begin

        key_vp <= key_vc;              // ����ǰ״̬��Ϊ��ǰ״̬

    end

    // ʹ�ð�ť����ʱ����߼�
   // ���ʹ��Time_Modifier,���P5;��ʹ����ر�P5;
    always @(posedge clk or negedge rst) begin //�������rst_for_time_modify(P5);

        if (!rst) begin

            seconds <= seconds;  // ͣ������

            minutes <= minutes;  // ��λ����

            hours   <= hours;    // ��λСʱ

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
                    location[5:0] = {location[4:0], location[5]}; // ���ƶ��༭λ��
                end

                Sr: begin
                    location[5:0] = {location[0], location[5:1]}; // ���ƶ��༭λ��
                end

                Su: // ����ʱ��
                    case(location)
                        6'b000001: begin // ��ĸ�λ
                            if(seconds >= 59) begin 
                              seconds = 0; 
                                if(minutes >= 59) begin 
                                    minutes = 0; 
                                    hours = 0; 
                                end else minutes = minutes + 1; 
                            end else seconds = seconds + 1; 
                        end

                        6'b000010: begin // ���ʮλ
                            if(seconds / 10 >= 5) begin 
                                seconds = seconds % 10; 
                                if(minutes >= 59) begin 
                                    minutes = 0; 
                                    hours = 0; 
                                end else minutes = minutes + 1; 
                            end else seconds = seconds + 10; 
                        end

                        6'b000100: begin // ���ӵĸ�λ
                            if(minutes >= 59) begin 
                                minutes = 0; 
                                if(hours >= 23) hours = 0; 
                                else hours = hours + 1; 
                            end else minutes = minutes + 1; 
                        end

                        6'b001000: begin // ���ӵ�ʮλ
                            if(minutes / 10 >= 5) begin 
                                minutes = minutes % 10; 
                                if(hours >= 23) hours = 0; 
                                else hours = hours + 1; 
                            end else minutes = minutes + 10; 
                        end

                        6'b010000: begin // Сʱ�ĸ�λ
                            if(hours >= 23) begin 
                                hours = 0; 
                            end else hours = hours + 1; 
                        end

                        6'b100000: begin // Сʱ��ʮλ
                            if(hours / 10 >= 2) begin 
                                hours = hours % 10; 
                            end else begin 
                                hours = hours + 10; 
                                if(hours > 23) hours = 23; 
                            end 
                        end
                    endcase  

                Sd: // ����ʱ��
                    case(location) 
                        6'b000001: begin // ��ĸ�λ
                            if(seconds == 0) begin 
                                seconds = 59; 
                                if(minutes == 0) begin 
                                    minutes = 59; 
                                    hours = 23; 
                                end else minutes = minutes - 1; 
                            end else seconds = seconds - 1; 
                        end

                        6'b000010: begin // ���ʮλ
                            if(seconds / 10 == 0) begin 
                                seconds = seconds % 10 + 50; 
                                if(minutes == 0) begin 
                                    minutes = 59; 
                                    hours = 23; 
                                end else minutes = minutes - 1; 
                            end else seconds = seconds - 10; 
                        end

                        6'b000100: begin // ���ӵĸ�λ
                            if(minutes == 0) begin 
                                minutes = 59; 
                                if(hours == 0) hours = 23; 
                                else hours = hours - 1; 
                            end else minutes = minutes - 1; 
                        end

                        6'b001000: begin // ���ӵ�ʮλ
                            if(minutes / 10 == 0) begin 
                                minutes = minutes % 10 + 50; 
                                if(hours == 0) hours = 23; 
                                else hours = hours - 1; 
                            end else minutes = minutes - 10; 
                        end

                        6'b010000: begin // Сʱ�ĸ�λ
                            if(hours == 0) begin 
                                hours = 23; 
                            end else hours = hours - 1; 
                        end

                        6'b100000: begin // Сʱ��ʮλ
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
        data[31:28] = hours / 10;     // Сʱʮλ
        data[27:24] = hours % 10;     // Сʱ��λ
        data[23:20] = 4'hF;           // �ָ���
        data[19:16] = minutes / 10;   // ����ʮλ
        data[15:12] = minutes % 10;   // ���Ӹ�λ
        data[11:8]  = 4'hF;           // �ָ���
        data[7:4]   = seconds / 10;   // ����ʮλ
        data[3:0]   = seconds % 10;   // ���Ӹ�λ
    end

    // ��ʾ����

    number u2(
        .clk(clk),
        .rst(rst),
        .data(data),
        .seg_data(seg_data),
        .seg_data2(seg_data2),
        .seg_cs(seg_cs)
    );

endmodule
