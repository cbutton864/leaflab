#include "Vone_led_nominal_timing_tb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    // Instantiate DUT
    Vone_led_nominal_timing_tb *dut = new Vone_led_nominal_timing_tb;

    // Enable waveform tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC *vcd = new VerilatedVcdC;
    dut->trace(vcd, 99);
    vcd->open("one_led_nominal_timing_tb.vcd");

    // Initialize signals
    dut->clk = 0;
    dut->reset = 1;

    vluint64_t time = 0;
    const int sim_time = 100000;

    // Dump the initial state
    dut->eval();
    vcd->dump(time);

    int clk = 0;

    while (time < sim_time) {
        // Toggle clock every 5 time units (full period = 10 time units = 10 ns)
        if ((time % 5) == 0) {
            clk = !clk;
            dut->clk = clk;
        }

        // Deassert reset after 100 ns (10 cycles of 10 ns)
        if (time > 100) {
            dut->reset = 0;
        }

        dut->eval();
        vcd->dump(time);
        Verilated::timeInc(1);  // advance Verilator's internal time
        time++;
    }

    // Finalize and cleanup
    vcd->close();
    delete dut;
    return 0;
}
