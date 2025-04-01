/*
Module Name: count_enable
Description: Basic clock enable generator for the counter module.

Author: Curtis Button
Date: March 19, 2025
*/

module count_enable
  import pipeline_types::*;
#(
    parameter int DIVISOR = 5  // Debounce cycles
) (
    input  logic   i_clk,
    input  logic   i_reset_n,
    input  edges_t i_edges,        // Control path input signal
    output logic   o_count_enable  // Enable signal for the counter
);

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic [31:0] r_counter;

  //////////////////////////////////////////////////////////////////////
  // Counter Logic
  // Generates the clock enable strobe for the counter module.
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
