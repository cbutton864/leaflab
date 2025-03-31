/*
Module Name: reshaper
Description: Generates the ws2812 serial output signal and reshapes the signal
to shorter pulses are extended to meet the nominal timing requirements.

Author: Curtis Button
Date: March 19, 2025
*/

module reshaper
  import timing_constants::*;
(
    input  logic       i_clk,             // Clock input
    input  logic       i_reset_n,         // Active low reset
    input  logic       i_passthru_en,      // Passthrough enable signal
    input  logic       i_signal_synced,   // Synced input signal
    output logic       o_reshaped_signal  // Reshaped output signal
);

  //////////////////////////////////////////////////////////////////////
  // Parameters and Constants
  localparam int Cwidthcounter = 8;  // Fixed width of the counter

  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic [Cwidthcounter-1:0] r_counter;  // Internal counter register
  logic w_signal_reshaped;              // Internal reshaped signal

  //////////////////////////////////////////////////////////////////////
  // Counter Logic
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_counter <= '0;
    end else if (r_counter == {Cwidthcounter{1'b1}}) begin
      r_counter <= r_counter;
    end else if (i_signal_synced) begin
      r_counter <= r_counter + 1;
    end else begin
      r_counter <= '0;
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Next State Logic (Combinational Process)
  always_comb begin
    // Default passthru
    w_signal_reshaped = i_signal_synced;

    // Check if the counter has reached T0L threshold
    if (r_counter inside {
      T0H_CYCLES_ENCODER_MIN,
      T0H_CYCLES_ENCODER}) begin
      w_signal_reshaped = 1'b1;
    end

    // Check if the counter is in the T1H min to nom window
    if (r_counter inside {
      T1H_CYCLES_ENCODER_MIN,
      T1H_CYCLES_ENCODER}) begin
      w_signal_reshaped = 1'b1;  // Hold high if within T1H cycles
    end

    // If passthru is NOT enabled, hold the signal in reset state
    if (!i_passthru_en) begin
      w_signal_reshaped = 1'b0;
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Output assignment
  assign o_reshaped_signal = w_signal_reshaped;

endmodule
