/*
-----------------------------------------------------------------------------
Module Name: top_led
Description:
    Top level module for the LED controller.
-----------------------------------------------------------------------------
*/
module top_led #(
    parameter int DEBOUNCEWIDTH = 5  // Number of cycles for debouncing
)
(
    input wire clk,
    input wire rst_n,
    output wire led,
    output wire o_reshaped_signal
);

    //////////////////////////////////////////////////////////////////////
    // Internal Signals
    //////////////////////////////////////////////////////////////////////
    wire o_signal_syncd;  // Synchronized signal
    wire o_rising;        // Rising edge detection
    wire o_falling;       // Falling edge detection
    wire [9:0] o_count;   // Counter output from the timer
    wire [23:0] o_led_data;  // LED data output from shift register
    wire o_passthru_en;      // Passthrough enable from shift register

    pipeline_types::decoder_s1_input_t decoder_s1_input;  // Input struct for decoder_s1
    pipeline_types::shift_reg_input_t shift_reg_input;    // Input struct for shift register

    //////////////////////////////////////////////////////////////////////
    // Instance: Synchronizer
    //////////////////////////////////////////////////////////////////////
    synchronizer #(
        .DEBOUNCE_CYCLES(DEBOUNCEWIDTH)
    ) synchronizer_inst (
        .i_clk(clk),
        .i_reset_n(rst_n),
        .i_signal_async(led),  // Example input signal to synchronize
        .o_signal_syncd(o_signal_syncd),
        .o_rising(o_rising),
        .o_falling(o_falling)
    );

    //////////////////////////////////////////////////////////////////////
    // Instance: Timer
    //////////////////////////////////////////////////////////////////////
    timer u_timer (
        .i_clk(clk),
        .i_reset_n(rst_n),
        .i_rising(o_rising),    // Connect rising edge from synchronizer
        .i_falling(o_falling), // Connect falling edge from synchronizer
        .o_count(o_count)       // Counter output
    );

    //////////////////////////////////////////////////////////////////////
    // Instance: Reshaper
    //////////////////////////////////////////////////////////////////////
    reshaper u_reshaper (
        .i_clk(clk),
        .i_reset_n(rst_n),
        .i_signal_synced(o_signal_syncd),  // Synchronized signal from synchronizer
        .o_reshaped_signal(o_reshaped_signal)  // Reshaped signal
    );

    //////////////////////////////////////////////////////////////////////
    // Instance: Decoder
    //////////////////////////////////////////////////////////////////////
    decoder u_decoder (
        .i_clk(clk),
        .i_reset_n(rst_n),
        .i_decoder_s1(decoder_s1_input),  // Input struct for decoder_s1
        .o_shift_reg(shift_reg_input)     // Output struct for shift register
    );

    //////////////////////////////////////////////////////////////////////
    // Instance: Shift Register
    //////////////////////////////////////////////////////////////////////
    shift_register u_shift_register (
        .i_clk(clk),
        .i_reset_n(rst_n),
        .i_shift_reg(shift_reg_input),  // Input struct from decoder
        .o_led_data(o_led_data),        // LED data output
        .o_passthru_en(o_passthru_en)   // Passthrough enable output
    );

endmodule
