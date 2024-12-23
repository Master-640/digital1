module countdown_timer(
    input clk,              // ʱ���ź�
    input reset,            // ��λ�ź�
    input start,            // ��ʼ����ʱ�ź�
    input [7:0] countdown,  // ����ʱ��ʼֵ
    output reg done,        // ����ʱ����ź�
    output reg [7:0] time_left // ʣ��ʱ��
);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            time_left <= 0;
            done <= 1'b0;
        end else if (start) begin
            if (time_left == 0) begin
                time_left <= countdown;
                done <= 1'b0;
            end else if (time_left == 1) begin
               // time_left <= 0;
                done <= 1'b1; // ����ʱ���
            end else begin
                time_left <= time_left - 1;  
                done <= 1'b0;
            end
        end
    end

endmodule
