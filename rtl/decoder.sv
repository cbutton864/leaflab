/*
-----------------------------------------------------------------------------
Module Name: decoder
Description: Encapsulates the decoder_s1 and decoder_s2.

Author: Curtis Button
Date: March 19, 2025
-----------------------------------------------------------------------------
*/

`include "decoder_s1.sv"
`include "decoder_s2.sv"

module decoder (
    input  wire                               i_clk,         // Clock input
    input  wire                               i_reset_n,     // Active low reset
    input  pipeline_types::decoder_s1_input_t i_decoder_s1,  // Input struct for stage 1
    output pipeline_types::shift_reg_input_t  o_shift_reg    // Output struct for shift register
);

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  pipeline_types::decoder_s2_input_t w_decoder_s2;

  //////////////////////////////////////////////////////////////////////
  // Instance: Decoder Stage 1
  // Decodes the high cycle and outputs to stage 2
  decoder_s1 u_decoder_s1 (
      .i_clk(i_clk),
      .i_reset_n(i_reset_n),
      .i_decoder_s1(i_decoder_s1),
      .o_decoder_s2(w_decoder_s2)
  );

  //////////////////////////////////////////////////////////////////////
  // Instance: Decoder Stage 2
  // Decodes the low cycle and outputs to the shift register
  decoder_s2 u_decoder_s2 (
      .i_clk(i_clk),
      .i_reset_n(i_reset_n),
      .i_decoder_s2(w_decoder_s2),
      .o_shift_reg(o_shift_reg)
  );

endmodule
