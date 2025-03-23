/*
-----------------------------------------------------------------------------
Module Name: reshaper
Description: Generates the ws2812 serial output signal and reshapes the signal
to shorter pulses are extended to meet the nominal timing requirements.

Author: Curtis Button
Date: March 19, 2025
-----------------------------------------------------------------------------
*/

import timing_constants::*;

module reshaper (
    input  logic i_clk,             // Clock input
    input  logic i_reset_n,         // Active low reset
    input  logic i_signal_synced,   // Synced input signal
    output logic o_reshaped_signal  // Reshaped output signal
);

  //////////////////////////////////////////////////////////////////////
  // Parameters and Constants
  localparam int Cwidthcounter = 8;  // Fixed width of the counter

  import timing_constants::*;
  timing_params_decode_t decode_params = timing_constants::init_decode_params(Cwidthcounter);


  //////////////////////////////////////////////////////////////////////
  // Internal Signals
  logic [Cwidthcounter-1:0] r_counter;  // Internal counter register
  logic w_signal_reshaped;  // Internal reshaped signal

  //////////////////////////////////////////////////////////////////////
  // Counter Logic
  //////////////////////////////////////////////////////////////////////
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_counter <= '0;
      // Fisrt, we check if the counter has reached the maximum value to trigger a stall
    end else if (r_counter == {Cwidthcounter{1'b1}}) begin
      r_counter <= r_counter;
      // Now we can accumulate the input signal
    end else if (i_signal_synced) begin
      r_counter <= r_counter + 1;
      // Finaaly, initalize the counter if the signal is low
    end else begin
      r_counter <= '0;
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Next State Logic (Combinational Process)
  //////////////////////////////////////////////////////////////////////
  always_comb begin
    // Default passthru
    w_signal_reshaped = i_signal_synced;
    // First we check if the counter has reached T0L threshold
    if (r_counter < timing.T0H_CYCLES) begin
      w_signal_reshaped = 1'b1;
    end
    //Then we check if the counter is in the T1H min to nom window
    if (r_counter inside {timing.T1H_CYCLES_MIN, timing.T1H_CYCLES}) begin
      w_signal_reshaped = 1'b1;  // Hold high if within T1H cycles
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Output assignment
  assign o_reshaped_signal = w_signal_reshaped;

endmodule
