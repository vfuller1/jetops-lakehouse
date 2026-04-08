import argparse
import json
import os
import signal
from pathlib import Path


def _default_state_dir() -> Path:
    return Path(__file__).resolve().parent / ".load-control"


def _state_paths(state_dir: Path, name: str) -> tuple[Path, Path]:
    return state_dir / f"{name}.json", state_dir / f"{name}.stop"


def main() -> int:
    parser = argparse.ArgumentParser(description="Stop the JetOps bulk load generator.")
    parser.add_argument("--name", default="maintenance-load")
    parser.add_argument("--state-dir", default=str(_default_state_dir()))
    parser.add_argument("--force", action="store_true", help="Terminate the tracked process after signalling stop.")
    args = parser.parse_args()

    state_dir = Path(args.state_dir)
    state_path, stop_path = _state_paths(state_dir, args.name)
    stop_path.parent.mkdir(parents=True, exist_ok=True)
    stop_path.write_text("stop\n", encoding="utf-8")
    print(f"Wrote stop file: {stop_path}")

    if not state_path.exists():
        print("No state file found. If a load is running in another environment, stop it there.")
        return 0

    state = json.loads(state_path.read_text(encoding="utf-8"))
    pid = state.get("pid")
    if args.force and pid:
        try:
            os.kill(int(pid), signal.SIGTERM)
            print(f"Sent SIGTERM to PID {pid}")
        except ProcessLookupError:
            print(f"Tracked PID {pid} is not running.")
        except PermissionError:
            print(f"Permission denied when trying to terminate PID {pid}.")
    else:
        print("Graceful stop requested. The running loader will stop after the current request finishes.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
