/*
-----------------------------------------------------------------------------
Module Name: counter
Description: Simple counter module with reset and enable functionality.
The counter increments when enabled and resets on rising or falling edges.
Outputs the counter value along with rising and falling edge flags.

Author: Curtis Button
Date: March 19, 2025
-----------------------------------------------------------------------------
*/

import pipeline_types::*;

module counter (
    input logic i_clk,  // Clock input
    input logic i_reset_n,  // Active low reset input
    input logic i_count_enable,  // Enable signal for the counter
    input logic i_rising,  // Synchronized rising edge for LED control
    input logic i_falling,  // Synchronized falling edge for LED control
    output pipeline_types::decoder_s1_input_t o_count  // Counter output signal
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
      o_count   <= pipeline_types::reset_values;
    end else begin
      // First, we increment the counter with the CE to reduce the effective
      // clock rate of the counter. We also stop the counter at an easy
      // value past the ws2812 reset duration to prevent roll over.
      if (i_count_enable && !r_counter[WIDTH-1]) begin
        r_counter <= r_counter + 1;
      end

      // Then we check for an edge condition to reset the counter
      if (i_rising || i_falling) begin
        r_counter <= '0;
      end
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Output Assignments
  assign o_count = '{counter: r_counter, rising: i_rising, falling: i_falling};

endmodule
