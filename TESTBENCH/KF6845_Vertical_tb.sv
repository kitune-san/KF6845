
`define TB_CYCLE        20
`define TB_FINISH_COUNT 40000

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
    logic           write_vertical_total_register;
    logic           write_vertical_total_adjust_register;
    logic           write_vertical_displayed_register;
    logic           write_vertical_sync_position_register;
    logic           write_interlace_mode_register;
    logic           write_maximum_scan_line_register;

    logic           Horizontal;
    logic           Horizontal_Half;

    logic   [1:0]   interlace;
    logic           V_Total;
    logic           V_Display;
    logic           Scanline_End;
    logic   [4:0]   RA;
    logic           VSYNC;

    KF6845_Vertical_Control  u_Vertical (.*);

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
            if (horizontal_count == 8'd10)
                horizontal_count    <= 8'h0;
            else
                horizontal_count    <= horizontal_count + 8'h1;
        else
            horizontal_count    <= horizontal_count;
    end

    assign  Horizontal       = (horizontal_count == 8'd10) & video_clock_enable;
    assign  Horizontal_Half  = (horizontal_count == 8'd5)  & video_clock_enable;


    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
            internal_data_bus                       = 8'hFF;
            write_vertical_total_register           = 1'b0;
            write_vertical_total_adjust_register    = 1'b0;
            write_vertical_displayed_register       = 1'b0;
            write_vertical_sync_position_register   = 1'b0;
            write_interlace_mode_register           = 1'b0;
            write_maximum_scan_line_register        = 1'b0;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        // Normal mode
        internal_data_bus                       = 8'd30;
        write_vertical_total_register           = 1'b1;
        #(`TB_CYCLE * 1);
        write_vertical_total_register           = 1'b0;
        #(`TB_CYCLE * 1);

        internal_data_bus                       = 8'd2;
        write_vertical_total_adjust_register    = 1'b1;
        #(`TB_CYCLE * 1);
        write_vertical_total_adjust_register    = 1'b0;
        #(`TB_CYCLE * 1);

        internal_data_bus                       = 8'd20;
        write_vertical_displayed_register       = 1'b1;
        #(`TB_CYCLE * 1);
        write_vertical_displayed_register       = 1'b0;
        #(`TB_CYCLE * 1);

        internal_data_bus                       = 8'd10;
        write_vertical_sync_position_register   = 1'b1;
        #(`TB_CYCLE * 1);
        write_vertical_sync_position_register   = 1'b0;
        #(`TB_CYCLE * 1);

        internal_data_bus                       = 8'd0;
        write_interlace_mode_register           = 1'b1;
        #(`TB_CYCLE * 1);
        write_interlace_mode_register           = 1'b0;
        #(`TB_CYCLE * 1);

        internal_data_bus                       = 8'd5;
        write_maximum_scan_line_register        = 1'b1;
        #(`TB_CYCLE * 1);
        write_maximum_scan_line_register        = 1'b0;

        #(`TB_CYCLE * 10000);

        // Interlace Sync Mode
        internal_data_bus                       = 8'd1;
        write_interlace_mode_register           = 1'b1;
        #(`TB_CYCLE * 1);
        write_interlace_mode_register           = 1'b0;

        #(`TB_CYCLE * 20000);

        // Interlace Sync and Video Mode
        internal_data_bus                       = 8'd3;
        write_interlace_mode_register           = 1'b1;
        #(`TB_CYCLE * 1);
        write_interlace_mode_register           = 1'b0;

        #(`TB_CYCLE * 20000);

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

