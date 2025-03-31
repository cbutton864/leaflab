/*
Module Name: count_enable
Description: Basic clock enable generator for the counter module.
The module generates an enable signal by dividing the input clock. The counter
is reset on the rising edge of the clock to reduce jitter.

Author: Curtis Button
Date: March 19, 2025
*/

module count_enable
  import pipeline_types::*;  // Importing the pipeline types
(
    input  logic   i_clk,          // Clock input
    input  logic   i_reset_n,      // Active low reset
    input  edges_t i_edges,        // Control path input signal
    output logic   o_count_enable  // Enable signal for the counter

);

  //////////////////////////////////////////////////////////////////////
  // Parameters and Constants
  localparam int DIVISOR = 5;  // Fixed division factor for the clock enable

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic [31:0] r_counter;  // Internal counter register

  //////////////////////////////////////////////////////////////////////
  // Counter Logic
  // Here we increment the counter and generate the clock enable signal
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_counter      <= '0;
      o_count_enable <= 1'b0;
    end else begin
      if (r_counter < (DIVISOR - 1)) begin
        r_counter      <= r_counter + 1;
        o_count_enable <= 1'b0;
      end else begin
        r_counter      <= '0;
        o_count_enable <= 1'b1;
      end
      if (i_edges.rising) begin
        r_counter      <= '0;
        o_count_enable <= 1'b0;
      end
    end
  end

endmodule
