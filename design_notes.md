# Design Notes
***Reset syncrnous deassertion and debounce is not implemented, this is to keep the target functionality as clean and reviewable as possible***

## WS2812 Overview
The WS2812 uses a simple single-bit serial protocol. LEDs are designed to be daisychained, each device receives a fixed number of pulse-encoded bits, latches data, and then passes the remaining stream downstream. A low (idle) bus held for 50 microseconds causes the devices to reset, preparing the chain for a new set of data.

## Architecture
The WS2812 protocol is straightforward, which allowed for a relatively simple control flow. Rather than building a separate high-level controller, the small amount of control logic required is directly integrated with the pipelined data path. This approach keeps the design compact, timing-friendly, and avoids unnecessary module hierarchy.

## Timing Considerations
Decode Timer: Generated from a 100 MHz clock using a divide-by-5 clock enable. This keeps the decode logic small and provides straightforward rollover handling beyond the 50 µs reset period.

Encode/Reshaper Timer: Remains at 100 MHz since it does not need to detect resets. However, timing closure results with Symplify Pro suggest that this path may be a bottleneck. One potential improvement is to apply the same divide-by-5 clock enable to the encoder logic, which could also simplify pulse timing constants.

## Control
The only substantial control in this design is the decision fork to keep/shift-in or pass data through to the downstream LED. To avoid an unnecessary counter, a control marker was used in the shift register. Because this logic is relatively small, it made sense to embed the minimal control FSM directly in the shift register module.

## Pulse Reshaping
To prevent the accumulation of signal distortion in the LED chain, the output high cycle is reshaped along three axes. A full signal regeneration is possible, but would require introducing a delay to adequately sample the incoming pulse before transmission, and is not implement in this version.

## Data Path
1. **Serial Input**: First dual-flopped and debounced.
2. **Edge Detection**: Passes through an edge detector, which generates events to control the decoder.
3. **Clock Enable Division**: The data sample clock is divided by 4 to reduce logic levels and improve design efficiency.
4. **Shift Register**: Decoded data feeds into a shift register. Instead of using separate counters, the shifter uses a marker bit to track its boundaries.
5. **Data Buffer**: When the register is full, the data is buffered.
6. **Output FSM**: A minimal FSM briefly exposes the valid data to top-level outputs and enables a pulse reshaper module to output the waveform to the next device in the chain.
7. **Pulse Reshaper**: Handles pulse width normalization—it stretches pulses to nominal durations based on the detected timing.

## Summary
By integrating a small amount of control logic within a pipelined structure, the decoder remains easy to time and resource-efficient. The final result is a streamlined WS2812 interface that does not rely on a large or separate controller, yet maintains enough modularity to adapt to typical FPGA-based applications.

```plaintext
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
```

## Verification Approach

The design is verified using multiple testbench scenarios:
- Two-color packet transmission
- Chained LED updates
- Reset latch behavior with long idle times
- Negative test for short (invalid) reset windows
- Transient Rejection

Monitors check for exact RGB value latching at each DUT stage, verifying the DUT can perform its basic functionality.

## Future Improvements

Optimize Sampling Rate: Explore whether a different division ratio or sampling strategy yields better resource usage or timing margin.

Extended Testing: Add more exhaustive tests for reset edge cases, pulse timing variations, and any corner-case conditions.

Full Pulse Regeneration: Introduce a small pipeline delay for true regeneration of the incoming pulse before retransmission (if needed).
