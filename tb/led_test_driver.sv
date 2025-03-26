/*
Module Name: led_test_driver
Description: Driver for the LED controller testbench.

Author: Curtis Button
Date: March 19, 2025
*/

`ifndef LED_TEST_DRIVER_SV
`define LED_TEST_DRIVER_SV

import timing_constants_tb::*;

class led_test_driver;

  virtual led_if vif;

  function new(virtual led_if vif);
    this.vif = vif;
  endfunction

  task send_bit(input bit bit_val);
    if (bit_val) begin
      vif.serial_in = 1;
      #(T1H_NS);
      vif.serial_in = 0;
      #(T1L_NS);
    end else begin
      vif.serial_in = 1;
      #(T0H_NS);
      vif.serial_in = 0;
      #(T0L_NS);
    end
  endtask

  task send_bytes(input logic [23:0] bytes_to_send);
    for (int i = 23; i >= 0; i--) begin
      send_bit(bytes_to_send[i]);
    end
  endtask

endclass
`endif
