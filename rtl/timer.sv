/*
Module Name: timer
Description: Encapsulates the count_enable and counter modules.

Author: Curtis Button
Date: March 19, 2025
*/

module timer
  import pipeline_types::*;  // Importing the pipeline types
(
    input   logic               i_clk,  // Clock input
    input   logic               i_reset_n,  // Active low reset
    input   control_path_t      i_control,  // Control path input signal
    output  decoder_input_t     o_decoder_input  // Counter output signal
);

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic w_count_enable;  // Clock enable signal generated by count_enable

  //////////////////////////////////////////////////////////////////////
  // Instance: Count Enable
  // Generates a clock enable signal by dividing the input clock
  count_enable u_count_enable (
      .i_clk         (i_clk),
      .i_reset_n     (i_reset_n),
      .i_control     (i_control),
      .o_count_enable(w_count_enable)
  );

  //////////////////////////////////////////////////////////////////////
  // Instance: Counter
  // Increments the counter based on the clock enable signal
  counter u_counter (
      .i_clk          (i_clk),
      .i_reset_n      (i_reset_n),
      .i_count_enable (w_count_enable),
      .i_control      (i_control),
      .o_decoder_input(o_decoder_input)
  );

endmodule
