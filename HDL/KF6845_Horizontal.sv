//
// KF6845_Horizontal
// Horizontal Control
//
// Written by kitune-san
//
module KF6845_Horizontal_Control (
    input   logic           clock,
    input   logic           video_clock_enable,
    input   logic           reset,

    // Internal data bus
    input   logic   [7:0]   internal_data_bus,
    input   logic           write_horizontal_total_register,
    input   logic           write_horizontal_displayed_register,
    input   logic           write_horizontal_sync_position_register,
    input   logic           write_horizontal_sync_width_register,

    // Output
    output  logic           Horizontal,
    output  logic           Horizontal_Half,
    output  logic           Horizontal_End,
    output  logic           H_Display,
    output  logic           HSYNC
);

    //
    // Hrizontal total register
    //
    logic   [7:0]   horizontal_total;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            horizontal_total                    <= 8'h00;
        else if (write_horizontal_total_register)
            horizontal_total                    <= internal_data_bus;
        else
            horizontal_total                    <= horizontal_total;
    end

    //
    // Hrizontal displayed register
    //
    logic   [7:0]   horizontal_displayed;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            horizontal_displayed                <= 8'h00;
        else if (write_horizontal_displayed_register)
            horizontal_displayed                <= internal_data_bus;
        else
            horizontal_displayed                <= horizontal_displayed;
    end

    //
    // Hrizontal sync position register
    //
    logic   [7:0]   horizontal_sync_position;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            horizontal_sync_position            <= 8'h00;
        else if (write_horizontal_sync_position_register)
            horizontal_sync_position            <= internal_data_bus;
        else
            horizontal_sync_position            <= horizontal_sync_position;
    end

    //
    // Horizontal sync width register
    //
    logic   [3:0]   horizontal_sync_width;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            horizontal_sync_width               <= 4'h0;
        else if (write_horizontal_sync_width_register)
            horizontal_sync_width               <= internal_data_bus;
        else
            horizontal_sync_width               <= horizontal_sync_width;
    end

    //
    // Horizontal counter
    //
    logic   [7:0]   horizontal_counter;
    logic   [7:0]   next_horizontal_counter;

    always_comb begin
        if (Horizontal)
            next_horizontal_counter             = 8'h00;
        else
            next_horizontal_counter             = horizontal_counter + 8'h01;
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            horizontal_counter                  <= 8'h00;
        else if (video_clock_enable)
            horizontal_counter                  <= next_horizontal_counter;
        else
            horizontal_counter                  <= horizontal_counter;
    end

    //
    // Horizontal synch width counter
    //
    logic   [3:0]   horizontal_sync_width_counter;
    logic   [3:0]   next_horizontal_sync_width_counter;
    logic           wire_reset_horizontal_sync_width;
    logic           reset_horizontal_sync_width;

    always_comb begin
        if (reset_horizontal_sync_width)
            next_horizontal_sync_width_counter  = 4'h0;
        else if (HSYNC)
            next_horizontal_sync_width_counter  = horizontal_sync_width_counter + 4'h1;
        else
            next_horizontal_sync_width_counter  = horizontal_sync_width_counter;
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            horizontal_sync_width_counter       <= 4'h0;
        else if (video_clock_enable)
            horizontal_sync_width_counter       <= next_horizontal_sync_width_counter;
        else
            horizontal_sync_width_counter       <= horizontal_sync_width_counter;
    end

    assign  wire_reset_horizontal_sync_width = (next_horizontal_sync_width_counter == horizontal_sync_width);

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            reset_horizontal_sync_width         <= 1'b0;
        else if (video_clock_enable)
            reset_horizontal_sync_width         <= wire_reset_horizontal_sync_width;
        else
            reset_horizontal_sync_width         <= reset_horizontal_sync_width;
    end

    //
    // Output signals
    //
    wire    wire_Horizontal         = (next_horizontal_counter == horizontal_total);
    wire    wire_Horizontal_Half    = (next_horizontal_counter == {1'b0, horizontal_total[7:1]});
    wire    wire_Horizontal_End     = (next_horizontal_counter == horizontal_displayed);

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            Horizontal      <= 1'b0;
        else if (video_clock_enable)
            Horizontal      <= wire_Horizontal;
        else
            Horizontal      <= Horizontal;
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            Horizontal_Half <= 1'b0;
        else if (video_clock_enable)
            Horizontal_Half <= wire_Horizontal_Half;
        else
            Horizontal_Half <= Horizontal_Half;
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            Horizontal_End  <= 1'b0;
        else if (video_clock_enable)
            Horizontal_End  <= wire_Horizontal_End;
        else
            Horizontal_End  <= Horizontal_End;
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            H_Display       <= 1'b0;
        else if ((video_clock_enable) && (wire_Horizontal_End))
            H_Display       <= 1'b0;
        else if ((video_clock_enable) && (wire_Horizontal))
            H_Display       <= 1'b1;
        else
            H_Display       <= H_Display;
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            HSYNC           <= 1'b0;
        else if ((video_clock_enable) && (wire_reset_horizontal_sync_width))
            HSYNC           <= 1'b0;
        else if ((video_clock_enable) && (next_horizontal_counter == horizontal_sync_position))
            HSYNC           <= 1'b1;
        else
            HSYNC           <= HSYNC;
    end

endmodule

