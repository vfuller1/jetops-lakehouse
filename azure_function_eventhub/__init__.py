import logging
import azure.functions as func
from azure.eventhub import EventHubProducerClient, EventData
import os
import json

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('HTTP trigger function received a request.')

    try:
        req_body = req.get_json()
    except ValueError:
        return func.HttpResponse("Invalid JSON", status_code=400)

    # Get Event Hub connection details from environment variables
    connection_str = os.environ["EVENTHUB_CONNECTION_STRING"]
    eventhub_name = os.environ["EVENTHUB_NAME"]

    producer = EventHubProducerClient.from_connection_string(
        conn_str=connection_str, eventhub_name=eventhub_name)
    event_data = EventData(json.dumps(req_body))
    with producer:
        producer.send_batch([event_data])
    return func.HttpResponse(f"Event sent: {req_body}", status_code=200)
