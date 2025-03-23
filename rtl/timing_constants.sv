package timing_constants;
  // Timing constants for ws2812 LED control

  typedef struct packed {
    //Timing constants for ws2812 LED control are for an effective sample rate of
    //20MHz (50ns per sample). FPGA Clock(100MHZ) / 5
    logic [WIDTH_COUNTER-1:0] T_TOLERANCE = 15;
    logic [WIDTH_COUNTER-1:0] T1H_CYCLES = (70 / 5);  // 14 samples divided by 5
    logic [WIDTH_COUNTER-1:0] T1H_CYCLES_MIN = ((T1H_CYCLES - T_TOLERANCE) / 5);
    logic [WIDTH_COUNTER-1:0] T1H_CYCLES_MAX = ((T1H_CYCLES + T_TOLERANCE) / 5);
    logic [WIDTH_COUNTER-1:0] T0H_CYCLES = (35 / 5);  // 7 samples divided by 5
    logic [WIDTH_COUNTER-1:0] T0H_CYCLES_MIN = ((T0H_CYCLES - T_TOLERANCE) / 5);
    logic [WIDTH_COUNTER-1:0] T0H_CYCLES_MAX = ((T0H_CYCLES + T_TOLERANCE) / 5);
    logic [WIDTH_COUNTER-1:0] T1L_CYCLES = (60 / 5);  // 12 samples divided by 5
    logic [WIDTH_COUNTER-1:0] T1L_CYCLES_MIN = ((T1L_CYCLES - T_TOLERANCE) / 5);
    logic [WIDTH_COUNTER-1:0] T1L_CYCLES_MAX = ((T1L_CYCLES + T_TOLERANCE) / 5);
    logic [WIDTH_COUNTER-1:0] T0L_CYCLES = (80 / 5);  // 16 samples divided by 5
    logic [WIDTH_COUNTER-1:0] T0L_CYCLES_MIN = ((T0L_CYCLES - T_TOLERANCE) / 5);
    logic [WIDTH_COUNTER-1:0] T0L_CYCLES_MAX = ((T0L_CYCLES + T_TOLERANCE) / 5);
    logic [WIDTH_COUNTER-1:0] TRESET_CYCLES = (5000 / 5);  // 1000 samples divided by 5
  } timing_params_decode_t;

  typedef struct packed {
    logic [WIDTH_COUNTER-1:0] T_TOLERANCE = 15;
    logic [WIDTH_COUNTER-1:0] T1H_CYCLES = 70;
    logic [WIDTH_COUNTER-1:0] T1H_CYCLES_MIN = T1H_CYCLES - T_TOLERANCE;
    logic [WIDTH_COUNTER-1:0] T1H_CYCLES_MAX = T1H_CYCLES + T_TOLERANCE;
    logic [WIDTH_COUNTER-1:0] T0H_CYCLES = 35;
    logic [WIDTH_COUNTER-1:0] T0H_CYCLES_MIN = T0H_CYCLES - T_TOLERANCE;
    logic [WIDTH_COUNTER-1:0] TPERIOD_CYCLES = 125;
  } timing_params_encode_t;

endpackage
