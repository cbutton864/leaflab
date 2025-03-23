/*
-----------------------------------------------------------------------------
Module Name: decoder_s2
Description: Decodes stage 2 (low cycle) for WS2812 signal processing.
Combinationally decodes the low cycle, ensures the high cycle was valid, and
checks that the bit value agrees with the previous stage. Outputs the bit
value, valid flag (as a strobe), and reset flag.

Author: Curtis Button
Date: March 19, 2025
-----------------------------------------------------------------------------
*/

import pipeline_types::*;
import timing_constants::*;

module decoder_s2 (
    input wire i_clk,
    input wire i_reset_n,
    input wire pipeline_types::decoder_s2_input_t i_decoder_s2,  // Input struct
    output wire pipeline_types::shift_reg_input_t o_shift_reg  // Output struct for shift register
);

  //////////////////////////////////////////////////////////////////////
  // Parameters and Constants
  localparam int Cwidthcounter = 10;  // Fixed width of the counter

  import timing_constants::*;
  timing_params_decode_t timing = timing_constants::init_decode_params(Cwidthcounter);

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic w_decode_bit_lcl, w_valid, w_treset;  // Combinational signals
  logic r_decode_bit_lcl, r_valid_strobe, r_treset;  // Registered signals

  //////////////////////////////////////////////////////////////////////
  // Decode Low Cycle Logic
  // Here we decode the low cycle and validate the bit based on timing
  //////////////////////////////////////////////////////////////////////
  always_comb begin
    // Default values
    w_decode_bit_lcl = 1'b0;
    w_valid = 1'b0;
    w_treset = 1'b0;

    // We check timing for T1L and T0L cycles to ensure they are within spec
    if (i_decoder_s2.counter <= timing.T1L_CYCLES && i_decoder_s2.valid) begin
      w_decode_bit_lcl = 1'b1;
      w_valid = 1'b1;
    end else if (i_decoder_s2.counter <= timing.T0L_CYCLES && i_decoder_s2.valid) begin
      w_decode_bit_lcl = 1'b0;
      w_valid = 1'b1;
    end

    // next we check if the decoded bit from this stage matches the previous stage
    if (i_decoder_s2.decode_bit != w_decode_bit_lcl) begin
      w_valid = 1'b0;
    end

    // finally, we check if the counter has reached the maximum value to trigger a reset
    if (i_decoder_s2.counter[Cwidthcounter-1]) begin
      w_treset = 1'b1;
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Register Logic
  // Sequential logic to register the decoded bit, valid flag, and reset flag
  //////////////////////////////////////////////////////////////////////
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_decode_bit_lcl <= 1'b0;
      r_valid_strobe   <= 1'b0;
      r_treset         <= 1'b0;
    end else if (i_decoder_s2.rising) begin
      r_decode_bit_lcl <= w_decode_bit_lcl;
      r_valid_strobe   <= w_valid;
      r_treset         <= w_treset;
    end else begin
      r_valid_strobe <= 1'b0;  // Clear the strobe after one cycle
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Output Assignments
  assign o_shift_reg.decode_bit  = r_decode_bit_lcl;
  assign o_shift_reg.valid_strobe = r_valid_strobe;
  assign o_shift_reg.treset     = r_treset;

endmodule
