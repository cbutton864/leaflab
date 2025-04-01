/*
Module Name: counter
Description: Simple counter module with CE.

Author: Curtis Button
Date: March 19, 2025
*/

module counter
  import pipeline_types::*;
#(
    parameter int WIDTH = 10  // Counter width
) (
    input  logic               i_clk,
    input  logic               i_reset_n,
    input  logic               i_count_enable,  // Enable signal for the counter
    input  edges_t             i_edges,         // Control path input signal
    output logic   [WIDTH-1:0] o_timer_value    // Counter output value
);

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic [WIDTH-1:0] r_counter;

  //////////////////////////////////////////////////////////////////////
  // Counter Logic
  // The counter is shared between the high cycle and low cycle, so it
  // will be reset when the edges are detected. It will alsoo stall when the
  // msb is high, preventing rolling-over.
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_counter <= '0;
    end else begin
      // The counter will increment when the count_enable signal is high
      if (i_count_enable && !r_counter[WIDTH-1]) begin
        r_counter <= r_counter + 1;
      end
      // Then we check for an edge condition to reset the counter
      if (i_edges.rising || i_edges.falling) begin
        r_counter <= '0;
      end
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Output Assignments
  assign o_timer_value = r_counter;

endmodule
