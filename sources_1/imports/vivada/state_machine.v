module state_machine(
    input enable, in1, in2, in3, in4, in5,
    input clk,
    input clk_bps,
    input [5:0] hurricane_countdown1,
    input [5:0] hurricane_countdown2,
    input [7:0] selfclean_countdown,
    output reg [2:0] state, next_state,
    output reg led0, led1, led2, led3, led4, led5, led6
);

parameter s0 = 3'b000, s1 = 3'b001, s2 = 3'b010, s3 = 3'b011, 
          s4 = 3'b100, s5 = 3'b101, s6 = 3'b110;

wire [5:0] in;
assign in = {enable, in1, in2, in3, in4, in5};

// ����ʱ�ź�
reg start_hurricane_timer1 = 0;
reg start_hurricane_timer2 = 0;
reg start_selfclean_timer = 0;

wire hurricane_done1, hurricane_done2, selfclean_done;
wire [7:0] hurricane_time_left1, hurricane_time_left2, selfclean_time_left;

// ���õ���ʱģ��
countdown_timer hurricane_timer1(
    .clk(clk_bps),
    .reset(state != s4), // ���״̬�뿪s4����λ
    .start(start_hurricane_timer1),
    .countdown(hurricane_countdown1),
    .done(hurricane_done1),
    .time_left(hurricane_time_left1)
);

countdown_timer hurricane_timer2(
    .clk(clk_bps),
    .reset(state != s4), // ���״̬�뿪s4����λ
    .start(start_hurricane_timer2),
    .countdown(hurricane_countdown2),
    .done(hurricane_done2),
    .time_left(hurricane_time_left2)
);

countdown_timer selfclean_timer(
    .clk(clk_bps),
    .reset(state != s5), // ���״̬�뿪s5����λ
    .start(start_selfclean_timer),
    .countdown(selfclean_countdown),
    .done(selfclean_done),
    .time_left(selfclean_time_left)
);

reg hurricane_used = 1'b1;
reg back_to_standby = 1'b0;

always @(posedge clk_bps) begin
    state <= next_state;
end

always @* begin
    // Ĭ�ϲ���������ʱ
    start_hurricane_timer1 = 0;
    start_hurricane_timer2 = 0;
    start_selfclean_timer = 0;

    case (state)
        s0: begin // ����ģʽ
            case (in)
                6'b110000: next_state = s1; // �˵������л�ģʽ
                6'b101000: next_state = s6; // ��ʱ��
                default: next_state = s0;
            endcase
        end
        s1: begin // �˵�ģʽ
            case (in)
                6'b101000: next_state = s2; // һ��
                6'b100100: next_state = s3; // ����
                6'b100010: begin
                    if (hurricane_used) begin
                        next_state = s4; // ������쫷�ģʽ��
                        hurricane_used = 1'b0;
                        start_hurricane_timer1 = 1; // ��ʼ쫷絹��ʱ
                    end
                end
                6'b100001: begin
                    next_state = s5; // �����
                    start_selfclean_timer = 1; // ��ʼ����൹��ʱ
                end
                default: next_state = s1;
            endcase
        end
        s2: begin // һ��
            case (in)
                6'b110000: next_state = s1; // �˵��������ش���ģʽ
                6'b100100: next_state = s3;//2��
                default: next_state = s2;
            endcase
        end
        s3: begin // ����
            case (in)
                6'b110000: next_state = s1; // �˵��������ش���ģʽ
                6'b101000: next_state = s2;//1��
                default: next_state = s3;
            endcase
        end
        s4: begin // ������쫷�ģʽ��
            if (in==6'b110000)begin
                back_to_standby=1'b1;
                start_hurricane_timer2=1'b1;
            end
            if (!start_hurricane_timer2 && hurricane_done1) begin
                    next_state = s3; // �ص�����
            end else if(start_hurricane_timer2 && hurricane_done2) begin
                    next_state=s0;
            end
            else begin
                next_state = s4; // ��������ʱ
            end
        end
        s5: begin // �����ģʽ
            if (selfclean_done) begin
                next_state = s0; // ���ش���
            end else begin
                next_state = s5;
            end
        end
        s6: begin // ��ʱ��
            next_state = (in == 6'b110000) ? s0 : s6; // ���ش���
        end
        default: next_state = s0;
    endcase
end

always @(state) begin
    led0 = (state == s0);
    led1 = (state == s1);
    led2 = (state == s2);
    led3 = (state == s3);
    led4 = (state == s4);
    led5 = (state == s5);
    led6 = (state == s6);
end

endmodule
