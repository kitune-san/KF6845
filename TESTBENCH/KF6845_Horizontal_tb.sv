
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
    logic           write_horizontal_total_register;
    logic           write_horizontal_displayed_register;
    logic           write_horizontal_sync_position_register;
    logic           write_horizontal_sync_width_register;
    logic           Horizontal;
    logic           Horizontal_Half;
    logic           Horizontal_End;
    logic           H_Display;
    logic           HSYNC;

    KF6845_Horizontal_Control  u_Horizontal (.*);

    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            video_clock_enable  <= 1'b0;
        else
            video_clock_enable  <= ~video_clock_enable;
    end

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
            internal_data_bus                       = 8'hFF;
            write_horizontal_total_register         = 1'b0;
            write_horizontal_displayed_register     = 1'b0;
            write_horizontal_sync_position_register = 1'b0;
            write_horizontal_sync_width_register    = 1'b0;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();

        internal_data_bus                       = 8'd100;
        write_horizontal_total_register         = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus                       = 8'hFF;
        write_horizontal_total_register         = 1'b0;
        #(`TB_CYCLE * 1);

        internal_data_bus                       = 8'd60;
        write_horizontal_displayed_register     = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus                       = 8'hFF;
        write_horizontal_displayed_register     = 1'b0;
        #(`TB_CYCLE * 1);

        internal_data_bus                       = 8'd70;
        write_horizontal_sync_position_register = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus                       = 8'hFF;
        write_horizontal_sync_position_register = 1'b0;
        #(`TB_CYCLE * 1);

        internal_data_bus                       = 8'd10;
        write_horizontal_sync_width_register    = 1'b1;
        #(`TB_CYCLE * 1);
        internal_data_bus                       = 8'hFF;
        write_horizontal_sync_width_register    = 1'b0;
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

