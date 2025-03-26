import argparse
import subprocess
import os
import platform
from pathlib import Path

#IMPORTANT: ICARUS will not run these SV testbenches.


def run_lint(tool: str):
    if tool == "icarus":
        print("[INFO] Running Verilog lint using Icarus Verilog (iverilog)...")
        subprocess.run(["iverilog", "-t", "null", "-Wall", "-o", "/dev/null", "-c", "lint_filelist.txt"], check=True)
    else:
        print("[INFO] Running Verilog lint using Questa...")
        subprocess.run(["vsim", "-do", "lint.do"], check=True)

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
            "-voptargs=+acc",
            "-wlf", str(sim_dir / "waves.wlf"),
            "-c" if not gui else "-gui",
            "work.testbench",
            "-do", "sim.do",
            "-l", str(sim_dir / "transcript.log"),
        ]
        subprocess.run(sim_flags, check=True)

def main():
    parser = argparse.ArgumentParser(description="Run simulation or lint using QuestaSim or Icarus Verilog")
    parser.add_argument("--lint", action="store_true", help="Run lint only")
    parser.add_argument("--gui", action="store_true", help="Run simulation in GUI mode")
    parser.add_argument("--tool", choices=["questa", "icarus"], default="questa", help="Select simulation tool")

    args = parser.parse_args()

    if args.lint:
        run_lint(tool=args.tool)
    else:
        run_sim(tool=args.tool, gui=args.gui)

if __name__ == "__main__":
    main()
