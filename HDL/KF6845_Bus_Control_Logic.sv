//
// KF6845_Bus_Control_Logic
// Data Bus Buffer & Read/Write Control Logic
//
// Written by kitune-san
//
module KF6845_Bus_Control_Logic (
    input   logic           clock,
    input   logic           reset,

    // Processor Interface
    input   logic           CS_N,
    input   logic           RS,
    input   logic           ENABLE,
    input   logic           R_OR_W,
    input   logic   [7:0]   D_IN,

    // Internal data bus
    output  logic   [7:0]   internal_data_bus,
    // Write register signals
    output  logic           write_horizontal_total_register,
    output  logic           write_horizontal_displayed_register,
    output  logic           write_horizontal_sync_position_register,
    output  logic           write_horizontal_sync_width_register,
    output  logic           write_vertical_total_register,
    output  logic           write_vertical_total_adjust_register,
    output  logic           write_vertical_displayed_register,
    output  logic           write_vertical_sync_position_register,
    output  logic           write_interlace_mode_register,
    output  logic           write_maximum_scan_line_register,
    output  logic           write_cursor_start_register,
    output  logic           write_cursor_end_register,
    output  logic           write_start_address_h_register,
    output  logic           write_start_address_l_register,
    output  logic           write_cursor_h_register,
    output  logic           write_cursor_l_register,
    output  logic           write_light_pen_h_register,
    output  logic           write_light_pen_l_register,
    // Read register signals
    output  logic           read_cursor_h_register,
    output  logic           read_cursor_l_register,
    output  logic           read_light_pen_h_register,
    output  logic           read_light_pen_l_register
);

    //
    // Latch Processor Interface Signals
    //
    logic           latch_chip_select_n;
    logic           latch_r_or_s;
    logic           latch_read_or_write;
    logic   [7:0]   latch_data;
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            latch_chip_select_n <= 1'b1;
            latch_r_or_s        <= 1'b1;
            latch_read_or_write <= 1'b1;
            latch_data          <= 8'hFF;
        end
        else begin
            latch_chip_select_n <= CS_N;
            latch_r_or_s        <= RS;
            latch_read_or_write <= R_OR_W;
            latch_data          <= D_IN;
        end
    end

    //
    // Strobe signal
    //
    logic           prev_enable;
    logic           strobe;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            prev_enable         <= 1'b0;
        else
            prev_enable         <= ENABLE;
    end
    assign  strobe  = prev_enable & ~ENABLE;

    //
    // Write signal
    //
    wire    write   = strobe      & ~latch_chip_select_n & ~latch_read_or_write;

    //
    // Read signal
    //
    wire    read    = prev_enable & ~latch_chip_select_n &  latch_read_or_write;

    //
    // Write Address Register
    //
    logic   [4:0]   address;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            address             <= 5'h00;
        else if (write & ~latch_r_or_s)
            address             <= latch_data;
        else
            address             <= address;
    end

    //
    // Internal data bus
    //
    assign  internal_data_bus   =  latch_data;

    //
    // Write Register
    //
    wire    write_register  = write & latch_r_or_s;
    assign  write_horizontal_total_register         = (write_register & (address == 5'h00));
    assign  write_horizontal_displayed_register     = (write_register & (address == 5'h01));
    assign  write_horizontal_sync_position_register = (write_register & (address == 5'h02));
    assign  write_horizontal_sync_width_register    = (write_register & (address == 5'h03));
    assign  write_vertical_total_register           = (write_register & (address == 5'h04));
    assign  write_vertical_total_adjust_register    = (write_register & (address == 5'h05));
    assign  write_vertical_displayed_register       = (write_register & (address == 5'h06));
    assign  write_vertical_sync_position_register   = (write_register & (address == 5'h07));
    assign  write_interlace_mode_register           = (write_register & (address == 5'h08));
    assign  write_maximum_scan_line_register        = (write_register & (address == 5'h09));
    assign  write_cursor_start_register             = (write_register & (address == 5'h0A));
    assign  write_cursor_end_register               = (write_register & (address == 5'h0B));
    assign  write_start_address_h_register          = (write_register & (address == 5'h0C));
    assign  write_start_address_l_register          = (write_register & (address == 5'h0D));
    assign  write_cursor_h_register                 = (write_register & (address == 5'h0E));
    assign  write_cursor_l_register                 = (write_register & (address == 5'h0F));
    assign  write_light_pen_h_register              = (write_register & (address == 5'h10));
    assign  write_light_pen_l_register              = (write_register & (address == 5'h11));

    //
    // Read Register
    //
    wire    read_register   = read & latch_r_or_s;
    assign  read_cursor_h_register                  = (read_register  & (address == 5'h0E));
    assign  read_cursor_l_register                  = (read_register  & (address == 5'h0F));
    assign  read_light_pen_h_register               = (read_register  & (address == 5'h10));
    assign  read_light_pen_l_register               = (read_register  & (address == 5'h11));

endmodule

