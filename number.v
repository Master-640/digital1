module number(
    input enable,
    input clk,
    input rst,
    input [5:0] modified_hours,   // �޸ĺ��Сʱ
    //�����5:0�Ҹĳ�4:0��������
    input [5:0] modified_minutes, // �޸ĺ�ķ���
    input [5:0] modified_seconds, // �޸ĺ����
    output reg [7:0] seg_data,    // �������ʾ������
    output reg [7:0] seg_data2,   // �ڶ����������ʾ������
    output reg [7:0] seg_cs       // ����ܿ����ź�
);
   //���enable���У���ô���ģ����Ч  
    reg clk_500hz;
    integer clk_cnt;
    // ����500Hzʱ���ź�����ɨ�������
    always @(posedge clk or negedge enable)
    begin
        if(!enable)
        begin
            seg_data = 8'bzzzz_zzzz;
            seg_data2 = 8'bzzzz_zzzz;
            seg_cs= 8'bzzzz_zzzz;
          end
    end
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            clk_500hz <= 0;
            clk_cnt <= 0;
        end else begin
            if (clk_cnt >= 100_000) begin
                clk_cnt <= 0;
                clk_500hz <= ~clk_500hz;
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end
    end

    // �����ɨ����ƣ���˳����ʾÿһλ����
    always @(posedge clk_500hz or negedge rst) begin
        if (!rst) begin
            seg_cs <= 8'b00000001;
        end else begin
            seg_cs <= {seg_cs[6:0], seg_cs[7]};
        end
    end

    // ��Сʱ�����ӡ���ת��Ϊ��Ӧ���������ʾ����
    reg [7:0] dis_data;
    always @(seg_cs) begin
        case (seg_cs)
            8'b00000001: dis_data = {4'b0000, modified_seconds % 10};  // ���λ
            8'b00000010: dis_data = {4'b0000, modified_seconds / 10};  // ��ʮλ
            8'b00000100: dis_data = {4'b0000, modified_minutes % 10};  // �ָ�λ
            8'b00001000: dis_data = {4'b0000, modified_minutes / 10};  // ��ʮλ
            8'b00010000: dis_data = {4'b0000, modified_hours % 10};    // Сʱ��λ
            8'b00100000: dis_data = {4'b0000, modified_hours / 10};    // Сʱʮλ
            default: dis_data = 8'h40;  // ���������ʾ�հ�
        endcase
    end

    // ���ֵ��߶���ʾ��ת��
    always @(dis_data) begin
        case (dis_data[3:0])
            4'h0: seg_data = 8'h3F;
            4'h1: seg_data = 8'h06;
            4'h2: seg_data = 8'h5B;
            4'h3: seg_data = 8'h4F;
            4'h4: seg_data = 8'h66;
            4'h5: seg_data = 8'h6D;
            4'h6: seg_data = 8'h7D;
            4'h7: seg_data = 8'h07;
            4'h8: seg_data = 8'h7F;
            4'h9: seg_data = 8'h6F;
            4'hA: seg_data = 8'h77;
            4'hB: seg_data = 8'h7C;
            4'hC: seg_data = 8'h39;
            4'hD: seg_data = 8'h5E;
            4'hE: seg_data = 8'h79;
            4'hF: seg_data = 8'h40;
            default: seg_data = 8'h40;
        endcase

        case (dis_data[7:4])
            4'h0: seg_data2 = 8'h3F;
            4'h1: seg_data2 = 8'h06;
            4'h2: seg_data2 = 8'h5B;
            4'h3: seg_data2 = 8'h4F;
            4'h4: seg_data2 = 8'h66;
            4'h5: seg_data2 = 8'h6D;
            4'h6: seg_data2 = 8'h7D;
            4'h7: seg_data2 = 8'h07;
            4'h8: seg_data2 = 8'h7F;
            4'h9: seg_data2 = 8'h6F;
            4'hA: seg_data2 = 8'h77;
            4'hB: seg_data2 = 8'h7C;
            4'hC: seg_data2 = 8'h39;
            4'hD: seg_data2 = 8'h5E;
            4'hE: seg_data2 = 8'h79;
            4'hF: seg_data2 = 8'h40;
            default: seg_data2 = 8'h40;
        endcase
    end

endmodule
