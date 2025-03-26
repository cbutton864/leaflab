package timing_constants;

  // Define constants directly
  localparam int T_TOLERANCE = 15;
  localparam int T1H_CYCLES_DECODER = 70 / 5;
  localparam int T1H_CYCLES_DECODER_MIN = (70 - T_TOLERANCE) / 5;
  localparam int T1H_CYCLES_DECODER_MAX = (70 + T_TOLERANCE) / 5;
  localparam int T0H_CYCLES_DECODER = 35 / 5;
  localparam int T0H_CYCLES_DECODER_MIN = (35 - T_TOLERANCE) / 5;
  localparam int T0H_CYCLES_DECODER_MAX = (35 + T_TOLERANCE) / 5;
  localparam int T1L_CYCLES_DECODER = 60 / 5;
  localparam int T1L_CYCLES_DECODER_MIN = (60 - T_TOLERANCE) / 5;
  localparam int T1L_CYCLES_DECODER_MAX = (60 + T_TOLERANCE) / 5;
  localparam int T0L_CYCLES_DECODER = 80 / 5;
  localparam int T0L_CYCLES_DECODER_MIN = (80 - T_TOLERANCE) / 5;
  localparam int T0L_CYCLES_DECODER_MAX = (80 + T_TOLERANCE) / 5;
  localparam int TRESET_CYCLES_DECODER = 5000 / 5;

  // Define constants encoder(shaper)
  localparam int T1H_CYCLES_ENCODER = 70;
  localparam int T1H_CYCLES_ENCODER_MIN = 70 - T_TOLERANCE;
  localparam int T1H_CYCLES_ENCODER_MAX = 70 + T_TOLERANCE;
  localparam int T0H_CYCLES_ENCODER = 35;
  localparam int T0H_CYCLES_ENCODER_MIN = 35 - T_TOLERANCE;
  localparam int T0H_CYCLES_ENCODER_MAX = 35 + T_TOLERANCE;
  localparam int T1L_CYCLES_ENCODER = 60;
  localparam int T1L_CYCLES_ENCODER_MIN = 60 - T_TOLERANCE;
  localparam int T1L_CYCLES_ENCODER_MAX = 60 + T_TOLERANCE;
  localparam int T0L_CYCLES_ENCODER = 80;
  localparam int T0L_CYCLES_ENCODER_MIN = 80 - T_TOLERANCE;
  localparam int T0L_CYCLES_ENCODER_MAX = 80 + T_TOLERANCE;

endpackage
