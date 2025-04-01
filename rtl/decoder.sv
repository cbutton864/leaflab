/*
Module Name: decoder
Description: Decodes WS2812 signal timing using a window comparator.
             Determines the bit value based on the timer.
             Outputs the decoded bit, valid flag, and pipeline signals.

Author: Curtis Button
Date: March 19, 2025
*/

module decoder
  import pipeline_types::*;
  import timing_constants::*;
#(
    parameter int WIDTH = 10  // Counter width
) (
    input  logic                   i_clk,
    input  logic                   i_reset_n,
    input  edges_t                 i_edges,        // Edge detection signals
    input  logic       [WIDTH-1:0] i_timer_value,  // Timer value from the counter
    output shift_reg_t             o_shift_reg     // Output struct for shift register
);

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic w_decoded_bit, r_decoded_bit;
  logic w_valid, r_valid;

  //////////////////////////////////////////////////////////////////////
  // Decode High Cycle Logic (Window Comparator)
  always_comb begin
    // Default combinational outputs
    w_decoded_bit = 1'b0;
    w_valid       = 1'b0;
    // Set the decode bit high if the timer value is within the T1H range
    if (i_timer_value >= T1H_CYCLES_DECODER_MIN && i_timer_value <= T1H_CYCLES_DECODER_MAX) begin
      w_decoded_bit = 1'b1;
      w_valid       = 1'b1;
      // If the timer value is within the T0H range, we set the decode bit low
    end else if (i_timer_value >= T0H_CYCLES_DECODER_MIN &&
      i_timer_value <= T0H_CYCLES_DECODER_MAX) begin
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
  assign o_shift_reg.decoded_bit = r_decoded_bit;
  assign o_shift_reg.valid       = r_valid;
  assign o_shift_reg.treset      = i_timer_value[WIDTH-1];

endmodule
