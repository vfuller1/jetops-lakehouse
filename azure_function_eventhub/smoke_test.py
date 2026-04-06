import argparse
import json
import os
import sys

import azure.functions as func

sys.path.insert(0, os.path.dirname(__file__))

import function_app


class DummyBatch:
    def __init__(self):
        self.items = []

    def add(self, event):
        self.items.append(event)


class DummyProducer:
    def __init__(self):
        self.sent = []

    def create_batch(self):
        return DummyBatch()

    def send_batch(self, batch):
        self.sent.extend(batch.items)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, tb):
        return False


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--count", type=int, default=5)
    parser.add_argument("--seed", type=int, default=7)
    args = parser.parse_args()

    os.environ["EVENTHUB_NAME"] = os.environ.get("EVENTHUB_NAME", "jetops-maintenance-events-dev")

    producer = DummyProducer()
    function_app._producer_client = lambda: producer

    request = func.HttpRequest(
        method="GET",
        url=f"http://localhost/api/maintenance-events/generate?count={args.count}&seed={args.seed}",
        params={"count": str(args.count), "seed": str(args.seed)},
        body=bytes(),
    )
    response = function_app.generate_maintenance_events(request)

    payload = json.loads(response.get_body().decode())
    print(json.dumps(payload, indent=2))
    print(f"Sent events: {len(producer.sent)}")

    if response.status_code != 200:
        return 1
    if payload["event_count"] != args.count:
        return 2
    if len(producer.sent) != args.count:
        return 3
    return 0


if __name__ == "__main__":
    raise SystemExit(main())