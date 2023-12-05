//
// KF6845_Cursor
// Cursor Control
//
// Written by kitune-san
//
module KF6845_Cursor (
    input   logic           clock,
    input   logic           video_clock_enable,
    input   logic           reset,

    // Internal data bus
    input   logic   [7:0]   internal_data_bus_in,
    output  logic   [7:0]   internal_data_bus_out,
    input   logic           write_cursor_start_register,
    input   logic           write_cursor_end_register,
    input   logic           write_cursor_h_register,
    input   logic           write_cursor_l_register,
    input   logic           read_cursor_h_register,
    input   logic           read_cursor_l_register,

    // Input
    input   logic           V_total,
    input   logic   [4:0]   RA,
    input   logic   [13:0]  MA,

    // Output
    output  logic   [13:0]  CURSOR
);

    //
    // Cursor start register
    //
    logic   [1:0]   blink_config;
    logic   [4:0]   cursor_start;
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            blink_config            <= 2'h0;
            cursor_start            <= 5'h0;
        end
        else if (write_cursor_start_register) begin
            blink_config            <= internal_data_bus_in[6:5];
            cursor_start            <= internal_data_bus_in[4:0];
        end
        else begin
            blink_config            <= blink_config;
            cursor_start            <= cursor_start;
        end
    end

    //
    // Cursor end register
    //
    logic   [4:0]   cursor_end;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            cursor_end              <= 5'h0;
        else if (write_cursor_end_register)
            cursor_end              <= internal_data_bus_in[4:0];
        else
            cursor_end              <= cursor_end;

    end

    //
    // Cursor address register
    //
    logic   [13:0]  cursor_address;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            cursor_address          <= 14'h0;
        else if (write_cursor_h_register)
            cursor_address          <= {internal_data_bus_in[5:0], cursor_address[7:0]};
        else if (write_cursor_l_register)
            cursor_address          <= {cursor_address[13:8], internal_data_bus_in};
        else
            cursor_address          <= cursor_address;
    end

    always_comb begin
        if (read_cursor_h_register)
            internal_data_bus_out   = {2'b00, cursor_address[13:8]};
        else if (read_cursor_l_register)
            internal_data_bus_out   = cursor_address[7:0];
        else
            internal_data_bus_out   = 8'hFF;
    end

    //
    // Blink
    //
    logic   [4:0]   field_rate_counter;
    logic           cursor_on;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            field_rate_counter      <= 5'h0;
        else if (V_total)
            field_rate_counter      <= field_rate_counter + 5'h1;
        else
            field_rate_counter      <= field_rate_counter;
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            cursor_on               <= 1'b0;
        else
            casez (blink_config)
                2'b00:  cursor_on   <= 1'b1;
                2'b01:  cursor_on   <= 1'b0;
                2'b10:  cursor_on   <= (~|field_rate_counter[3:0]) ? ~cursor_on : cursor_on;
                2'b11:  cursor_on   <= (~|field_rate_counter[4:0]) ? ~cursor_on : cursor_on;
            endcase
    end

    //
    // Cursor character
    //
    wire    cursor_character = (cursor_address == MA);

    //
    // Cursor scan line
    //
    wire    cursor_scanline  = (cursor_start <= RA) && (RA <= cursor_end);

    //
    // CURSOR
    //
    assign  CURSOR  = cursor_character & cursor_scanline & cursor_on;

endmodule

