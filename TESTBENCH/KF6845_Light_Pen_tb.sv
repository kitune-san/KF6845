
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
    logic   [7:0]   internal_data_bus_out;
    logic           read_light_pen_h_register;
    logic           read_light_pen_l_register;
    logic           LPSTB;
    logic   [13:0]  MA;

    KF6845_Light_Pen u_Light_Pen (.*);

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
        read_light_pen_h_register   = 1'b0;
        read_light_pen_l_register   = 1'b0;
        LPSTB                       = 1'b0;
        MA                          = 14'h0;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        #(`TB_CYCLE * 2);
        MA                          = 14'h3AA;
        LPSTB                       = 1'b1;
        #(`TB_CYCLE * 2);
        LPSTB                       = 1'b0;
        #(`TB_CYCLE * 2);

        read_light_pen_h_register   = 1'b1;
        #(`TB_CYCLE * 2);
        read_light_pen_h_register   = 1'b0;
        #(`TB_CYCLE * 2);
        read_light_pen_l_register   = 1'b1;
        #(`TB_CYCLE * 2);
        read_light_pen_l_register   = 1'b0;
        #(`TB_CYCLE * 2);

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

