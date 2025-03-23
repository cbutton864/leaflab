`include "led_defines.v"

module led(
    input           i_serial,
    output          o_serial,
    output [23:0]   o_led);

    reg [23:0] data;
    assign o_led = data;

    // Do things...

endmodule
