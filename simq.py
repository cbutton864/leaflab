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

    # Ensure the work directory exists and is initialized
    work_dir = Path("work")
    if work_dir.exists():
        shutil.rmtree(work_dir)  # Remove stale work directory
    subprocess.run(["vlib", "work"], check=True)  # Initialize the work directory

    if tool == "icarus":
        print("[INFO] Running simulation using Icarus Verilog...")
        subprocess.run(["iverilog", "-o", str(sim_dir / "sim.out"), "-c", "sim_filelist.txt"], check=True)
        subprocess.run(["vvp", str(sim_dir / "sim.out")], check=True)
    else:
        print("[INFO] Running simulation using Questa%s..." % (" (GUI mode)" if gui else ""))
        sim_flags = [
            "vsim",
            "-voptargs=+acc",
            "-do", "sim.do",  # Ensure the sim.do script is executed

            "-wlf", str(sim_dir / "waves.wlf"),
            "-c" if not gui else "-gui",
            "-l", str(sim_dir / "transcript.log"),
        ]
        subprocess.run(sim_flags, check=True)

def clean():
    """Clean up generated simulation files and directories."""
    sim_dir = Path("sim")
    if sim_dir.exists() and sim_dir.is_dir():
        print(f"[INFO] Removing simulation directory: {sim_dir}")
        shutil.rmtree(sim_dir)

    # Remove all contents of the work directory if it exists
    work_dir = Path("work")
    if work_dir.exists() and work_dir.is_dir():
        print(f"[INFO] Removing all contents of the work directory: {work_dir}")
        shutil.rmtree(work_dir)

    # Remove other generated files if needed
    files_to_remove = ["transcript.log", "waves.wlf"]
    for file in files_to_remove:
        file_path = Path(file)
        if file_path.exists():
            print(f"[INFO] Removing file: {file_path}")
            file_path.unlink()


def main():
    parser = argparse.ArgumentParser(description="Run simulation or lint using QuestaSim or Icarus Verilog")
    parser.add_argument("--lint", action="store_true", help="Run lint only")
    parser.add_argument("--gui", action="store_true", help="Run simulation in GUI mode")
    parser.add_argument("--tool", choices=["questa", "icarus"], default="questa", help="Select simulation tool")
    parser.add_argument("--clean", action="store_true", help="Clean up generated files")

    args = parser.parse_args()

    if args.clean:
        clean()
    elif args.lint:
        run_lint(tool=args.tool)
    else:
        run_sim(tool=args.tool, gui=args.gui)


if __name__ == "__main__":
    main()