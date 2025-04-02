#include "Vone_led_nominal_timing_tb.h"  // Include the Verilated model for the testbench
#include "verilated.h"                  // Include Verilator utilities
#include "verilated_vcd_c.h"            // For waveform generation (optional)

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv); // Initialize Verilator arguments

    // Instantiate the DUT (Device Under Test)
    Vone_led_nominal_timing_tb *dut = new Vone_led_nominal_timing_tb;

    // Optional: Enable waveform generation
    Verilated::traceEverOn(true); // Enable tracing
    VerilatedVcdC *vcd = nullptr;
    vcd = new VerilatedVcdC;
    dut->trace(vcd, 99); // Trace 99 levels of hierarchy
    vcd->open("one_led_nominal_timing_tb.vcd");

    // Simulation loop
    for (int time = 0; time < 1000; time++) {
        dut->eval();                 // Evaluate the DUT

        if (vcd) vcd->dump(time);    // Dump waveform data
    }

    // Cleanup
    if (vcd) vcd->close();
    delete dut;
    return 0;
}