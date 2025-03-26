/*
Module Name: testbench
Description: Testbench for the LED controller.

Author: Curtis Button
Date: March 19, 2025
*/

`include "interface_tb.sv"
`include "led_test_driver.sv"
`include "led_test_monitor.sv"
`include "test_runner.sv"

module testbench;

  reg clk;
  reg rst_n;
  wire serial_d1_in, serial_d2_in;
  wire [23:0] led_data_d0, led_data_d1;

  led_if led_if_0 ();  // Interface instance
  led_if led_if_1 ();  // Interface instance
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

  task automatic dut_reset();
    $display("[%0t] [TB] Resetting DUTs...", $time);
    rst_n = 0;
    #100;
    rst_n = 1;
    $display("[%0t] [TB] Reset complete.", $time);
  endtask


  top_led dut_0 (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_serial(led_if_0.serial_in),
      .o_serial(serial_d1_in),
      .o_led_data(led_if_0.o_led_data)
  );

  assign led_data_d0 = led_if_0.o_led_data;

  top_led dut_1 (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_serial(serial_d1_in),  // chained input
      .o_serial(serial_d2_in),
      .o_led_data(led_if_1.o_led_data)
  );

  assign led_data_d1 = led_if_1.o_led_data;
  assign led_if_0.rst_n = rst_n;

  led_test_driver drv;
  led_test_monitor mon0, mon1;
  test_runner runner;

  initial begin
    drv  = new(led_if_0);
    mon0 = new(led_if_0);
    mon1 = new(led_if_1);

    fork
      mon0.monitor_led_data();
      mon1.monitor_led_data();
    join_none

    runner = new(drv, mon0, mon1);
    runner.run_all();
  end


endmodule
