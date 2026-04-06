from __future__ import annotations

from datetime import UTC, datetime, timedelta
import random
from typing import Any

AIRCRAFT = [
    {"tail_number": "N817JP", "aircraft_model": "Gulfstream G550", "hangar": "HGR-A1", "airport_code": "TEB"},
    {"tail_number": "N244JT", "aircraft_model": "Bombardier Challenger 650", "hangar": "HGR-B2", "airport_code": "DAL"},
    {"tail_number": "N602MX", "aircraft_model": "Cessna Citation Latitude", "hangar": "HGR-C1", "airport_code": "VNY"},
    {"tail_number": "N901AV", "aircraft_model": "Dassault Falcon 2000LXS", "hangar": "HGR-D4", "airport_code": "HPN"},
    {"tail_number": "N455QX", "aircraft_model": "Embraer Praetor 600", "hangar": "HGR-A3", "airport_code": "OPF"},
]

COMPONENTS = [
    {
        "component": "Engine",
        "fault_codes": ["ENG-201", "ENG-319", "ENG-442"],
        "maintenance_types": ["Scheduled Inspection", "Unscheduled Repair", "Post-Flight Check"],
        "details": [
            "Oil pressure variance observed during engine run-up.",
            "Compressor vibration exceeded baseline threshold.",
            "Engine mount inspection flagged loosened hardware.",
        ],
    },
    {
        "component": "Avionics",
        "fault_codes": ["AVX-118", "AVX-203", "AVX-771"],
        "maintenance_types": ["Diagnostics", "Line Maintenance", "Scheduled Inspection"],
        "details": [
            "Primary flight display intermittently lost brightness sync.",
            "FMS database load validation failed during preflight checks.",
            "Transponder response time exceeded dispatch tolerance.",
        ],
    },
    {
        "component": "Hydraulics",
        "fault_codes": ["HYD-221", "HYD-402", "HYD-509"],
        "maintenance_types": ["Unscheduled Repair", "Scheduled Inspection", "Return To Service"],
        "details": [
            "Hydraulic pressure fluctuation detected on taxi-out.",
            "Actuator seal wear identified during bay inspection.",
            "Reservoir contamination required system flush and retest.",
        ],
    },
    {
        "component": "Landing Gear",
        "fault_codes": ["LDG-144", "LDG-332", "LDG-610"],
        "maintenance_types": ["Scheduled Inspection", "Line Maintenance", "AOG Recovery"],
        "details": [
            "Nose gear steering feedback misalignment recorded after landing.",
            "Main gear strut pressure fell below service target.",
            "Retraction cycle timing variance triggered maintenance hold.",
        ],
    },
    {
        "component": "Cabin Pressurization",
        "fault_codes": ["CAB-180", "CAB-455", "CAB-612"],
        "maintenance_types": ["Diagnostics", "Scheduled Inspection", "Unscheduled Repair"],
        "details": [
            "Cabin differential pressure warning repeated during climb.",
            "Outflow valve calibration drift detected in overnight checks.",
            "Environmental control unit logged an intermittent airflow fault.",
        ],
    },
]

STATUSES = ["Open", "In-Work", "Awaiting Parts", "AOG", "Return To Service Review"]
SEVERITIES = ["Low", "Medium", "High", "Critical"]
TECHNICIANS = ["TECH-014", "TECH-021", "TECH-033", "TECH-041", "TECH-058"]


def _weighted_choice(rng: random.Random, options: list[str], weights: list[int]) -> str:
    return rng.choices(options, weights=weights, k=1)[0]



def build_maintenance_events(count: int, seed: int | None = None) -> list[dict[str, Any]]:
    rng = random.Random(seed)
    base_time = datetime.now(UTC)
    return [build_maintenance_event(index=index, rng=rng, base_time=base_time) for index in range(1, count + 1)]



def build_maintenance_event(index: int, rng: random.Random, base_time: datetime) -> dict[str, Any]:
    aircraft = rng.choice(AIRCRAFT)
    component = rng.choice(COMPONENTS)
    status = _weighted_choice(rng, STATUSES, [30, 35, 10, 15, 10])
    severity = _weighted_choice(rng, SEVERITIES, [35, 35, 20, 10])
    event_time = base_time - timedelta(minutes=(index * 3) + rng.randint(0, 12), seconds=rng.randint(0, 59))
    inspection_date = (event_time - timedelta(hours=rng.randint(2, 36))).date().isoformat()
    maintenance_log_id = 500000 + index

    return {
        "event_type": "maintenance_log_created",
        "event_id": f"evt-{event_time.strftime('%Y%m%d%H%M%S')}-{index:04d}",
        "event_time_utc": event_time.isoformat().replace("+00:00", "Z"),
        "tail_number": aircraft["tail_number"],
        "aircraft_model": aircraft["aircraft_model"],
        "maintenance_log_id": maintenance_log_id,
        "work_order_id": f"WO-{event_time.strftime('%y%m%d')}-{index:04d}",
        "status": status,
        "maintenance_type": rng.choice(component["maintenance_types"]),
        "component": component["component"],
        "fault_code": rng.choice(component["fault_codes"]),
        "severity": severity,
        "part_hours": round(rng.uniform(450.0, 5400.0), 1),
        "inspection_date": inspection_date,
        "technician_id": rng.choice(TECHNICIANS),
        "hangar": aircraft["hangar"],
        "airport_code": aircraft["airport_code"],
        "details": rng.choice(component["details"]),
        "ingestion_source": "azure-function",
        "schema_version": "1.0",
    }
