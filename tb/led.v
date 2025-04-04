`timescale 1ns / 1ns

module led(
    input wire i_serial,
    output wire o_serial,
    output wire [23:0] o_led_data
);

  // Parameters
  localparam int DEBOUNCEWIDTH = 0;
  localparam int CWIDTH = 0;

  // Instantiate the DUT (Device Under Test)
  top_led # (
    .DEBOUNCEWIDTH(DEBOUNCEWIDTH),
    .CWIDTH(CWIDTH)
  )
  top_led_inst (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_serial(i_serial),
    .o_serial(o_serial),
    .o_led_data(o_led_data)
  );

  // // Clock generation
  // reg i_clk;
  // initial begin
  //   i_clk = 0;
  //   forever #5 i_clk = ~i_clk; // 10ns clock period
  // end

  // // Reset generation
  // reg i_rst_n;
  // initial begin
  //   i_rst_n = 0; // Assert reset
  //   #20;         // Hold reset for 20ns
  //   i_rst_n = 1; // Deassert reset
  // end

endmodule
