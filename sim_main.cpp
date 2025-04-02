#include "Vled.h"       // Include the Verilated model for the `led` module
#include "verilated.h"  // Include Verilator utilities
#include "verilated_vcd_c.h" // For waveform generation (optional)

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv); // Initialize Verilator arguments

    // Instantiate the DUT (Device Under Test)
    Vled *dut = new Vled;

    // Optional: Enable waveform generation
    Verilated::traceEverOn(true); // Enable tracing
    VerilatedVcdC *vcd = nullptr;
    vcd = new VerilatedVcdC;
    dut->trace(vcd, 99); // Trace 99 levels of hierarchy
    vcd->open("led.vcd");

    // Simulation loop
    for (int time = 0; time < 1000; time++) {
        // If the `led` module does not have a clock, remove or modify this line
        // dut->i_clk = (time % 2) == 0; // Generate a clock signal

        dut->eval();                 // Evaluate the DUT

        if (vcd) vcd->dump(time);    // Dump waveform data
    }

    // Cleanup
    if (vcd) vcd->close();
    delete dut;
    return 0;
}