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

// 倒计时信号
reg start_hurricane_timer1 = 0;
reg start_hurricane_timer2 = 0;
reg start_selfclean_timer = 0;

wire hurricane_done1, hurricane_done2, selfclean_done;
wire [7:0] hurricane_time_left1, hurricane_time_left2, selfclean_time_left;

// 调用倒计时模块
countdown_timer hurricane_timer1(
    .clk(clk_bps),
    .reset(state != s4), // 如果状态离开s4，则复位
    .start(start_hurricane_timer1),
    .countdown(hurricane_countdown1),
    .done(hurricane_done1),
    .time_left(hurricane_time_left1)
);

countdown_timer hurricane_timer2(
    .clk(clk_bps),
    .reset(state != s4), // 如果状态离开s4，则复位
    .start(start_hurricane_timer2),
    .countdown(hurricane_countdown2),
    .done(hurricane_done2),
    .time_left(hurricane_time_left2)
);

countdown_timer selfclean_timer(
    .clk(clk_bps),
    .reset(state != s5), // 如果状态离开s5，则复位
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
    // 默认不启动倒计时
    start_hurricane_timer1 = 0;
    start_hurricane_timer2 = 0;
    start_selfclean_timer = 0;

    case (state)
        s0: begin // 待机模式
            case (in)
                6'b110000: next_state = s1; // 菜单键，切换模式
                6'b101000: next_state = s6; // 调时间
                default: next_state = s0;
            endcase
        end
        s1: begin // 菜单模式
            case (in)
                6'b101000: next_state = s2; // 一档
                6'b100100: next_state = s3; // 二档
                6'b100010: begin
                    if (hurricane_used) begin
                        next_state = s4; // 三档（飓风模式）
                        hurricane_used = 1'b0;
                        start_hurricane_timer1 = 1; // 开始飓风倒计时
                    end
                end
                6'b100001: begin
                    next_state = s5; // 自清洁
                    start_selfclean_timer = 1; // 开始自清洁倒计时
                end
                default: next_state = s1;
            endcase
        end
        s2: begin // 一档
            case (in)
                6'b110000: next_state = s1; // 菜单键，返回待机模式
                6'b100100: next_state = s3;//2档
                default: next_state = s2;
            endcase
        end
        s3: begin // 二档
            case (in)
                6'b110000: next_state = s1; // 菜单键，返回待机模式
                6'b101000: next_state = s2;//1档
                default: next_state = s3;
            endcase
        end
        s4: begin // 三档（飓风模式）
            if (in==6'b110000)begin
                back_to_standby=1'b1;
                start_hurricane_timer2=1'b1;
            end
            if (!start_hurricane_timer2 && hurricane_done1) begin
                    next_state = s3; // 回到二档
            end else if(start_hurricane_timer2 && hurricane_done2) begin
                    next_state=s0;
            end
            else begin
                next_state = s4; // 继续倒计时
            end
        end
        s5: begin // 自清洁模式
            if (selfclean_done) begin
                next_state = s0; // 返回待机
            end else begin
                next_state = s5;
            end
        end
        s6: begin // 调时间
            next_state = (in == 6'b110000) ? s0 : s6; // 返回待机
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
