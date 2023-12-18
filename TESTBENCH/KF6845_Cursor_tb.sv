
`define TB_CYCLE        20
`define TB_FINISH_COUNT 200000

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
    logic   [7:0]   internal_data_bus_in;
    logic   [7:0]   internal_data_bus_out;
    logic           write_cursor_start_register;
    logic           write_cursor_end_register;
    logic           write_cursor_h_register;
    logic           write_cursor_l_register;
    logic           read_cursor_h_register;
    logic           read_cursor_l_register;

    logic           Horizontal;
    logic           Horizontal_End;
    logic           V_total;
    logic           Scanline_End;

    logic   [4:0]   RA;
    logic   [13:0]  MA;

    logic           CURSOR;

    KF6845_Cursor u_Cursor (.*);

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
        internal_data_bus_in                    = 8'hFF;
        write_cursor_start_register             = 1'b0;
        write_cursor_end_register               = 1'b0;
        write_cursor_h_register                 = 1'b0;
        write_cursor_l_register                 = 1'b0;
        read_cursor_h_register                  = 1'b0;
        read_cursor_l_register                  = 1'b0;
        RA                                      = 5'h0;
        MA                                      = 14'h0;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Initialization
    //
    task RA_COUNTUP();
    begin
        #(`TB_CYCLE * 0);
        RA                                      = 5'h0;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h1;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h2;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h3;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h4;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h5;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h6;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h7;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h8;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h9;
        #(`TB_CYCLE * 1);
        RA                                      = 5'hA;
        #(`TB_CYCLE * 1);
        RA                                      = 5'hB;
        #(`TB_CYCLE * 1);
        RA                                      = 5'hC;
        #(`TB_CYCLE * 1);
        RA                                      = 5'hD;
        #(`TB_CYCLE * 1);
        RA                                      = 5'hE;
        #(`TB_CYCLE * 1);
        RA                                      = 5'hF;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h10;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h11;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h12;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h13;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h14;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h15;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h16;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h17;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h18;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h19;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h1A;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h1B;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h1C;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h1D;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h1E;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h1F;
        #(`TB_CYCLE * 1);
        RA                                      = 5'h0;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        #(`TB_CYCLE * 10000);
        // scanline 1-10 non-blink
        internal_data_bus_in                    = 8'h01;
        write_cursor_start_register             = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'hFF;
        write_cursor_start_register             = 1'b0;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'h0A;
        write_cursor_end_register               = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'hFF;
        write_cursor_end_register               = 1'b0;
        #(`TB_CYCLE * 1);

        // cursor 0x0F12
        internal_data_bus_in                    = 8'h0F;
        write_cursor_h_register                 = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'hFF;
        write_cursor_h_register                 = 1'b0;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'h12;
        write_cursor_l_register                 = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'hFF;
        write_cursor_l_register                 = 1'b0;
        #(`TB_CYCLE * 1);

        // read cursor
        read_cursor_h_register                  = 1'b1;
        #(`TB_CYCLE * 1);
        read_cursor_h_register                  = 1'b0;
        #(`TB_CYCLE * 1);
        read_cursor_l_register                  = 1'b1;
        #(`TB_CYCLE * 1);
        read_cursor_l_register                  = 1'b0;
        #(`TB_CYCLE * 10);

        MA                                      = 14'h0;
        RA_COUNTUP();

        MA                                      = 14'hF11;
        RA_COUNTUP();

        MA                                      = 14'hF12;
        RA_COUNTUP();

        MA                                      = 14'hF13;
        RA_COUNTUP();

        // read cursor
        read_cursor_h_register                  = 1'b1;
        #(`TB_CYCLE * 1);
        read_cursor_h_register                  = 1'b0;
        #(`TB_CYCLE * 1);
        read_cursor_l_register                  = 1'b1;
        #(`TB_CYCLE * 1);
        read_cursor_l_register                  = 1'b0;
        #(`TB_CYCLE * 1);

        // scanline 1-10 non-display
        internal_data_bus_in                    = 8'h21;
        write_cursor_start_register             = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'hFF;
        write_cursor_start_register             = 1'b0;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'h0A;
        write_cursor_end_register               = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'hFF;
        write_cursor_end_register               = 1'b0;
        #(`TB_CYCLE * 1);

        MA                                      = 14'hF12;
        RA_COUNTUP();

        // scanline 1-10 blink(1/16)
        internal_data_bus_in                    = 8'h41;
        write_cursor_start_register             = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'hFF;
        write_cursor_start_register             = 1'b0;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'h0A;
        write_cursor_end_register               = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'hFF;
        write_cursor_end_register               = 1'b0;
        #(`TB_CYCLE * 1);

        MA                                      = 14'hF12;
        RA                                      = 5'h01;
        #(`TB_CYCLE * 30000);

        // scanline 1-10 blink(1/32)
        internal_data_bus_in                    = 8'h61;
        write_cursor_start_register             = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'hFF;
        write_cursor_start_register             = 1'b0;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'h0A;
        write_cursor_end_register               = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus_in                    = 8'hFF;
        write_cursor_end_register               = 1'b0;
        #(`TB_CYCLE * 1);

        MA                                      = 14'hF12;
        RA                                      = 5'h01;
        #(`TB_CYCLE * 60000);

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

