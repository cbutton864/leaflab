/*
Module Name: test_runner
Description: Test runner for the LED controller.

Author: Curtis Button
Date: March 19, 2025
*/


`ifndef TEST_RUNNER_SV
`define TEST_RUNNER_SV

`include "led_test_driver.sv"
`include "led_test_monitor.sv"

class test_runner;

  led_test_driver  drv;
  led_test_monitor mon0, mon1;

  function new(led_test_driver d, led_test_monitor m0, led_test_monitor m1);
    drv  = d;
    mon0 = m0;
    mon1 = m1;
  endfunction

  // Run manager
  task automatic dut_reset();
    $display("[%0t] [TEST] Resetting DUTs...", $time);
    drv.vif.rst_n = 0;
    #100;
    drv.vif.rst_n = 1;
    $display("[%0t] [TEST] Reset complete.", $time);
    #80000;  // Wait for reset latch
  endtask

  ////////////////////////////////////////////////////////////////////////
  /*Test 1: Send two packets to DUTs and verify that they are received correctly
  Req: DUT shall receive packets and pass them along to the next DUT
  Steps:
  1. Send a packet to DUT0
  2. Verify that DUT0 received the packet
  3. Send a packet to DUT1
  4. Verify that DUT1 received the packet
*/
  task run_two_packet_test();
    $display("[%0t] [TEST] Sending packet to DUT0...", $time);
    drv.send_bytes(24'hFF0000);
    mon0.expect_led_data(24'hFF0000);

    $display("[%0t] [TEST] Sending packet to DUT1...", $time);
    drv.send_bytes(24'h0000FF);
    #5000;
    mon1.expect_led_data(24'h0000FF);
  endtask

  // Test 1a
  task run_data_shift_test();
    $display("[%0t] [TEST] Starting data shift test...", $time);
    drv.send_bytes(24'hAA1122);
    drv.send_bytes(24'h00FFCC);
    #5000;
    mon0.expect_led_data(24'hAA1122);
    mon1.expect_led_data(24'h00FFCC);
    $display("[%0t] [TEST] Data shift test complete.", $time);
  endtask


  ////////////////////////////////////////////////////////////////////////
  /* Test 2: Test the DUTs ability to reset the latch
  Req: DUT shall reset the latch after 50 µs
  Steps:
  1. Send a packet to DUT0
  2. Verify that DUT0 received the packet
  3. Wait 80 µs
  4. Send a packet to DUT0
  5. Verify that DUT0 received the packet
  */
  task run_reset_latch_test();
    $display("[%0t] [TEST] Starting reset latch test...", $time);
    drv.send_bytes(24'h112233);
    drv.send_bytes(24'h445566);
    #1000;
    mon0.expect_led_data(24'h112233);
    mon1.expect_led_data(24'h445566);
    $display("[%0t] [TEST] Waiting 80 µs for reset latch...", $time);
    #80000;
    drv.send_bytes(24'hAABBCC);
    drv.send_bytes(24'hDDEEFF);
    #1000;
    mon0.expect_led_data(24'hAABBCC);
    mon1.expect_led_data(24'hDDEEFF);
    $display("[%0t] [TEST] Reset latch test complete.", $time);
  endtask

  ////////////////////////////////////////////////////////////////////////
  /* Test 3: Test the DUTs ability to reset the latch after a short reset
  Req: DUT shall reset the latch after 50 µs
  Steps:
  1. Send a packet to DUT0
  2. Verify that DUT0 received the packet
  3. Wait <50 µs
  4. Send a packet to DUT0
  5. Verify that DUT0 did not receive the packet
  */
  task run_reset_short_test();
    $display("[%0t] [TEST] Starting reset short test...", $time);

    // Set to known state
    drv.send_bytes(24'h121212);
    drv.send_bytes(24'h343434);
    #1000;
    mon0.expect_led_data(24'h121212);
    mon1.expect_led_data(24'h343434);

    // Wait <50us to simulate short reset
    #20000;

    // Try to overwrite — this should NOT succeed
    drv.send_bytes(24'hDEADBE);
    drv.send_bytes(24'h00BEEF);
    #1000;
    mon0.expect_led_data(24'h121212);
    mon1.expect_led_data(24'h343434);
    $display("[%0t] [TEST] Reset short test complete.", $time);
  endtask

  ////////////////////////////////////////////////////////////////////////
  /*Test 4: Send transient signal to DUT0 then data packets, verify
  packets are received correctly
  Req: DUT shall operate after recieving transient signal
  Steps:
  1. Send a transient signal to DUT0
  2. Send a data packet to DUT0 & DUT1
  3. Verify that DUT0 received the packet
*/
  task run_transient_test();
    $display("[%0t] [TEST] Starting transient test...", $time);
    $display("[%0t] [TEST] Sending packet to DUT0...", $time);
    drv.send_bytes(24'hFF0000);
    mon0.expect_led_data(24'hFF0000);

    $display("[%0t] [TEST] Sending packet to DUT1...", $time);
    #1000;
    drv.send_transient(1'b0);  //TODO replace arg with serial_in
    #1000;
    drv.send_bytes(24'h0000FF);
    #5000 mon1.expect_led_data(24'h0000FF);
  endtask



  //Run manager
  task run_all();
    dut_reset();
    run_two_packet_test();

    dut_reset();
    run_data_shift_test();

    dut_reset();
    run_reset_latch_test();

    dut_reset();
    run_reset_short_test();

    dut_reset();
    run_transient_test();

    $finish;
  endtask

endclass

`endif
