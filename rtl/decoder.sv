/*
Module Name: decoder_s1
Description: Decodes stage 1 (high cycle) for WS2812 signal processing.
Uses a window comparator to decode the high cycle, ensuring the bit value
and valid flag are within the specified timing ranges. Outputs the decoded
bit, valid flag, and other pipeline signals to the next stage.

Author: Curtis Button
Date: March 19, 2025
*/

module decoder
  import pipeline_types::*;
  import timing_constants::*;
(
    input  logic             i_clk,
    input  logic             i_reset_n,
    input  edges_t           i_edges,
    input  decoder_input_t   i_decoder,
    output shift_reg_input_t o_shift_reg
);

  //////////////////////////////////////////////////////////////////////
  // Parameters and Constants
  localparam int Cwidthcounter = 10;  // Fixed width of the counter

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic w_decoded_bit;
  logic w_valid;  // Combinational decoded bit and valid flag
  logic r_decoded_bit;
  logic r_valid;  // Registered decoded bit and valid flag

  //////////////////////////////////////////////////////////////////////
  // Decode High Cycle Logic (Window Comparator)
  // We decode the high cycle using a window comparator to determine if the bit value.
  always_comb begin
    // Default combinational outputs
    w_decoded_bit = 1'b0;
    w_valid       = 1'b0;

    // Check the T1H range
    if (i_decoder.counter >= timing_constants::T1H_CYCLES_DECODER_MIN &&
      i_decoder.counter <= timing_constants::T1H_CYCLES_DECODER_MAX) begin
      w_decoded_bit = 1'b1;
      w_valid       = 1'b1;
    end  // Check the T0H range
    else if (i_decoder.counter >= timing_constants::T0H_CYCLES_DECODER_MIN &&
      i_decoder.counter <= timing_constants::T0H_CYCLES_DECODER_MAX) begin
      w_decoded_bit = 1'b0;
      w_valid       = 1'b1;
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Register Logic
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_decoded_bit <= 1'b0;
      r_valid       <= 1'b0;
    end else if (i_edges.falling) begin
      r_decoded_bit <= w_decoded_bit;
      r_valid       <= w_valid;
    end else begin
      r_valid <= 1'b0;
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Output Assignments
  assign o_shift_reg.decode_bit      = r_decoded_bit;
  assign o_shift_reg.valid  = r_valid;
  assign o_shift_reg.treset = i_decoder.counter[Cwidthcounter-1];

endmodule
