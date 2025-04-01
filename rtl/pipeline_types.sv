/*
Module Name: pipeline_types
Description: Defines the data types used in the pipeline modules.

Author: Curtis Button
Date: March 19, 2025
*/

package pipeline_types;

  typedef struct packed {
    logic decoded_bit;  // Bit value (1 or 0)
    logic valid;        // Valid flag
    logic treset;       // Reset flag (active high)
  } shift_reg_t;

  typedef struct packed {
    logic rising;   // Rising edge flag
    logic falling;  // Falling edge flag
  } edges_t;

  typedef struct packed {
    logic enable;       // Enable signal
    logic decoded_bit;  // Decoded bit value
  } reshaper_t;

  //////////////////////////////////////////////////////////////////////////
  //Reset Constants
  // Reset values for control_path_t
  const edges_t RESET_VALUES_CONTROL_PATH = '{rising: 1'b0, falling: 1'b0};

endpackage
