/*
Module Name: shift_register
Description: Implements a 25-bit shift register for WS2812 signal processing.
             - 24 bits are used for LED data.
             - 1 extra bit is used for the control 'marker'
             The module supports passthrough or shift operations based on the state
             of the control bit.

Author: Curtis Button
Date: March 19, 2025
*/

module shift_register
  import pipeline_types::*;
#(
    parameter int WIDTH = 25  // Shift register width (24 bits for LED data + 1 control bit)
) (
    input  logic                   i_clk,
    input  logic                   i_reset_n,
    input  shift_reg_t             i_shift_reg,  // Input for the shift register
    output logic       [WIDTH-2:0] o_led_data,   // Output for the LED data (24 bits)
    output reshaper_t              o_reshaper    // Output for passthru/reshaper
);

  //////////////////////////////////////////////////////////////////////
  // Parameters and Constants
  localparam logic [WIDTH-1:0] Cresetvalue = {{(WIDTH - 1) {1'b0}}, 1'b1};  // SR Reset value

  //////////////////////////////////////////////////////////////////////
  // State Machine Signals
  typedef enum logic [1:0] {
    SHIFT,
    PASSTHRU
  } state_t;  // FSM states

  //(* fsm_encoding = "one_hot" *) state_t state;
  //only 2 states; one-hot encoding if more than 2 states

  state_t q_state, d_state;  // State registers for the FSM

  //////////////////////////////////////////////////////////////////////
  // Shift Register Signals
  logic [WIDTH-1:0] r_shift_reg;
  // Control Signals
  logic w_passthru_en;
  logic w_shift_en;
  // LED Data
  logic [23:0] w_led_data, r_led_data;

  //////////////////////////////////////////////////////////////////////
  // FSM Logic
  // State transition logic
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      q_state <= SHIFT;
    end else begin
      q_state <= d_state;
    end
  end

  //////////////////////////////////////////////////////////////////////
  // FSM Logic
  // Combinational process to determine the next state
  always_comb begin
    // Default next state
    d_state = q_state;
    unique case (q_state)
      SHIFT: begin
        // If the shift register's extra bit is high, transition to PASSTHRU
        if (r_shift_reg[WIDTH-1]) begin
          d_state = PASSTHRU;
        end
      end
      PASSTHRU: begin
        // If the shift register's extra bit is low, transition back to SHIFT
        if (!r_shift_reg[WIDTH-1]) begin
          d_state = SHIFT;
        end
      end
      default: begin
        d_state = SHIFT;  // Default state
      end
    endcase
  end

  //////////////////////////////////////////////////////////////////////
  // State Behavior Logic
  // Combinational process to manage control signals based on the state
  always_comb begin
    // Default Initial
    w_passthru_en = 1'b0;
    w_shift_en    = 1'b0;
    w_led_data    = 24'b0;
    unique case (q_state)
      SHIFT: begin
        // Allow the control edge to trigger a shift
        w_shift_en = i_shift_reg.valid;
        w_led_data = r_led_data;
      end
      PASSTHRU: begin
        w_passthru_en = 1'b1;
        w_led_data    = r_shift_reg[23:0];  // Output the upper 24-bits SR as LED data
      end
      default: begin
        // Default "other"
        w_passthru_en = 1'b0;
        w_shift_en    = 1'b0;
        w_led_data    = 24'b0;
      end
    endcase
  end

  //////////////////////////////////////////////////////////////////////
  // Shift Register Logic
  // This will manage the shift register operation based on the input signals
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      r_shift_reg <= Cresetvalue;
      r_led_data  <= 24'b0;  // Reset r_led_data to 0
    end else begin
      // we should make some syncronous memory for the LED data
      // to reduce combinatorial paths / complexity
      r_led_data <= w_led_data;

      // Conditional logic for r_shift_reg
      if (i_shift_reg.treset) begin
        r_shift_reg <= Cresetvalue;
      end else if (w_shift_en) begin
        r_shift_reg <= {r_shift_reg[WIDTH-2:0], i_shift_reg.decoded_bit};
      end
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Output Assignments
  assign o_reshaper.enable      = w_passthru_en;
  assign o_reshaper.decoded_bit = i_shift_reg.decoded_bit;
  assign o_led_data             = r_led_data;

endmodule
