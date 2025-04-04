
`include "leaflab/inc/led_defines.v"
extern reg clk;
reg serial_in;
wire [1:0] serial_out;
wire [23:0] data_out [1:0];

task send_bit;
    input bit bit_val;
    input logic clk;
    begin
        if (bit_val) begin
            serial_in = 1;
            repeat (T1H_CYCLES) @(posedge clk);

            serial_in = 0;
            repeat (T1L_CYCLES) @(posedge clk);
        end else begin
            serial_in = 1;
            repeat (T0H_CYCLES) @(posedge clk);

            serial_in = 0;
            repeat (T0L_CYCLES) @(posedge clk);
        end
    end
endtask

task send_bytes;
    input [23:0] bytes_to_send;
    input logic clk;
    integer i;
    begin
        for (i = 23; i >= 0; i = i - 1) begin
            send_bit(bytes_to_send[i], clk);
        end
    end
endtask

