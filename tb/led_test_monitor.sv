/*
Module Name: led_test_monitor
Description: Monitor for the LED controller testbench.

Author: Curtis Button
Date: March 19, 2025
*/

`ifndef LED_TEST_MONITOR_SV
`define LED_TEST_MONITOR_SV

class led_test_monitor;

  virtual led_if vif;
  logic [23:0] last_seen_led_data;

  function new(virtual led_if vif);
    this.vif = vif;
    last_seen_led_data = 'x;
  endfunction

  // Task to monitor and capture LED data changes
  task monitor_led_data();
    logic [23:0] prev = 'x;
    $display("[%0t] [DEBUG] vif handle = %p", $time, vif);
    forever begin
      @(vif.o_led_data);  // Triggers on any change
      if (vif.o_led_data !== prev) begin
        prev = vif.o_led_data;
        last_seen_led_data = vif.o_led_data;
        $display("[%0t] [MONITOR] LED data changed to: %h", $time, last_seen_led_data);
      end
    end
  endtask

  // Expect function to validate LED output
  task expect_led_data(input logic [23:0] expected);
    // Wait until o_led_data becomes known (not 'x')
    wait (last_seen_led_data !== 'x);

    #1;  // Optional: small delay
    if (last_seen_led_data !== expected) begin
      $error("[%0t] [MONITOR] Mismatch! Expected: %h, Got: %h", $time, expected,
             last_seen_led_data);
    end else begin
      $display("[%0t] [MONITOR] Match OK: %h", $time, expected);
    end
  endtask

endclass

`endif
