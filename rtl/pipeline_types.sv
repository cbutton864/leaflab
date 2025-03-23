package pipeline_types;

typedef struct packed {
    logic [WIDTH-1:0] counter;
    logic rising;
    logic falling;
  } decoder_s1_input_t;

  // Reset values for decoder_s1_input_t
  pipeline_types::decoder_s1_input_t #(WIDTH) reset_values = '{
      counter: '0,
      rising: 1'b0,
      falling: 1'b0
  };

  typedef struct packed {
    logic [WIDTH-1:0] counter;
    logic decode_bit;
    logic valid;
    logic rising;
  } decoder_s2_input_t;

  // Reset values for decoder_s2_input_t
  pipeline_types::decoder_s2_input_t reset_values_s2 = '{
      counter: '0,
      decode_bit: 1'b0,
      valid: 1'b0,
      rising: 1'b0
  };

  typedef struct packed {
    logic decode_bit;  // Bit value (1 or 0)
    logic valid;       // Valid flag (strobe)
    logic treset;       // Reset flag (active high)
  } shift_reg_input_t;

  // Reset values for shift_reg_input_t
  pipeline_types::shift_reg_input_t reset_values_shift_reg = '{
      decode_bit: 1'b0,
      valid: 1'b0,
      treset: 1'b0
  };

endpackage
