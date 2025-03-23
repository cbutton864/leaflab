package timing_constants;

  typedef struct packed {
    logic [31:0] T_TOLERANCE;
    logic [31:0] T1H_CYCLES;
    logic [31:0] T1H_CYCLES_MIN;
    logic [31:0] T1H_CYCLES_MAX;
    logic [31:0] T0H_CYCLES;
    logic [31:0] T0H_CYCLES_MIN;
    logic [31:0] T0H_CYCLES_MAX;
    logic [31:0] T1L_CYCLES;
    logic [31:0] T1L_CYCLES_MIN;
    logic [31:0] T1L_CYCLES_MAX;
    logic [31:0] T0L_CYCLES;
    logic [31:0] T0L_CYCLES_MIN;
    logic [31:0] T0L_CYCLES_MAX;
    logic [31:0] TRESET_CYCLES;
  } timing_params_decode_t;

  function automatic timing_params_decode_t init_decode_params(int width_counter);
    timing_params_decode_t params;
    params.T_TOLERANCE = 15;
    params.T1H_CYCLES = (70 / 5);
    params.T1H_CYCLES_MIN = ((params.T1H_CYCLES - params.T_TOLERANCE) / 5);
    params.T1H_CYCLES_MAX = ((params.T1H_CYCLES + params.T_TOLERANCE) / 5);
    params.T0H_CYCLES = (35 / 5);
    params.T0H_CYCLES_MIN = ((params.T0H_CYCLES - params.T_TOLERANCE) / 5);
    params.T0H_CYCLES_MAX = ((params.T0H_CYCLES + params.T_TOLERANCE) / 5);
    params.T1L_CYCLES = (60 / 5);
    params.T1L_CYCLES_MIN = ((params.T1L_CYCLES - params.T_TOLERANCE) / 5);
    params.T1L_CYCLES_MAX = ((params.T1L_CYCLES + params.T_TOLERANCE) / 5);
    params.TRESET_CYCLES = (5000 / 5);
    return params;
  endfunction

endpackage
