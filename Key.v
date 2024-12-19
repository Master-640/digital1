module Key(
    input clk,
    input rst,
    input [4:0] btn,
    input enable,
    input [4:0] init_hours,   // 输入初始小时
    input [5:0] init_minutes, // 输入初始分钟
    input [5:0] init_seconds, // 输入初始秒
    output reg  [7:0] seg_data,
    output reg [7:0] seg_data2,
    output reg [7:0] seg_cs,
    output reg [5:0] led1,
    output reg [4:0] modified_hours,   // 输出修改后的小时
    output reg [5:0] modified_minutes, // 输出修改后的分钟
    output reg [5:0] modified_seconds,  // 输出修改后的秒
    output reg [15:0] modified_time
);

    reg [4:0] key_vc;
    reg [4:0] key_vp;
    reg [19:0] keycnt;
    always @(posedge clk or negedge enable)
    begin
     if(!enable)
     begin
     seg_data = 8'bzzzz_zzzz;
     seg_data2 =8'bzzzz_zzzz;
     seg_cs = 8'bzzzz_zzzz;
     end
    end
    always @(posedge clk or negedge rst) begin
    //这里是不是时序逻辑和组合逻辑混用了？
        if (!rst) begin
            keycnt <= 0;
            key_vc <= 4'd0;
        end else begin
            if (keycnt >= 20'd999_999) begin
                keycnt <= 0;
                key_vc <= btn;
            end else keycnt <= keycnt + 1;
        end
    end

    always @(posedge clk) begin
        key_vp <= key_vc;
    end

    wire [4:0] key_rise_edge;
    assign key_rise_edge = (~key_vp[4:0]) & key_vc[4:0];

    // 当前时间寄存器
    reg [5:0] seconds;
    reg [5:0] minutes;
    reg [4:0] hours;
    integer statue = 0;

    reg [5:0] location = 5'b000001;
    parameter Sm = 5'b00100;   
    parameter Su = 5'b10000;   
    parameter Sd = 5'b00010;   
    parameter Sl = 5'b01000;   
    parameter Sr = 5'b00001;   

    integer timer_cnt;

    // 初始化时间
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            location <= 6'b000001;
            led1 <= 6'b111111;
            statue <= 0;
            seconds <= init_seconds; // 使用初始化时间
            minutes <= init_minutes;
            hours <= init_hours;

            modified_seconds <= init_seconds;
            modified_minutes <= init_minutes;
            modified_hours <= init_hours;

            timer_cnt <= 0;
        end else begin
            if (key_rise_edge == Sm) begin
                statue = ~statue;
                if (!statue) led1 = 6'b111111;
                else led1 = 6'b000001;
            end
            if (statue) begin
                case (key_rise_edge)
                    Sl: begin location = {location[4:0], location[5]}; led1 = location; end
                    Sr: begin location = {location[0], location[5:1]}; led1 = location; end
                    Su: case (location)
                            6'b000001: begin if (seconds >= 59) seconds = 0; else seconds = seconds + 1; end
                            6'b000100: begin if (minutes >= 59) minutes = 0; else minutes = minutes + 1; end
                            6'b010000: begin if (hours >= 23) hours = 0; else hours = hours + 1; end
                        endcase
                    Sd: case (location)
                            6'b000001: begin if (seconds == 0) seconds = 59; else seconds = seconds - 1; end
                            6'b000100: begin if (minutes == 0) minutes = 59; else minutes = minutes - 1; end
                            6'b010000: begin if (hours == 0) hours = 23; else hours = hours - 1; end
                        endcase
                endcase
            end else if (timer_cnt >= 100_000_000) begin
                timer_cnt <= 0;
                if (seconds >= 59) begin
                    seconds = 0;
                    if (minutes >= 59) begin
                        minutes = 0;
                        if (hours >= 23) hours = 0;
                        else hours = hours + 1;
                    end else minutes = minutes + 1;
                end else seconds = seconds + 1;
            end else timer_cnt <= timer_cnt + 1;

            // 更新修改后的时间输出
            modified_seconds <= seconds;
            modified_minutes <= minutes;
            modified_hours <= hours;
            modified_time <= hours * 16'd3600 +minutes*8'd60 +seconds;
            //这里是否可行?我需要询问一下
        end
    end

    reg [31:0] data;
    always @(seconds or minutes or hours) begin
        data[31:28] = (hours) / 10;
        data[27:24] = (hours) % 10;
        data[23:20] = 04'hf;
        data[19:16] = (minutes) / 10;
        data[15:12] = (minutes) % 10;
        data[11:8]  = 04'hf;
        data[7:4]   = (seconds) / 10;
        data[3:0]   = (seconds) % 10;
    end
  
    number u2(  
        .clk(clk),
        .rst(rst),
        .data(data),
        .seg_data(seg_data),
        .seg_data2(seg_data2),
        .seg_cs(seg_cs)
    );
endmodule
