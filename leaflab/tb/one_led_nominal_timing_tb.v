`timescale 1ns / 1ns

`include "leaflab/inc/led_defines.v"

module one_led_nominal_timing_tb;
    `include "leaflab/inc/bitbang_tasks.v"
    
    // Instantiate the DUT
    led dut(
        .i_serial(serial_in),
        .o_serial(serial_out),
        .o_led_data(data_out[0])
    );
    initial begin
        reg [23:0] data_out_lcl;

        assign data_out_lcl = data_out[0];
        // Set up waveform output
        $dumpfile("one_led_nominal_timing_tb.vcd");
        $dumpvars(0, one_led_nominal_timing_tb);

        $display("Starting the test...");

        // Wait at least 50us to ensure reset completion
        #(`RET);

        $display("Sending LED data...");
        send_bytes(24'hFF00FF);

        if (data_out_lcl !== 24'hFF00FF) begin
            $display("FAIL: LED output incorrect!");
        end else begin
            $display("PASS: LED output correct!");
        end

        #1000; // Wait some time before finishing
        $display("Ending the test...");

        $finish;
    end

endmodule