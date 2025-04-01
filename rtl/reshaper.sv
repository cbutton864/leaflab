/*
Module Name: reshaper
Description: This module reshapes input signals to generate a WS2812-compatible output,
             ensuring compliance with the WS2812 timing requirements.

Author: Curtis Button
Date: March 19, 2025
*/

module reshaper
  import pipeline_types::*;
  import timing_constants::*;
#(
    parameter int WIDTH = 8  // Counter width
) (
    input  logic      i_clk,
    input  logic      i_reset_n,
    input  reshaper_t i_reshaper,        // Passthrough enable signal
    input  logic      i_signal,          // Synced input signal
    output logic      o_reshaped_signal  // Reshaped output signal
);

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic [WIDTH-1:0] r_counter;
  logic             w_signal_reshaped;

  //////////////////////////////////////////////////////////////////////
  // Counter Logic
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_counter <= '0;
    end else if (r_counter == {WIDTH{1'b1}}) begin
      r_counter <= r_counter;  // Stall counter when msb is high
    end else if (i_signal) begin
      r_counter <= r_counter + 1;  // We count when the signal is high
    end else begin
      r_counter <= '0;  // Reset counter when signal is low
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Signal Reshaping Logic
  always_comb begin
    // Default output
    w_signal_reshaped = i_signal;  // Default to passthrough

    if (!i_reshaper.enable) begin
        w_signal_reshaped = 1'b0;  // Reset state if passthru is disabled
    end else if (r_counter inside {[1:T0H_CYCLES_ENCODER]}) begin
        w_signal_reshaped = 1'b1;  // High if counter is in T0H range
    end else if (r_counter inside {[T1H_CYCLES_ENCODER_MIN:T1H_CYCLES_ENCODER]}) begin
        w_signal_reshaped = 1'b1;  // High if counter is in T1H range
    end else if (r_counter > T1H_CYCLES_ENCODER) begin
        w_signal_reshaped = 1'b0;  // Low if counter exceeds T1H range
    end
end

  //////////////////////////////////////////////////////////////////////
  // Output Assignment
  assign o_reshaped_signal = w_signal_reshaped;

endmodule
