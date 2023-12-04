
`define TB_CYCLE        20
`define TB_FINISH_COUNT 20000

module tb();

    timeunit        1ns;
    timeprecision   10ps;

    //
    // Generate wave file to check
    //
`ifdef IVERILOG
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end
`endif

    //
    // Generate clock
    //
    logic   clock;
    initial clock = 1'b0;
    always #(`TB_CYCLE / 2) clock = ~clock;

    //
    // Generate reset
    //
    logic reset;
    initial begin
        reset = 1'b1;
            # (`TB_CYCLE * 10)
        reset = 1'b0;
    end

    //
    // Cycle counter
    //
    logic   [31:0]  tb_cycle_counter;
    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            tb_cycle_counter <= 32'h0;
        else
            tb_cycle_counter <= tb_cycle_counter + 32'h1;
    end

    always_comb begin
        if (tb_cycle_counter == `TB_FINISH_COUNT) begin
            $display("***** SIMULATION TIMEOUT ***** at %d", tb_cycle_counter);
`ifdef IVERILOG
            $finish;
`elsif MODELSIM
            $stop;
`else
            $finish;
`endif
        end
    end

    //
    // Module under test
    //
    logic           video_clock_enable;
    logic   [7:0]   internal_data_bus;
    logic           write_start_address_h_register;
    logic           write_start_address_l_register;

    logic           Horizontal;
    logic           Horizontal_End;
    logic           V_total;
    logic           Scanline_End;

    logic   [13:0]  MA;

    KF6845_Linear_Address_Generator u_Line_Address (.*);

    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            video_clock_enable  <= 1'b0;
        else
            video_clock_enable  <= ~video_clock_enable;
    end

    logic   [7:0]   horizontal_count;
    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            horizontal_count    <= 8'h0;
        else if (video_clock_enable)
            if (V_total)
                horizontal_count    <= 8'h0;
            else if (horizontal_count == 8'd10)
                horizontal_count    <= 8'h0;
            else
                horizontal_count    <= horizontal_count + 8'h1;
        else
            horizontal_count    <= horizontal_count;
    end

    assign  Horizontal       = (horizontal_count == 8'd10) & video_clock_enable;
    assign  Horizontal_End   = (horizontal_count == 8'd5)  & video_clock_enable;

    logic   [7:0]   line_count;
    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            line_count          <= 8'h0;
        else if (Scanline_End)
            line_count          <= 8'h0;
        else if (Horizontal)
            line_count          <= line_count + 8'h1;
        else
            line_count          <= line_count;
    end
    assign  Scanline_End    = (line_count == 8'd3) && Horizontal;

    logic   [7:0]   row_count;
    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            row_count           <= 8'h0;
        else if (V_total)
            row_count           <= 8'h0;
        else if (Scanline_End)
            row_count           <= row_count + 8'h1;
        else
            row_count           <= row_count;
    end
    assign  V_total         = (row_count == 8'd5) && Horizontal;

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
            internal_data_bus                       = 8'hFF;
            write_start_address_h_register          = 1'b0;
            write_start_address_l_register          = 1'b0;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        internal_data_bus                       = 8'hAA;
        write_start_address_h_register          = 1'b1;
        #(`TB_CYCLE * 1);
        write_start_address_h_register          = 1'b0;
        #(`TB_CYCLE * 1);

        internal_data_bus                       = 8'h55;
        write_start_address_l_register          = 1'b1;
        #(`TB_CYCLE * 1);
        write_start_address_l_register          = 1'b0;

        #(`TB_CYCLE * 10000);

        // End of simulation
`ifdef IVERILOG
        $finish;
`elsif  MODELSIM
        $stop;
`else
        $finish;
`endif
    end

endmodule

