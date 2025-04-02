/*
Module Name: top_led

Description:
Top level module for the LED controller.

Author: Curtis Button
Date: March 19, 2025
*/

module top_led #(
    parameter int DEBOUNCEWIDTH = 5,  // Number of cycles for debouncing
    parameter int CWIDTH = 10  // Width of the counter
) (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_serial,
    output logic        o_serial,
    output logic [23:0] o_led_data
);

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic                                    signal_syncd;
  logic                       [CWIDTH-1:0] timer_value;

  pipeline_types::shift_reg_t              shift_reg;  // Input struct for shift register
  pipeline_types::edges_t                  edges;  // serial edge detect signals
  pipeline_types::reshaper_t               reshaper;  // Input struct for reshaper

  //////////////////////////////////////////////////////////////////////
  // Instance: Synchronizer
  synchronizer #(
      .DEBOUNCE_CYCLES(DEBOUNCEWIDTH)
  ) synchronizer_inst (
      .i_clk         (i_clk),
      .i_reset_n     (i_rst_n),
      .i_signal_async(i_serial),
      .o_signal_syncd(signal_syncd),
      .o_edges       (edges)
  );

  //////////////////////////////////////////////////////////////////////
  // Instance: Timer
  timer u_timer (
      .i_clk        (i_clk),
      .i_reset_n    (i_rst_n),
      .i_edges      (edges),
      .o_timer_value(timer_value)
  );

  //////////////////////////////////////////////////////////////////////
  // Instance: Reshaper
  reshaper u_reshaper (
      .i_clk            (i_clk),
      .i_reset_n        (i_rst_n),
      .i_reshaper       (reshaper),
      .i_signal         (signal_syncd),
      .o_reshaped_signal(o_serial)
  );

  //////////////////////////////////////////////////////////////////////
  // Instance: Decoder
  decoder u_decoder (
      .i_clk        (i_clk),
      .i_reset_n    (i_rst_n),
      .i_edges      (edges),
      .i_timer_value(timer_value),
      .o_shift_reg  (shift_reg)
  );

  //////////////////////////////////////////////////////////////////////
  // Instance: Shift Register
  shift_register u_shift_register (
      .i_clk      (i_clk),
      .i_reset_n  (i_rst_n),
      .i_shift_reg(shift_reg),
      .o_led_data (o_led_data),
      .o_reshaper (reshaper)
  );

endmodule
