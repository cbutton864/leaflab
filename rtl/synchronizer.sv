/*
-----------------------------------------------------------------------------
Module Name: synchronizer
Description: 2-stage flip-flop synchronizer into a debounce circuit, followed
edge detection. Module outputs a synchronized signal, rising edge, and falling edge.
Author: Curtis Button
Date: March 19, 2025
-----------------------------------------------------------------------------

Parameters:
- DEBOUNCE_CYCLES : Number of cycles for debouncing (default: 5)

Ports:
- input  i_clk      : Clock input for the synchronizer
- input  i_reset_n  : Active low reset input
- input  i_signal   : Input signal to be synchronized
- output o_signal   : Synchronized output signal
- output o_rising   : Rising edge detection output
- output o_falling  : Falling edge detection output
-----------------------------------------------------------------------------
*/

module synchronizer #(
    parameter int DEBOUNCE_CYCLES = 5  // Number of cycles for debouncing
) (
    input  logic i_clk,           // Clock input
    input  logic i_reset_n,       // Active low reset
    input  logic i_signal_async,  // Input signal to be synchronized
    output logic o_signal_syncd,  // Synchronized output signal
    output logic o_rising,        // Rising edge detection output
    output logic o_falling        // Falling edge detection output
);

  // Internal registers for the 2-stage flip-flops
  logic r_signal_meta, r_signal_syncd;  // Meta-stable and synchronized signals

  // Debounce-related signals
  logic r_debounce_signal, r_debounce_signal_delayed;  // Debounced signal
  logic [DEBOUNCE_CYCLES-1:0] r_shift_reg;  // Shift register for each bit

  ////////////////////////////////////////////////////////////////////
  // Synchronizer Logic
  // a simple dual flop with with an added stage
  ////////////////////////////////////////////////////////////////////
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_signal_meta  <= '0;
      r_signal_syncd <= '0;
    end else begin
      r_signal_meta  <= i_signal_async;
      r_signal_syncd <= r_signal_meta;
    end
  end

  ////////////////////////////////////////////////////////////////////
  // Shift Register-Based Debounce Logic
  // we shift in sampled signal and check for register uniformity
  ////////////////////////////////////////////////////////////////////
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_debounce_signal <= '0;
      r_shift_reg <= '0;
    end else begin
      // we shift the bits in the shift register
      r_shift_reg <= {r_shift_reg[DEBOUNCE_CYCLES-2:0], o_signal_syncd};
      // we now check if all bits in the shift register are the same
      if (&r_shift_reg) begin
        r_debounce_signal <= 1'b1;  // All bits are 1
      end else if (~|r_shift_reg) begin
        r_debounce_signal <= 1'b0;  // All bits are 0
      end
    end
  end

  ////////////////////////////////////////////////////////////////////
  // Edge Detection Logic
  // we use the delayed debounced signal to detect edges to avoid
  // false edges due to noise.
  ////////////////////////////////////////////////////////////////////
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_debounce_signal_delayed <= 1'b0;
      o_rising                  <= 1'b0;
      o_falling                 <= 1'b0;
    end else begin
      r_debounce_signal_delayed <= r_debounce_signal;

      // our edge detection logic
      o_rising <= ~r_debounce_signal_delayed & r_debounce_signal;
      o_falling <= r_debounce_signal_delayed & ~r_debounce_signal;
    end
  end

  ////////////////////////////////////////////////////////////////////
  // Assign Debounced Signal to Output
  ////////////////////////////////////////////////////////////////////
  assign o_signal_syncd = r_debounce_signal;

endmodule
