# Set the library
vlib work
vmap work work

# Compile the RTL files
vlog -work work rtl/timing_constants.sv
vlog -work work rtl/pipeline_types.sv
vlog -work work rtl/count_enable.sv
vlog -work work rtl/counter.sv
vlog -work work rtl/decoder.sv
vlog -work work rtl/synchronizer.sv
vlog -work work rtl/reshaper.sv
vlog -work work rtl/shift_register.sv
vlog -work work rtl/timer.sv
vlog -work work rtl/top_led.sv

# Compile the testbench files
vlog -sv -work work tb/timing_constants_tb.sv
vlog -sv -work work tb/interface_tb.sv
vlog -sv -work work tb/led_test_driver.sv
vlog -sv -work work tb/led_test_monitor.sv
vlog -sv -work work tb/test_runner.sv
vlog -sv -work work tb/testbench.sv

# Load the testbench module for simulation
vsim work.testbench

# Log all signals in the design hierarchy
log -r /*

# Run the simulation
run -all

# Exit QuestaSim
quit -f