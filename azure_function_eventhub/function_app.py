import json
import logging
import os
from typing import Any

import azure.functions as func
from azure.eventhub import EventData, EventHubProducerClient

from maintenance_events import build_maintenance_events

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)
MAX_EVENT_COUNT = 500
DEFAULT_EVENT_COUNT = 25


def _resolve_count(req: func.HttpRequest) -> int:
    count_value = req.params.get("count")
    if count_value is None:
        try:
            payload = req.get_json()
        except ValueError:
            payload = {}
        count_value = payload.get("count", DEFAULT_EVENT_COUNT)

    count = int(count_value)
    if count < 1 or count > MAX_EVENT_COUNT:
        raise ValueError(f"count must be between 1 and {MAX_EVENT_COUNT}")
    return count


def _resolve_seed(req: func.HttpRequest) -> int | None:
    seed_value = req.params.get("seed")
    if seed_value is None:
        try:
            payload = req.get_json()
        except ValueError:
            payload = {}
        seed_value = payload.get("seed")

    return int(seed_value) if seed_value not in (None, "") else None


def _producer_client() -> EventHubProducerClient:
    connection_string = os.environ["EVENTHUB_CONNECTION_STRING"]
    eventhub_name = os.environ["EVENTHUB_NAME"]
    return EventHubProducerClient.from_connection_string(
        conn_str=connection_string,
        eventhub_name=eventhub_name,
    )


@app.route(route="maintenance-events/generate", methods=["GET", "POST"])
def generate_maintenance_events(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Generating JetOps maintenance events for Event Hub ingestion.")

    try:
        count = _resolve_count(req)
        seed = _resolve_seed(req)
    except ValueError as exc:
        return func.HttpResponse(str(exc), status_code=400)

    events = build_maintenance_events(count=count, seed=seed)
    producer = _producer_client()

    sent_count = 0
    batch = producer.create_batch()
    batch_count = 0

    with producer:
        for event_payload in events:
            event_data = EventData(json.dumps(event_payload))
            try:
                batch.add(event_data)
                batch_count += 1
            except ValueError:
                producer.send_batch(batch)
                sent_count += batch_count
                batch = producer.create_batch()
                batch.add(event_data)
                batch_count = 1

        if batch_count:
            producer.send_batch(batch)
            sent_count += batch_count

    response_body: dict[str, Any] = {
        "message": "JetOps maintenance events sent to Event Hub.",
        "event_count": sent_count,
        "eventhub_name": os.environ.get("EVENTHUB_NAME"),
        "sample_event": events[0],
    }
    return func.HttpResponse(
        json.dumps(response_body, indent=2),
        mimetype="application/json",
        status_code=200,
    )
