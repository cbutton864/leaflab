/*
-----------------------------------------------------------------------------
Module Name: shift_register
Description: Implements a shift register for WS2812 signal processing. The shift
Register is 25-bit, 24 for the LED data and 1 extra bit for control. The module
directs data to either passthrough or shift based on the extra bit's state.
Author: Curtis Button

Date: March 19, 2025

-----------------------------------------------------------------------------

*/



module shift_register
  import pipeline_types::*;
(
    input  logic                    i_clk,
    input  logic                    i_reset_n,
    input  shift_reg_input_t        i_shift_reg,
    output logic             [23:0] o_led_data,    // Output for the LED data (24 bits)
    output logic                    o_passthru_en  // Output for passthrough enable
);

  //////////////////////////////////////////////////////////////////////
  // Parameters and Constants
  localparam int WIDTH = 25;  // Fixed width of the shift register
  localparam logic [WIDTH-1:0] Cresetvalue = {{(WIDTH - 1) {1'b0}}, 1'b1};  // SR Reset value

  //////////////////////////////////////////////////////////////////////
  // State Machine Signals
  typedef enum logic [1:0] {
    SHIFT,
    PASSTHRU
  } state_t;  // FSM states

  //(* fsm_encoding = "one_hot" *) state_t state;
  //only 2 states; one-hot encoding wouldn’t buy you much here,

  state_t q_state;
  state_t d_state; // Current and next state

  //////////////////////////////////////////////////////////////////////
  // Shift Register Signals
  logic [WIDTH-1:0] r_shift_reg;
  // Control Signals
  logic w_passthru_en;
  logic w_shift_en   ;
  // LED Data
  logic [23:0] w_led_data;
  logic [23:0] r_led_data;

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
        w_shift_en = i_shift_reg.shift_en;
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
        r_shift_reg <= {r_shift_reg[WIDTH-2:0], i_shift_reg.decode_bit};
      end
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Output Assignments
  assign o_passthru_en = w_passthru_en;  // Assign passthrough enable output
  assign o_led_data    = r_led_data;  // Assign LED data output

endmodule
