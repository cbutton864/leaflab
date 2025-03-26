/*
Module Name: top_led

Description:
    Top level module for the LED controller.

Author: Curtis Button
Date: March 19, 2025
*/
module top_led #(
    parameter int DEBOUNCEWIDTH = 5  // Number of cycles for debouncing
) (
    input wire i_clk,
    input wire i_rst_n,
    input wire i_serial,
    output wire o_serial,
    output wire [23:0] o_led_data

);

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  wire signal_syncd;  // Synchronized signal
  wire [9:0] count;  // Counter output from the timer
  wire passthru_en;  // Passthrough enable from shift register

  pipeline_types::decoder_input_t decoder_input;  // Input struct for decoder_s1
  pipeline_types::shift_reg_input_t shift_reg_input;  // Input struct for shift register
  pipeline_types::control_path_t control;

  //////////////////////////////////////////////////////////////////////
  // Instance: Synchronizer
  synchronizer #(
      .DEBOUNCE_CYCLES(DEBOUNCEWIDTH)
  ) synchronizer_inst (
      .i_clk(i_clk),
      .i_reset_n(i_rst_n),
      .i_signal_async(i_serial),
      .o_signal_syncd(signal_syncd),
      .o_control(control)
  );

  //////////////////////////////////////////////////////////////////////
  // Instance: Timer
  timer u_timer (
      .i_clk(i_clk),
      .i_reset_n(i_rst_n),
      .i_control(control),
      .o_decoder_input(decoder_input)  // Output struct for decoder_s1
  );

  //////////////////////////////////////////////////////////////////////
  // Instance: Reshaper
  reshaper u_reshaper (
      .i_clk(i_clk),
      .i_reset_n(i_rst_n),
      .i_passthru_en(passthru_en),  // Passthrough enable signal
      .i_signal_synced(signal_syncd),  // Synchronized signal from synchronizer
      .o_reshaped_signal(o_serial)  // Reshaped signal
  );

  //////////////////////////////////////////////////////////////////////
  // Instance: Decoder
  decoder u_decoder (
      .i_clk(i_clk),
      .i_reset_n(i_rst_n),
      .i_control(control),
      .i_decoder(decoder_input),  // Input struct for decoder_s1
      .o_shift_reg(shift_reg_input)     // Output struct for shift register
  );

  //////////////////////////////////////////////////////////////////////
  // Instance: Shift Register
  shift_register u_shift_register (
      .i_clk        (i_clk),
      .i_reset_n    (i_rst_n),
      .i_shift_reg  (shift_reg_input),  // Input struct from decoder
      .o_led_data   (o_led_data),       // LED data output
      .o_passthru_en(passthru_en)     // Passthrough enable output
  );

endmodule
