//
// KF6845
// CRT Controller
//
// Written by kitune-san
//
module KF6845 (
    input   logic           clock,
    input   logic           video_clock_enable,
    input   logic           reset,

    // Processor Interface
    input   logic           CS_N,
    input   logic           RS,
    input   logic           ENABLE,
    input   logic           R_OR_W,
    input   logic   [7:0]   D_IN,
    output  logic   [7:0]   D_OUT,

    // Light Pen Strobe
    input   logic           LPSTB,
    // Cursor
    output  logic           CURSOR,

    // CRT Control
    output  logic           HSYNC,
    output  logic           VSYNC,

    // Row Address
    output  logic   [4:0]   RA,
    // Refresh Memory Address
    output  logic   [13:0]  MA,
    // Display enable
    output  logic           DE
);

    //
    // Internal signals
    //
    logic   [7:0]   internal_data_bus;
    logic   [7:0]   internal_data_bus_out_cursor;
    logic   [7:0]   internal_data_bus_out_light_pen;
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
    logic           Horizontal;
    logic           Horizontal_Half;
    logic           Horizontal_End;
    logic           H_Display;
    logic           V_Display;
    logic   [1:0]   interlace;
    logic           V_total;
    logic           Scanline_End;
    logic           CURSOR_Buffer;
    logic           HSYNC_Buffer;
    logic           VSYNC_Buffer;
    logic   [4:0]   RA_Buffer;
    logic   [13:0]  MA_Buffer;
    logic           DE_Buffer;


    //
    // Data Bus Buffer & Read/Write Control Logic
    //
    KF6845_Bus_Control_Logic u_Bus_Control_Logic (
        .clock                                      (clock),
        .reset                                      (reset),
        .CS_N                                       (CS_N),
        .RS                                         (RS),
        .ENABLE                                     (ENABLE),
        .R_OR_W                                     (R_OR_W),
        .D_IN                                       (D_IN),
        .internal_data_bus                          (internal_data_bus),
        .write_horizontal_total_register            (write_horizontal_total_register),
        .write_horizontal_displayed_register        (write_horizontal_displayed_register),
        .write_horizontal_sync_position_register    (write_horizontal_sync_position_register),
        .write_horizontal_sync_width_register       (write_horizontal_sync_width_register),
        .write_vertical_total_register              (write_vertical_total_register),
        .write_vertical_total_adjust_register       (write_vertical_total_adjust_register),
        .write_vertical_displayed_register          (write_vertical_displayed_register),
        .write_vertical_sync_position_register      (write_vertical_sync_position_register),
        .write_interlace_mode_register              (write_interlace_mode_register),
        .write_maximum_scan_line_register           (write_maximum_scan_line_register),
        .write_cursor_start_register                (write_cursor_start_register),
        .write_cursor_end_register                  (write_cursor_end_register),
        .write_start_address_h_register             (write_start_address_h_register),
        .write_start_address_l_register             (write_start_address_l_register),
        .write_cursor_h_register                    (write_cursor_h_register),
        .write_cursor_l_register                    (write_cursor_l_register),
        .write_light_pen_h_register                 (write_light_pen_h_register),
        .write_light_pen_l_register                 (write_light_pen_l_register),
        .read_cursor_h_register                     (read_cursor_h_register),
        .read_cursor_l_register                     (read_cursor_l_register),
        .read_light_pen_h_register                  (read_light_pen_h_register),
        .read_light_pen_l_register                  (read_light_pen_l_register)
    );

    //
    // Horizontal Control
    //
    KF6845_Horizontal_Control u_Horizontal_Control (
        .clock                                      (clock),
        .video_clock_enable                         (video_clock_enable),
        .reset                                      (reset),
        .internal_data_bus                          (internal_data_bus),
        .write_horizontal_total_register            (write_horizontal_total_register),
        .write_horizontal_displayed_register        (write_horizontal_displayed_register),
        .write_horizontal_sync_position_register    (write_horizontal_sync_position_register),
        .write_horizontal_sync_width_register       (write_horizontal_sync_width_register),
        .Horizontal                                 (Horizontal),
        .Horizontal_Half                            (Horizontal_Half),
        .Horizontal_End                             (Horizontal_End),
        .H_Display                                  (H_Display),
        .HSYNC                                      (HSYNC_Buffer)
    );

    //
    // Vertical Control
    //
    KF6845_Vertical_Control u_Vertical_Control (
        .clock                                      (clock),
        .video_clock_enable                         (video_clock_enable),
        .reset                                      (reset),
        .internal_data_bus                          (internal_data_bus),
        .write_vertical_total_register              (write_vertical_total_register),
        .write_vertical_total_adjust_register       (write_vertical_total_adjust_register),
        .write_vertical_displayed_register          (write_vertical_displayed_register),
        .write_vertical_sync_position_register      (write_vertical_sync_position_register),
        .write_interlace_mode_register              (write_interlace_mode_register),
        .write_maximum_scan_line_register           (write_maximum_scan_line_register),
        .Horizontal                                 (Horizontal),
        .Horizontal_Half                            (Horizontal_Half),
        .interlace                                  (interlace),
        .V_total                                    (V_total),
        .V_Display                                  (V_Display),
        .Scanline_End                               (Scanline_End),
        .RA                                         (RA_Buffer),
        .VSYNC                                      (VSYNC_Buffer)
    );

    assign  DE_Buffer   = H_Display & V_Display;

    //
    // Linear Address Generator
    //
    KF6845_Linear_Address_Generator u_Linear_Address_Generator (
        .clock                                      (clock),
        .video_clock_enable                         (video_clock_enable),
        .reset                                      (reset),
        .internal_data_bus                          (internal_data_bus),
        .write_start_address_h_register             (write_start_address_h_register),
        .write_start_address_l_register             (write_start_address_l_register),
        .Horizontal_End                             (Horizontal_End),
        .V_total                                    (V_total),
        .Scanline_End                               (Scanline_End),
        .MA                                         (MA_Buffer)
    );

    //
    // Cursor Control
    //
    KF6845_Cursor u_Cursor (
        .clock                                      (clock),
        .video_clock_enable                         (video_clock_enable),
        .reset                                      (reset),
        .internal_data_bus_in                       (internal_data_bus),
        .internal_data_bus_out                      (internal_data_bus_out_cursor),
        .write_cursor_start_register                (write_cursor_start_register),
        .write_cursor_end_register                  (write_cursor_end_register),
        .write_cursor_h_register                    (write_cursor_h_register),
        .write_cursor_l_register                    (write_cursor_l_register),
        .read_cursor_h_register                     (read_cursor_h_register),
        .read_cursor_l_register                     (read_cursor_l_register),
        .V_total                                    (V_total),
        .RA                                         (RA_Buffer),
        .MA                                         (MA_Buffer),
        .CURSOR                                     (CURSOR_Buffer)
    );

    //
    // Light Pen Control
    //
    KF6845_Light_Pen u_Light_Pen (
        .clock                                      (clock),
        .video_clock_enable                         (video_clock_enable),
        .reset                                      (reset),
        .internal_data_bus_out                      (internal_data_bus_out_light_pen),
        .read_light_pen_h_register                  (read_light_pen_h_register),
        .read_light_pen_l_register                  (read_light_pen_l_register),
        .MA                                         (MA),
        .LPSTB                                      (LPSTB)
    );

    //
    // Data Bus
    //
    always_comb begin
        if (read_cursor_h_register)
            D_OUT   = internal_data_bus_out_cursor;
        else if (read_cursor_l_register)
            D_OUT   = internal_data_bus_out_cursor;
        else if (read_light_pen_h_register)
            D_OUT   = internal_data_bus_out_light_pen;
        else if (read_light_pen_l_register)
            D_OUT   = internal_data_bus_out_light_pen;
        else
            D_OUT   = 8'hFF;
    end

    //
    // Output signals
    //
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            CURSOR  <= 1'b0;
            HSYNC   <= 1'b0;
            VSYNC   <= 1'b0;
            RA      <= 5'h0;
            MA      <= 14'h0;
            DE      <= 1'b0;
        end
        else begin
            CURSOR  <= CURSOR_Buffer;
            HSYNC   <= HSYNC_Buffer;
            VSYNC   <= VSYNC_Buffer;
            RA      <= RA_Buffer;
            MA      <= MA_Buffer;
            DE      <= DE_Buffer;
        end
    end

endmodule

