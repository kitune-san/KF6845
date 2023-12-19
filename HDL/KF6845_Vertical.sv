//
// KF6845_Vertical
// Vertical Control
//
// Written by kitune-san
//
module KF6845_Vertical_Control (
    input   logic           clock,
    input   logic           video_clock_enable,
    input   logic           reset,

    // Internal data bus
    input   logic   [7:0]   internal_data_bus,
    input   logic           write_vertical_total_register,
    input   logic           write_vertical_total_adjust_register,
    input   logic           write_vertical_displayed_register,
    input   logic           write_vertical_sync_position_register,
    input   logic           write_interlace_mode_register,
    input   logic           write_maximum_scan_line_register,

    // Input
    input   logic           Horizontal,
    input   logic           Horizontal_Half,

    // Output
    output  logic   [1:0]   interlace,
    output  logic           V_total,
    output  logic           V_Display,
    output  logic           Scanline_End,
    output  logic   [4:0]   RA,
    output  logic           VSYNC
);

    //
    // Vertical total register
    //
    logic   [6:0]   vertical_total;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            vertical_total              <= 7'h00;
        else if (write_vertical_total_register)
            vertical_total              <= internal_data_bus[6:0];
        else
            vertical_total              <= vertical_total;
    end

    //
    // Vertical total adjust register
    //
    logic   [4:0]   vertical_total_adjust;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            vertical_total_adjust       <= 5'h00;
        else if (write_vertical_total_adjust_register)
            vertical_total_adjust       <= internal_data_bus[4:0];
        else
            vertical_total_adjust       <= vertical_total_adjust;
    end

    //
    // vertical displayed register
    //
    logic   [6:0]   vertical_displayed;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            vertical_displayed          <= 7'h00;
        else if (write_vertical_displayed_register)
            vertical_displayed          <= internal_data_bus[6:0];
        else
            vertical_displayed          <= vertical_displayed;
    end

    //
    // vertical sync position register
    //
    logic   [6:0]   vertical_sync_position;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            vertical_sync_position      <= 7'h3F;
        else if (write_vertical_sync_position_register)
            vertical_sync_position      <= internal_data_bus[6:0];
        else
            vertical_sync_position      <= vertical_sync_position;
    end

    //
    // interlace mode register
    //
    logic   [1:0]   interlace_mode;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            interlace_mode              <= 2'b00;
        else if (write_interlace_mode_register)
            interlace_mode              <= internal_data_bus[1:0];
        else
            interlace_mode              <= interlace_mode;
    end

    //
    // maximum scan line register
    //
    logic   [4:0]   maximum_scan_line;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            maximum_scan_line           <= 5'h00;
        else if (write_maximum_scan_line_register)
            maximum_scan_line           <= internal_data_bus[4:0];
        else
            maximum_scan_line           <= maximum_scan_line;
    end

    //
    // Scan line counter
    //
    logic   [4:0]   scan_line_counter;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            scan_line_counter           <= 5'h00;
        else if ((video_clock_enable) && (Horizontal))
            if (V_total || Scanline_End)
                scan_line_counter       <= 5'h00;
            else
                scan_line_counter       <= scan_line_counter + 5'h01;
        else
            scan_line_counter           <= scan_line_counter;
    end

    assign  Scanline_End    = video_clock_enable & Horizontal & (scan_line_counter == maximum_scan_line);

    //
    // Character row counter
    //
    logic   [6:0]   next_character_row_counter;
    logic   [6:0]   character_row_counter;
    always_comb begin
        if (V_total)
            next_character_row_counter  = 8'h00;
        else if (Scanline_End)
            next_character_row_counter  = character_row_counter + 8'h01;
        else
            next_character_row_counter  = character_row_counter;
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            character_row_counter       <= 8'h00;
        else
            character_row_counter       <= next_character_row_counter;
    end

    //
    // Interlace odd or even
    //
    logic           odd_or_even;
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            interlace                   <= 2'b00;
            odd_or_even                 <= 1'b1;
        end
        else if (V_total) begin
            interlace                   <= interlace_mode[1:0];
            if (~interlace_mode[0])
                odd_or_even             <= 1'b1;
            else
                odd_or_even             <= ~odd_or_even;
        end
        else begin
            interlace                   <= interlace;
            odd_or_even                 <= odd_or_even;
        end
    end

    //
    // V_total
    //
    logic   Vadjust;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            Vadjust                     <= 1'b0;
        else if (V_total)
            Vadjust                     <= 1'b0;
        else if (Scanline_End && (character_row_counter == vertical_total))
            Vadjust                     <= 1'b1;
        else
            Vadjust                     <= Vadjust;
    end

    always_comb begin
        if (odd_or_even)    // interlace == odd
            if (~|vertical_total_adjust)    // adjust == 0
                V_total = (character_row_counter == vertical_total);
            else                            // adjust >  0
                V_total = (Vadjust & scan_line_counter == (vertical_total_adjust-5'h01));
        else                // interlace == even
            V_total = (Vadjust & (scan_line_counter == vertical_total_adjust));

        // V_total timing
        V_total = video_clock_enable & Horizontal & V_total;
    end

    //
    // V_Display
    //
    wire wire_Vertical_End  = (next_character_row_counter == vertical_displayed);
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            V_Display                   <= 1'b0;
        else if (wire_Vertical_End)
            V_Display                   <= 1'b0;
        else if (V_total)
            V_Display                   <= 1'b1;
        else
            V_Display                   <= V_Display;
    end

    //
    // RA
    //
    wire    update_ra_timing = video_clock_enable & Horizontal;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            RA                          <= 5'h00;
        else if (V_total || Scanline_End)
            if (~interlace[0] || ~interlace[1] || ~odd_or_even) // Normal sync or Interlace sync mode || (Interlace sync and Video mode & EVEN)
                RA                      <= 5'h00;
            else                                                // Interlace sync and Video mode & ODD
                RA                      <= 5'h01;
        else if (update_ra_timing)
            if (~interlace[0] || ~interlace[1])                 // Normal sync or Interlace sync mode
                RA                      <= RA + 5'h01;
            else                                                // Interlace sync and Video mode
                RA                      <= RA + 5'h02;
        else
            RA                          <= RA;
    end

    //
    // VSYNC
    //
    logic   [4:0]   Vsync_counter;
    logic   [4:0]   increment_Vsync_counter;
    logic           Vsync_odd;
    logic           Vsync_even;

    assign  increment_Vsync_counter = Vsync_counter + 5'h1;

    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            Vsync_odd                   <= 1'b0;
            Vsync_counter               <= 5'h0;
        end
//        else if (Scanline_End)
        else if (update_ra_timing)
            if ((Scanline_End) && (next_character_row_counter == vertical_sync_position)) begin
                Vsync_odd               <= 1'b1;
                Vsync_counter           <= 5'h0;
            end
            else if (increment_Vsync_counter == 5'h10) begin
                Vsync_odd               <= 1'b0;
                Vsync_counter           <= 5'h0;
            end
            else begin
                Vsync_odd               <= Vsync_odd;
                Vsync_counter           <= increment_Vsync_counter;
            end
        else begin
            Vsync_odd                   <= Vsync_odd;
            Vsync_counter               <= Vsync_counter;
        end
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            Vsync_even                  <= 1'b0;
        else if (video_clock_enable & Horizontal_Half)
            Vsync_even                  <= Vsync_odd;
        else
            Vsync_even                  <= Vsync_even;
    end

    assign  VSYNC   = (odd_or_even) ? Vsync_odd : Vsync_even;

endmodule

