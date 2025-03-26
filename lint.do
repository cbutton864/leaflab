# Questa Linter Script for SystemVerilog Modules

# Set the library and work directory
vlib work
vmap work work

# Add the RTL source files
vlog -sv rtl/timing_constants.sv
vlog -sv rtl/pipeline_types.sv
vlog -sv rtl/count_enable.sv
vlog -sv rtl/counter.sv
vlog -sv rtl/synchronizer.sv
vlog -sv rtl/reshaper.sv
vlog -sv rtl/decoder.sv
vlog -sv rtl/shift_register.sv
vlog -sv rtl/timer.sv
vlog -sv rtl/top_led.sv

# Enable Questa Lint and specify the rules
# Use the -lint switch to enable linting
vlog -lint -sv rtl/top_led.sv

# Run Questa Lint
# Use the `-lint` option to check for linting issues
vlog -lint -sv rtl/*.sv

# Generate a lint report
# Redirect the output to a file for review
vlog -lint -sv rtl/*.sv > lint_report.txt

# Exit QuestaSim
quit