# Design Notes

## WS2812 Overview
The WS2812 uses a simple single-bit serial protocol. LEDs are designed to be daisychained, each device receives a fixed number of pulse-encoded bits, latches data, and then passes the remaining stream downstream. A low (idle) bus held for 50 microseconds causes the devices to latch and reset, preparing the chain for a new set of data.

## Design Overview
I originally planned to write this in Verilog, but somewhere along the way, I decided to experiment with a single-bit FIFO using interfaces. That experiment didn’t stick, but it pushed me toward SystemVerilog, which I stuck with for the final design.

The design is targeted for FPGA implementation. one controller per FPGA instance, running at a base clock of 100 MHz.

## Architecture
The first major decision was architectural. The protocol is straightforward, and a monolithic FSM—mostly Moore with a few state forks—would have been a reasonable option. But due to the simplicity of the protocol and in the spirit of exploring a more timing-friendly design, I went with a more pipelined oriented approach instead.

While I didn't fully separate control and data paths (the modules were already simple and adding hierarchy would just add clutter), the pipelining gaves us some flexibility with timing and resource sharing.

## Data Path
- Serial input is first dual-flopped and debounced.
- It then passes through an edge detector, which generates events to control the decoder.
- The data sample clock is Clock-Enable divided 4 to reduce logic levels and improve design efficiency.
- Decoded data feeds into a shift register. Instead of using separate counters, the shifter uses a marker bit to track its boundaries.
- When the register is full, the data is latched.
- A minimal FSM briefly exposes the valid data to top-level outputs, and enables a pulse reshaper module to output the waveform to the next device in the chain.
- The reshaper handles pulse width normalization—it stretches short pulses up to nominal durations based on the detected timing.

## Summary
The final result is a modular, pipelined WS2812 decoder that avoids a heavy central FSM. The design is an attempt to balance between structured control and practical pipeline-driven timing.


 [ Serial Input ]
        |  
        V
+------------------+
|  Synchronizer    |  
+------------------+
+------------------+
|   Debounce       |
+------------------+
+------------------+
|  Edge Detector   |
+------------------+
         |
         v
+------------------+       +------------------+
|    Decoder       |<----  | CE ÷ 4 -> Counter |
+------------------+       +------------------+
         |
         v
+------------------+ 
|  Shift Register  | 
+------------------+
+------------------+
|   Data Latch     | <-- Final 24-bit RGB output
+------------------+
         |
         |          (From Synchronizer)
         |                  |
         v                  v
  [ Output Port ]    +------------------+
                     |    Reshaper      | <-- Reconstruct pulse
                     +------------------+
                            |
                            v
                     [ Serial Out ]


## Verification Approach

The design is verified using multiple testbench scenarios:
- Two-color packet transmission
- Chained LED updates
- Reset latch behavior with long idle times
- Negative test for short (invalid) reset windows

Monitors check for exact RGB value latching at each DUT stage, verifying the DUT can perform its basic functionality.

## Future Improvements

- Optomize sampling rate for more efficient decode.
- More complete testing treset and pulse timing edge cases.
