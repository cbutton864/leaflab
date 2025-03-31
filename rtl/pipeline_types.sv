/*
Module Name: pipeline_types
Description: Defines the data types used in the pipeline modules.

Author: Curtis Button
Date: March 19, 2025
*/

package pipeline_types;

  typedef struct packed {logic [9:0] counter;} decoder_input_t;

  typedef struct packed {
    logic decode_bit;    // Bit value (1 or 0)
    logic valid;         // Valid flag
    logic treset;        // Reset flag (active high)
  } shift_reg_input_t;

  // Reset values for shift_reg_input_t
  const shift_reg_input_t RESET_VALUES_SHIFT_REG = '{
      decode_bit: 1'b0,
      valid: 1'b0,
      treset: 1'b0
  };

  typedef struct packed {
    logic rising;         // Rising edge flag
    logic falling;        // Falling edge flag
  } edges_t;

  // Reset values for control_path_t
  const edges_t RESET_VALUES_CONTROL_PATH = '{
      rising: 1'b0,
      falling: 1'b0
  };

endpackage
