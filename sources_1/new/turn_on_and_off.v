`timescale 1ns / 1ps

module turn_on_and_off(
    input clk,
    input rst,
    input power_button,  // ���ػ�����
    input left_button,
    input right_button,
    output reg power_status, // ���ػ�״̬ (1: ����, 0: �ػ�)
    output [7:0] selection,
    output [7:0] left_time,
    output [7:0] right_time
);
    parameter LONG_PRESS_TIME = 300_000_000; // ���� 3 �� (���� 100 MHz ʱ��)
    parameter DEBOUNCE_TIME = 20_000_000;    // ȥ����ʱ 200 ms
    parameter COUNTDOWN_TIME = 500_000_000;  // 5 �뵹��ʱ

    // �ڲ��ź�
    wire button_stable;     // ȥ����İ����ź�
    wire left_stable;       // ȥ���������ź�
    wire right_stable;      // ȥ������Ҽ��ź�
    reg [28:0] counter;     // ����������
    reg [28:0] countdown;   // ����ʱ������
    reg countdown_active;   // ����ʱ�����־
    reg is_long_press;      // ������־
    reg button_prev;        // ��һ�ΰ���״̬
    reg left_prev, right_prev;
    
    

    // ȥ��ģ��
    debouncer #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) db_power (
        .clk(clk),
        .rst(rst),
        .button_in(power_button),
        .button_out(button_stable)
    );

    debouncer #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) db_left (
        .clk(clk),
        .rst(rst),
        .button_in(left_button),
        .button_out(left_stable)
    );

    debouncer #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) db_right (
        .clk(clk),
        .rst(rst),
        .button_in(right_button),
        .button_out(right_stable)
    );
    //��Ҫ����������ģ��Ҳ����ȥ������
    // ���߼�
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            power_status <= 0; // ��ʼ״̬Ϊ�ػ�
            counter <= 0;
            is_long_press <= 0;
            countdown <= 0;
            countdown_active <= 0;
            button_prev <= 0;
            left_prev <= 0;
            right_prev <= 0;
        end else begin
            // �̰�/�����߼�
            if (button_stable) begin
                if (counter < LONG_PRESS_TIME) begin
                    counter <= counter + 1; // ��������
                end else begin
                    is_long_press <= 1; // ���Ϊ����
                end
            end else begin
                if (button_prev && !is_long_press) begin
                    power_status <= 1'b1; // �̰�����
                end else if (is_long_press) begin
                    power_status <= 1'b0; // �����ػ�
                end
                counter <= 0;
                is_long_press <= 0;
            end

            // �����߼�
            if (!power_status) begin // �ػ�״̬
                if (left_stable && !left_prev) begin
                    countdown_active <= 1;
                    countdown <= 0;
                end
                if (countdown_active && right_stable && !right_prev) begin
                    power_status <= 1; // ��� + �Ҽ� ����
                    countdown_active <= 0;
                    countdown <= 0;
                end
            end else begin // ����״̬
                if (right_stable && !right_prev) begin
                    countdown_active <= 1;
                    countdown <= 0;
                end
                if (countdown_active && left_stable && !left_prev) begin
                    power_status <= 0; // �Ҽ� + ��� �ػ�
                    countdown_active <= 0;
                    countdown <= 0;
                end
            end

            // ����ʱ�߼�
            if (countdown_active) begin
                if (countdown < COUNTDOWN_TIME) begin
                    countdown <= countdown + 1;
                end else begin
                    countdown_active <= 0; // ����ʱ����
                    countdown <= 0;
                end
            end

            // ���°���״̬
            button_prev <= button_stable;
            left_prev <= left_stable;
            right_prev <= right_stable;
        end
    end
    
endmodule


// ȥ��ģ��
module debouncer #(
    parameter DEBOUNCE_TIME = 20_000_000 // ȥ����ʱ (Ĭ�� 200 ms)
)(
    input clk,
    input rst,
    input button_in,
    output reg button_out
);
    reg [24:0] counter;  // ȥ��������
    reg button_sync;     // ͬ����İ����ź�

    always @(posedge clk or negedge rst) begin
        if (!rst) begin//rst�Ǹ�λ
            counter <= 0;
            button_sync <= 0;
            button_out <= 0;
        end else begin
            button_sync <= button_in;
            if (button_sync == button_out) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;//�൱��button_sync���źŹ���һ���ٶ���
                if (counter >= DEBOUNCE_TIME) begin
                    button_out <= button_sync;
                    counter <= 0;
                end
            end
        end
    end
endmodule


module light_7seg_tube(input [3:0] sw, input rst, input clk, output reg [7:0] seg_out, output reg [7:0] seg_en);
    reg [2:0] scan_cnt;

    always @(negedge rst or posedge clk) begin
        if (~rst) scan_cnt <= 3'b000;
        else begin
            if (scan_cnt == 3'd7) scan_cnt <= 0;
            else scan_cnt <= scan_cnt + 1;
        end
    end
    
    always @ (scan_cnt) begin
        case (scan_cnt)
        3'b000 : seg_en = 8'h01;
        3'b001 : seg_en = 8'h02;
        3'b010 : seg_en = 8'h04;
        3'b011 : seg_en = 8'h08;
        3'b100 : seg_en = 8'h10;
        3'b101 : seg_en = 8'h20;
        3'b110 : seg_en = 8'h40;
        3'b111 : seg_en = 8'h80;
        default: seg_en = 8'h00;  
        endcase
    end
      
    always @(sw)
        case (sw)
            4'h0: seg_out = 8'b1111_1100;  // 0
            4'h1: seg_out = 8'b0110_0000;  // 1
            4'h2: seg_out = 8'b1101_1010;  // 2
            4'h3: seg_out = 8'b1111_0010;  // 3
            4'h4: seg_out = 8'b0110_0110;  // 4
            4'h5: seg_out = 8'b1011_0110;  // 5
            4'h6: seg_out = 8'b1011_1110;  // 6
            4'h7: seg_out = 8'b1110_0000;  // 7
            4'h8: seg_out = 8'b1111_1110;  // 8
            4'h9: seg_out = 8'b1110_0110;  // 9
            4'ha: seg_out = 8'b1110_1110;  // A
            4'hb: seg_out = 8'b0011_1110;  // B
            4'hc: seg_out = 8'b1001_1100;  // C
            4'hd: seg_out = 8'b0111_1010;  // D
            4'he: seg_out = 8'b1001_1110;  // E
            4'hf: seg_out = 8'b1000_1110;  // F
            default: seg_out = 8'b0000_0001;
        endcase
endmodule
