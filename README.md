# Leaflab Project

This repository contains the WS2812 LED controller exercise submission for Leaflabs. For documented design-related information and decisions, refer to `design_note.md`.

## Runner

This design was initially intended to be implemented in Verilog with a Cocotb runner. However, due to certain design decisions, it was changed to SystemVerilog. The use of QuestaSim is required due to the OOP features in the testbenches.

### Notes:
- Icarus Verilog will not work until a Cocotb testbench alternative is developed.

### Usage:
Run simulation or lint using QuestaSim or Icarus Verilog.

#### Options:
  -h, --help            show this help message and exit
  --lint                Run lint only
  --gui                 Run simulation in GUI mode
  --tool {questa,icarus}
                        Select simulation tool
  --clean               Clean up generated files
  --view                Open the waves.wlf file in QuestaSim wave viewer