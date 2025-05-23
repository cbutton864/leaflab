import argparse
import subprocess
import os
import platform
from pathlib import Path
import shutil  # For removing directories

# IMPORTANT: ICARUS will not run these SV testbenches.


def run_lint(tool: str):
    if tool == "icarus":
        print("[INFO] Running Verilog lint using Icarus Verilog (iverilog)...")
        subprocess.run(["iverilog", "-t", "null", "-Wall", "-o", "/dev/null", "-c", "lint_filelist.txt"], check=True)
    else:
        print("[INFO] Running Verilog lint using Questa...")
        subprocess.run(["vsim","-c", "-do", "lint.do"], check=True)


def run_sim(tool: str, gui: bool):
    sim_dir = Path("sim")
    sim_dir.mkdir(exist_ok=True)

    if tool == "icarus":
        print("[INFO] Running simulation using Icarus Verilog...")
        subprocess.run(["iverilog", "-o", str(sim_dir / "sim.out"), "-c", "sim_filelist.txt"], check=True)
        subprocess.run(["vvp", str(sim_dir / "sim.out")], check=True)
    else:
        print("[INFO] Running simulation using Questa%s..." % (" (GUI mode)" if gui else ""))
        sim_flags = [
            "vsim",
            "-c" if not gui else "-gui",  # Run in command-line or GUI mode
            "-do", "sim.do"               # Specify the simulation script
        ]
        print("Simulation flags:", sim_flags)  # Debug print to verify flags
        subprocess.run(sim_flags, check=True)

def clean():
    """Clean up generated simulation files and directories."""
    sim_dir = Path("sim")
    if sim_dir.exists() and sim_dir.is_dir():
        print(f"[INFO] Removing simulation directory: {sim_dir}")
        shutil.rmtree(sim_dir)

    #clean out the work directory
    work_dir = Path("work")
    if work_dir.exists() and work_dir.is_dir():
        print(f"[INFO] Removing work directory: {work_dir}")
        shutil.rmtree(work_dir)

    # Remove other generated files if needed
    files_to_remove = ["transcript.log", "waves.wlf"]
    for file in files_to_remove:
        file_path = Path(file)
        if file_path.exists():
            print(f"[INFO] Removing file: {file_path}")
            file_path.unlink()

def view_wlf():
    """Open the waves.wlf file in QuestaSim's wave viewer."""
    wlf_file = Path("sim") / "waves.wlf"
    if not wlf_file.exists():
        print(f"[ERROR] Waveform file not found at {wlf_file}. Please run a simulation first.")
        return
    
    print("[INFO] Opening waves.wlf in QuestaSim wave viewer...")
    # vsim -view sim/waves.wlf
    subprocess.run(["vsim", "-view", str(wlf_file)], check=True)

def main():
    parser = argparse.ArgumentParser(description="Run simulation or lint using QuestaSim or Icarus Verilog")
    parser.add_argument("--lint", action="store_true", help="Run lint only")
    parser.add_argument("--gui", action="store_true", help="Run simulation in GUI mode")
    parser.add_argument("--tool", choices=["questa", "icarus"], default="questa", help="Select simulation tool")
    parser.add_argument("--clean", action="store_true", help="Clean up generated files")
    parser.add_argument("--view", action="store_true", help="Open the waves.wlf file in QuestaSim wave viewer")

    args = parser.parse_args()

    if args.clean:
        clean()
    elif args.view:
        view_wlf()
    elif args.lint:
        run_lint(tool=args.tool)
    else:
        run_sim(tool=args.tool, gui=args.gui)


if __name__ == "__main__":
    main()