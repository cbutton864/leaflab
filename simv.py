import os
import subprocess
import sys
import argparse
import shutil

# Define Verilator command and options
VERILATOR = "verilator"
VERILATOR_OPTS = ["-Wall", "--cc", "--timing", "--Wno-fatal", "--trace", "--Mdir", "obj_dir"]

# Define testbench files
TESTBENCHES = [
    "leaflab/tb/one_led_nominal_timing_tb.v"
]

# Define source files
SRC_FILES = [
    "tb/led.v",
    "rtl/pipeline_types.sv",
    "rtl/timing_constants.sv",
    "rtl/timer.sv",
    "rtl/synchronizer.sv",
    "rtl/shift_register.sv",
    "rtl/reshaper.sv",
    "rtl/decoder.sv",
    "rtl/counter.sv",
    "rtl/count_enable.sv",
    "rtl/top_led.sv"
]

# Include directories
INCLUDE_DIRS = [
    "inc",
    "rtl"
]

# Function to run a shell command
def run_command(cmd):
    try:
        print("Running command:", " ".join(cmd))
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: Command failed with return code {e.returncode}")
        sys.exit(1)

# Function to clean up generated files
def clean():
    print("Cleaning up generated files...")
    obj_dir = "obj_dir"
    if os.path.exists(obj_dir):
        print(f"Removing directory: {obj_dir}")
        shutil.rmtree(obj_dir)

    # Remove other generated files if needed
    files_to_remove = ["verilator.log"]
    for file in files_to_remove:
        if os.path.exists(file):
            print(f"Removing file: {file}")
            os.remove(file)

    print("Clean completed.")

# Function to run simulations
def run_simulation():
    for tb in TESTBENCHES:
        tb_name = os.path.basename(tb).replace(".v", "")  # Extract testbench name
        print(f"Running testbench: {tb_name}")

        # Step 1: Run Verilator to generate the model
        cmd = [VERILATOR] + VERILATOR_OPTS + ["--top-module", tb_name]
        for include_dir in INCLUDE_DIRS:
            cmd.append(f"-I{include_dir}")
        cmd += SRC_FILES + [tb, "--exe", "sim_main.cpp"]  # Include sim_main.cpp
        print(f"Generating model for {tb_name}...")
        run_command(cmd)

        # Step 2: Compile the C++ testbench
        obj_dir = "obj_dir"
        make_cmd = ["make", "-C", obj_dir, "-f", f"V{tb_name}.mk", "-j", "1"]
        print(f"Compiling {tb_name}...")
        run_command(make_cmd)

        # Step 3: Run the compiled simulation
        sim_executable = os.path.join(obj_dir, f"V{tb_name}")
        print(f"Running simulation for {tb_name}...")
        run_command([sim_executable])

        print(f"Testbench {tb_name} completed successfully.\n")

    print("All testbenches completed successfully.")

# Main function
def main():
    parser = argparse.ArgumentParser(description="Run Verilator simulations or clean up generated files.")
    parser.add_argument("--clean", action="store_true", help="Clean up generated files.")
    parser.add_argument("--run", action="store_true", help="Run simulations.")

    args = parser.parse_args()

    if args.clean:
        clean()
    elif args.run:
        run_simulation()
    else:
        print("No action specified. Use --run to run simulations or --clean to clean up.")

# Entry point
if __name__ == "__main__":
    main()