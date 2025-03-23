/*
-----------------------------------------------------------------------------
Module Name: decoder_s1
Description: Decodes stage 1 (high cycle) for WS2812 signal processing.
Uses a window comparator to decode the high cycle, ensuring the bit value
and valid flag are within the specified timing ranges. Outputs the decoded
bit, valid flag, and other pipeline signals to the next stage.

Author: Curtis Button
Date: March 19, 2025
-----------------------------------------------------------------------------
*/

import pipeline_types::*;
import timing_constants::*;

module decoder_s1 (
    input wire i_clk,
    input wire i_reset_n,
    input wire pipeline_types::decoder_s1_input_t i_decoder_s1,  // Input struct
    output wire pipeline_types::decoder_s2_input_t o_decoder_s2  // Output struct
);

  //////////////////////////////////////////////////////////////////////
  // Parameters and Constants
  localparam int Cwidthcounter = 10;  // Fixed width of the counter

  import timing_constants::*;
  timing_params_decode_t decode_params = timing_constants::init_decode_params(Cwidthcounter);
  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic w_decode_bit, w_valid;  // Combinational decoded bit and valid flag
  logic r_decode_bit, r_valid;  // Registered decoded bit and valid flag

  //////////////////////////////////////////////////////////////////////
  // Decode High Cycle Logic (Window Comparator)
  // With this logic, we decode the high cycle using a window comparator
  // to determine if the bit is a 1 or a 0 based on timing ranges.
  //////////////////////////////////////////////////////////////////////
  always_comb begin
    // Default combinational outputs
    w_decode_bit = 1'b0;
    w_valid      = 1'b0;

    // Check the T1H range
    if (i_decoder_s1.counter >= timing.T1H_CYCLES_MIN &&
            i_decoder_s1.counter <= timing.T1H_CYCLES_MAX) begin
      w_decode_bit = 1'b1;
      w_valid      = 1'b1;
    end  // Check the T0H range
    else if (i_decoder_s1.counter >= timing.T0H_CYCLES_MIN &&
                 i_decoder_s1.counter <= timing.T0H_CYCLES_MAX) begin
      w_decode_bit = 1'b0;
      w_valid      = 1'b1;
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Register Logic
  //////////////////////////////////////////////////////////////////////
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_decode_bit <= 1'b0;
      r_valid      <= 1'b0;
    end else if (i_decoder_s1.falling) begin
      r_decode_bit <= w_decode_bit;
      r_valid      <= w_valid;
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Output Assignments
  assign o_decoder_s2.decode_bit = r_decode_bit;
  assign o_decoder_s2.valid      = r_valid;
  assign o_decoder_s2.counter    = i_decoder_s1.counter;  // Passthrough
  assign o_decoder_s2.rising     = i_decoder_s1.rising;  // Passthrough

endmodule
