
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
    logic           CS_N;
    logic           RS;
    logic           ENABLE;
    logic           R_OR_W;
    logic   [7:0]   D_IN;
    logic   [7:0]   internal_data_bus;
    logic           write_horizontal_total_register;
    logic           write_horizontal_displayed_register;
    logic           write_horizontal_sync_position_register;
    logic           write_horizontal_sync_width_register;
    logic           write_vertical_total_register;
    logic           write_vertical_total_adjust_register;
    logic           write_vertical_displayed_register;
    logic           write_vertical_sync_position_register;
    logic           write_interlace_mode_register;
    logic           write_maximum_scan_line_register;
    logic           write_cursor_start_register;
    logic           write_cursor_end_register;
    logic           write_start_address_h_register;
    logic           write_start_address_l__register;
    logic           write_cursor_h_register;
    logic           write_cursor_l_register;
    logic           write_light_pen_h_register;
    logic           write_light_pen_l_register;
    logic           read_cursor_h_register;
    logic           read_cursor_l_register;
    logic           read_light_pen_h_register;
    logic           read_light_pen_l_register;

    KF6845_Bus_Control_Logic u_Bus_Control_Logic (.*);

    logic   [17:0]  write_regs;
    assign  write_regs[0]   = write_horizontal_total_register;
    assign  write_regs[1]   = write_horizontal_displayed_register;
    assign  write_regs[2]   = write_horizontal_sync_position_register;
    assign  write_regs[3]   = write_horizontal_sync_width_register;
    assign  write_regs[4]   = write_vertical_total_register;
    assign  write_regs[5]   = write_vertical_total_adjust_register;
    assign  write_regs[6]   = write_vertical_displayed_register;
    assign  write_regs[7]   = write_vertical_sync_position_register;
    assign  write_regs[8]   = write_interlace_mode_register;
    assign  write_regs[9]   = write_maximum_scan_line_register;
    assign  write_regs[10]  = write_cursor_start_register;
    assign  write_regs[11]  = write_cursor_end_register;
    assign  write_regs[12]  = write_start_address_h_register;
    assign  write_regs[13]  = write_start_address_l__register;
    assign  write_regs[14]  = write_cursor_h_register;
    assign  write_regs[15]  = write_cursor_l_register;
    assign  write_regs[16]  = write_light_pen_h_register;
    assign  write_regs[17]  = write_light_pen_l_register;

    logic   [3:0]   read_regs;
    assign  read_regs[0]    = read_cursor_h_register;
    assign  read_regs[1]    = read_cursor_l_register;
    assign  read_regs[2]    = read_light_pen_h_register;
    assign  read_regs[3]    = read_light_pen_l_register;


    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        CS_N            = 1'b1;
        RS              = 1'b1;
        ENABLE          = 1'b0;
        R_OR_W          = 1'b1;
        D_IN            = 8'hFF;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Write data
    //
    task TASK_WRITE_DATA(input [7:0] data, input rs);
    begin
        #(`TB_CYCLE * 0);
        CS_N            = 1'b0;
        RS              = rs;
        ENABLE          = 1'b1;
        R_OR_W          = 1'b0;
        D_IN            = data;
        #(`TB_CYCLE * 1);
        CS_N            = 1'b1;
        RS              = 1'b1;
        ENABLE          = 1'b0;
        R_OR_W          = 1'b1;
        D_IN            = 8'hFF;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : Read data
    //
    task TASK_READ_DATA(input rs);
    begin
        #(`TB_CYCLE * 0);
        CS_N            = 1'b0;
        RS              = rs;
        ENABLE          = 1'b1;
        R_OR_W          = 1'b1;
        D_IN            = 8'hFF;
        #(`TB_CYCLE * 1);
        CS_N            = 1'b1;
        RS              = 1'b1;
        ENABLE          = 1'b0;
        R_OR_W          = 1'b1;
        D_IN            = 8'hFF;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        // Write RA0
        TASK_WRITE_DATA(8'h00, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA1
        TASK_WRITE_DATA(8'h01, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA2
        TASK_WRITE_DATA(8'h02, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA3
        TASK_WRITE_DATA(8'h03, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA4
        TASK_WRITE_DATA(8'h04, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA5
        TASK_WRITE_DATA(8'h05, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA6
        TASK_WRITE_DATA(8'h06, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA7
        TASK_WRITE_DATA(8'h07, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA8
        TASK_WRITE_DATA(8'h08, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA9
        TASK_WRITE_DATA(8'h09, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA10
        TASK_WRITE_DATA(8'h0A, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA11
        TASK_WRITE_DATA(8'h0B, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA12
        TASK_WRITE_DATA(8'h0C, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA13
        TASK_WRITE_DATA(8'h0D, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);

        // Write RA14
        TASK_WRITE_DATA(8'h0E, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);
        TASK_READ_DATA(1'b1);

        // Write RA15
        TASK_WRITE_DATA(8'h0F, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);
        TASK_READ_DATA(1'b1);

        // Write RA16
        TASK_WRITE_DATA(8'h10, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);
        TASK_READ_DATA(1'b1);

        // Write RA17
        TASK_WRITE_DATA(8'h11, 1'b0);
        TASK_WRITE_DATA(8'h55, 1'b1);
        TASK_READ_DATA(1'b1);

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

