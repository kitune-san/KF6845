//
// KF6845_Line_Address
// Line Address Generator
//
// Written by kitune-san
//
module KF6845_Linear_Address_Generator (
    input   logic           clock,
    input   logic           video_clock_enable,
    input   logic           reset,

    // Internal data bus
    input   logic   [7:0]   internal_data_bus,
    input   logic           write_start_address_h_register,
    input   logic           write_start_address_l_register,

    // Input
    input   logic           Horizontal,
    input   logic           Horizontal_End,
    input   logic           V_total,
    input   logic           Scanline_End,

    // Output
    output  logic   [13:0]  MA
);

    //
    // Start Address register
    //
    logic   [13:0]  start_address;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            start_address   <= 14'h0;
        else if (write_start_address_h_register)
            start_address   <= {internal_data_bus[5:0], start_address[7:0]};
        else if (write_start_address_l_register)
            start_address   <= {start_address[13:8],    internal_data_bus };
        else
            start_address   <= start_address;
    end

    //
    // Memory address
    //
    wire    [13:0]  increment_ma = MA + 14'h1;

    logic   [13:0]  retrace_ma;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            retrace_ma      <= 14'h0;
        else if (video_clock_enable)
            if (V_total)
                retrace_ma  <= start_address;
            else if (Scanline_End)
                retrace_ma  <= next_line_ma;
            else
                retrace_ma  <= retrace_ma;
        else
            retrace_ma      <= retrace_ma;
    end

    logic   [13:0]  next_line_ma;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            next_line_ma    <= 14'h0;
        else if (video_clock_enable && Horizontal_End)
            next_line_ma    <= increment_ma;
        else
            next_line_ma    <= next_line_ma;
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            MA              <= 14'h0;
        else if (video_clock_enable)
            if (V_total)
                MA          <= start_address;
            else if (Scanline_End)
                MA          <= next_line_ma;
            else if (Horizontal)
                MA          <= retrace_ma;
            else
                MA          <= increment_ma;
        else
            MA              <= MA;
    end

endmodule

