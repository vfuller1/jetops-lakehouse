import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


def _utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def _default_state_dir() -> Path:
    return Path(__file__).resolve().parent / ".load-control"


def _state_paths(state_dir: Path, name: str) -> tuple[Path, Path]:
    return state_dir / f"{name}.json", state_dir / f"{name}.stop"


def _write_state(state_path: Path, payload: dict) -> None:
    state_path.parent.mkdir(parents=True, exist_ok=True)
    state_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def _build_url(base_url: str, count: int, seed: int | None, function_key: str | None) -> str:
    query = {"count": str(count)}
    if seed is not None:
        query["seed"] = str(seed)
    if function_key:
        query["code"] = function_key

    separator = "&" if urllib.parse.urlparse(base_url).query else "?"
    return f"{base_url}{separator}{urllib.parse.urlencode(query)}"


def _invoke(url: str, timeout_seconds: float) -> dict:
    request = urllib.request.Request(url=url, method="POST")
    with urllib.request.urlopen(request, timeout=timeout_seconds) as response:
        body = response.read().decode("utf-8")
    return json.loads(body)


def main() -> int:
    parser = argparse.ArgumentParser(description="Repeatedly trigger the JetOps maintenance event function.")
    parser.add_argument(
        "--url",
        default="http://localhost:7071/api/maintenance-events/generate",
        help="Function URL without query parameters.",
    )
    parser.add_argument("--count-per-request", type=int, default=500)
    parser.add_argument("--iterations", type=int, default=1)
    parser.add_argument("--delay-seconds", type=float, default=2.0)
    parser.add_argument("--seed", type=int)
    parser.add_argument("--seed-step", type=int, default=1)
    parser.add_argument("--continuous", action="store_true")
    parser.add_argument("--function-key")
    parser.add_argument("--timeout-seconds", type=float, default=30.0)
    parser.add_argument("--name", default="maintenance-load")
    parser.add_argument("--state-dir", default=str(_default_state_dir()))
    args = parser.parse_args()

    if args.count_per_request < 1:
        raise ValueError("count-per-request must be >= 1")
    if not args.continuous and args.iterations < 1:
        raise ValueError("iterations must be >= 1 unless --continuous is set")

    state_dir = Path(args.state_dir)
    state_path, stop_path = _state_paths(state_dir, args.name)
    if stop_path.exists():
        stop_path.unlink()

    total_sent = 0
    iteration = 0
    state_payload = {
        "name": args.name,
        "pid": os.getpid(),
        "url": args.url,
        "count_per_request": args.count_per_request,
        "continuous": args.continuous,
        "delay_seconds": args.delay_seconds,
        "started_at_utc": _utc_now_iso(),
        "last_updated_utc": _utc_now_iso(),
        "iterations_completed": 0,
        "total_events_requested": 0,
        "stop_file": str(stop_path),
    }
    _write_state(state_path, state_payload)
    print(f"State file: {state_path}")
    print(f"Stop file:  {stop_path}")

    try:
        while args.continuous or iteration < args.iterations:
            if stop_path.exists():
                print("Stop file detected. Ending load loop.")
                break

            request_seed = None if args.seed is None else args.seed + (iteration * args.seed_step)
            url = _build_url(args.url, args.count_per_request, request_seed, args.function_key)

            try:
                response_payload = _invoke(url, args.timeout_seconds)
            except urllib.error.HTTPError as exc:
                error_body = exc.read().decode("utf-8", errors="replace")
                print(f"Request failed with HTTP {exc.code}: {error_body}", file=sys.stderr)
                return 1
            except urllib.error.URLError as exc:
                print(f"Request failed: {exc}", file=sys.stderr)
                return 1

            sent_now = int(response_payload.get("event_count", 0))
            total_sent += sent_now
            iteration += 1
            state_payload.update(
                {
                    "last_updated_utc": _utc_now_iso(),
                    "iterations_completed": iteration,
                    "total_events_requested": total_sent,
                    "last_response": response_payload,
                }
            )
            _write_state(state_path, state_payload)

            print(
                json.dumps(
                    {
                        "iteration": iteration,
                        "event_count": sent_now,
                        "total_events_requested": total_sent,
                        "seed": request_seed,
                    }
                )
            )

            if args.continuous or iteration < args.iterations:
                time.sleep(args.delay_seconds)
    except KeyboardInterrupt:
        print("Interrupted. Exiting load loop.")
    finally:
        state_payload.update(
            {
                "last_updated_utc": _utc_now_iso(),
                "ended_at_utc": _utc_now_iso(),
                "iterations_completed": iteration,
                "total_events_requested": total_sent,
            }
        )
        _write_state(state_path, state_payload)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
