import time
import json
import os
from datetime import datetime
from azure.eventhub import EventHubProducerClient, EventData

# Use environment variables for Event Hub connection string and name
CONNECTION_STR = os.environ.get("EVENTHUB_CONNECTION_STRING")
EVENTHUB_NAME = os.environ.get("EVENTHUB_NAME")

# Sample order event generator
def generate_order_event(order_id):
    return {
        "order_id": order_id,
        "customer_id": 2000 + order_id,
        "product_id": 3000 + (order_id % 3),
        "quantity": (order_id % 5) + 1,
        "order_date": datetime.utcnow().isoformat()
    }

def main():
    producer = EventHubProducerClient.from_connection_string(conn_str=CONNECTION_STR, eventhub_name=EVENTHUB_NAME)
    for i in range(10):
        event = generate_order_event(1000 + i)
        event_data = EventData(json.dumps(event))
        with producer:
            producer.send_batch([event_data])
        print(f"Sent event: {event}")
        time.sleep(2)  # Simulate real-time events

if __name__ == "__main__":
    main()
