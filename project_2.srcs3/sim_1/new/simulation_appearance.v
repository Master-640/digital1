module signal_generator;
    reg seg_data_left;
    reg seg_data_right;
    reg seg_data_cs;
    reg clk;

    // Clock generation (10ns period)
    always begin
        #5 clk = ~clk; // 10ns clock period
    end

    // Initialize the signals
    initial begin
        // Initial values
        seg_data_left = 0;
        seg_data_right = 0;
        seg_data_cs = 0;
        clk = 0;

        // Generate signals
        #10 seg_data_left = 1;
        #20 seg_data_right = 1;
        #30 seg_data_cs = 1; // Enable signal active
        #40 seg_data_left = 0;
        #50 seg_data_right = 0;
        #60 seg_data_cs = 0; // Disable signal

        // More dynamic changes in signals
        #100 seg_data_left = 1;
        #150 seg_data_right = 1;
        #200 seg_data_cs = 1;

        // End the simulation
        #300 $finish;
    end
endmodule