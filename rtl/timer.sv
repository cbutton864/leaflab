/*
Module Name: timer
Description: Encapsulates the count_enable and counter modules.

Author: Curtis Button
Date: March 19, 2025
*/

module timer
  import pipeline_types::*;
#(
    parameter int WIDTH = 10  // Width of our counter
) (
    input  logic               i_clk,
    input  logic               i_reset_n,
    input  edges_t             i_edges,       // Control path input signal
    output logic   [WIDTH-1:0] o_timer_value  // Counter output value
);

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic w_count_enable;

  //////////////////////////////////////////////////////////////////////
  // Instance: Count Enable
  count_enable u_count_enable (
      .i_clk         (i_clk),
      .i_reset_n     (i_reset_n),
      .i_edges       (i_edges),
      .o_count_enable(w_count_enable)
  );

  //////////////////////////////////////////////////////////////////////
  // Instance: Counter
  counter u_counter (
      .i_clk         (i_clk),
      .i_reset_n     (i_reset_n),
      .i_count_enable(w_count_enable),
      .i_edges       (i_edges),
      .o_timer_value (o_timer_value)
  );

endmodule
