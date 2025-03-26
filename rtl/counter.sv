/*
Module Name: counter
Description: Simple counter module with reset and enable functionality.
The counter increments when enabled and resets on rising or falling edges.
Outputs the counter value along with rising and falling edge flags.

Author: Curtis Button
Date: March 19, 2025
*/

import pipeline_types::*;

module counter (
    input wire i_clk,  // Clock input
    input wire i_reset_n,  // Active low reset input
    input wire i_count_enable,  // Enable signal for the counter
    input wire pipeline_types::control_path_t i_control,  // Control path input signal
    output pipeline_types::decoder_input_t o_decoder_input  // Counter output signal
);

  //////////////////////////////////////////////////////////////////////
  // Parameters and Constants
  localparam int WIDTH = 10;  // Fixed width of the counter

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic [WIDTH-1:0] r_counter;  // Internal counter register

  //////////////////////////////////////////////////////////////////////
  // Counter Logic
  // Here we increment the counter with the CE to reduce the effective
  // clock rate of the counter. We also stop the counter at an easy
  // value past the ws2812 reset duration to prevent roll over.
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_counter <= '0;
    end else begin
      // First, we increment the counter with the CE to reduce the effective
      // clock rate of the counter. We also stop the counter at an easy
      // value past the ws2812 reset duration to prevent roll over.
      if (i_count_enable && !r_counter[WIDTH-1]) begin
        r_counter <= r_counter + 1;
      end

      // Then we check for an edge condition to reset the counter
      if (i_control.rising || i_control.falling) begin
        r_counter <= '0;
      end
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Output Assignments
  assign o_decoder_input = '{counter: r_counter};

endmodule
