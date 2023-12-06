//
// KF6845_Light_Pen
// Light Pen Control
//
// Written by kitune-san
//
module KF6845_Light_Pen (
    input   logic           clock,
    input   logic           video_clock_enable,
    input   logic           reset,

    // Internal data bus
    output  logic   [7:0]   internal_data_bus_out,
    input   logic           read_light_pen_h_register,
    input   logic           read_light_pen_l_register,

    // Input
    input   logic   [13:0]  MA,
    input   logic           LPSTB
);

    //
    // LPSTB edge
    //
    logic   prev_lpstb;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            prev_lpstb              <= 1'b1;
        else if (video_clock_enable)
            prev_lpstb              <= LPSTB;
        else
            prev_lpstb              <= prev_lpstb;
    end

    wire    lpstb_edge  = ~prev_lpstb & LPSTB;

    //
    // Light pen register
    //
    logic   [13:0]  light_pen;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            light_pen               <= 14'h0;
        else if (video_clock_enable & lpstb_edge)
            light_pen               <= MA;
        else
            light_pen               <= light_pen;
    end

    always_comb begin
        if (read_light_pen_h_register)
            internal_data_bus_out   = {2'b00, light_pen[13:8]};
        else if (read_light_pen_l_register)
            internal_data_bus_out   = light_pen[7:0];
        else
            internal_data_bus_out   = 8'hFF;
    end

endmodule

