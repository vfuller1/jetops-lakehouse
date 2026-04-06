import json
import os
import shutil
import subprocess
from datetime import datetime, timedelta, timezone
from functools import lru_cache
from pathlib import Path

from azure.storage.filedatalake import DataLakeServiceClient


def _utc_now_iso():
    return datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z')


@lru_cache(maxsize=1)
def _storage_account():
    return os.getenv('JETOPS_STORAGE_ACCOUNT', 'stherbalifedev001')


@lru_cache(maxsize=1)
def _resource_group():
    return os.getenv('JETOPS_RESOURCE_GROUP', 'rg-herbalife-dev-core')


@lru_cache(maxsize=1)
def _gold_container():
    return os.getenv('JETOPS_GOLD_CONTAINER', 'gold')


@lru_cache(maxsize=1)
def _gold_dataset_root():
    return os.getenv('JETOPS_GOLD_DATASET_ROOT', 'jetops/maintenance_kpis')


@lru_cache(maxsize=1)
def _api_snapshot_root():
    return os.getenv('JETOPS_GOLD_API_SNAPSHOT_ROOT', 'jetops/maintenance_kpis_api')


@lru_cache(maxsize=1)
def _daily_dataset():
    return os.getenv('JETOPS_GOLD_DAILY_DATASET', f"{_gold_dataset_root()}/daily_operations")


@lru_cache(maxsize=1)
def _component_dataset():
    return os.getenv('JETOPS_GOLD_COMPONENT_DATASET', f"{_gold_dataset_root()}/component_reliability")


@lru_cache(maxsize=1)
def _fleet_dataset():
    return os.getenv('JETOPS_GOLD_FLEET_DATASET', f"{_gold_dataset_root()}/fleet_status_snapshot")


@lru_cache(maxsize=1)
def _az_cli():
    return os.getenv('AZURE_CLI_PATH', r'C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd')


def _storage_account_key():
    configured_key = os.getenv('JETOPS_STORAGE_ACCOUNT_KEY')
    if configured_key:
        return configured_key

    az_cli = _az_cli()
    if not shutil.which(az_cli) and not Path(az_cli).exists():
        raise RuntimeError(
            'JETOPS_STORAGE_ACCOUNT_KEY is not set and Azure CLI was not found for fallback credential lookup.'
        )

    try:
        return subprocess.check_output(
            [
                az_cli,
                'storage',
                'account',
                'keys',
                'list',
                '--resource-group',
                _resource_group(),
                '--account-name',
                _storage_account(),
                '--query',
                '[0].value',
                '-o',
                'tsv',
            ],
            text=True,
        ).strip()
    except Exception as exc:
        raise RuntimeError(
            'Unable to resolve the ADLS account key for the Gold KPI API. Set JETOPS_STORAGE_ACCOUNT_KEY explicitly.'
        ) from exc


@lru_cache(maxsize=1)
def _service_client():
    connection_string = (
        f'DefaultEndpointsProtocol=https;AccountName={_storage_account()};'
        f'AccountKey={_storage_account_key()};EndpointSuffix=core.windows.net'
    )
    return DataLakeServiceClient.from_connection_string(connection_string)


def _snapshot_directory(snapshot_name):
    return f'{_api_snapshot_root()}/{snapshot_name}'


def _snapshot_records(snapshot_name):
    file_system_client = _service_client().get_file_system_client(_gold_container())
    directory_path = _snapshot_directory(snapshot_name)
    files = [
        path.name
        for path in file_system_client.get_paths(path=directory_path)
        if path.name.endswith('.json')
    ]
    if not files:
        raise RuntimeError(
            f'Gold API snapshot {directory_path} was not found. Run the Databricks Gold notebook after the latest notebook patch.'
        )

    records = []
    for file_path in files:
        payload = file_system_client.get_file_client(file_path).download_file().readall().decode('utf-8')
        for line in payload.splitlines():
            if line.strip():
                records.append(json.loads(line))
    return records


def _safe_int(value):
    try:
        return int(value)
    except (TypeError, ValueError):
        return 0


def _parse_date(value):
    if not value:
        return None
    return datetime.fromisoformat(str(value).replace('Z', '+00:00'))


def gold_api_metadata():
    return {
        'generated_at_utc': _utc_now_iso(),
        'storage_account': _storage_account(),
        'gold_container': _gold_container(),
        'api_snapshot_root': _api_snapshot_root(),
        'datasets': {
            'daily_operations': _daily_dataset(),
            'component_reliability': _component_dataset(),
            'fleet_status_snapshot': _fleet_dataset(),
        },
    }


def gold_api_health():
    daily_records = _snapshot_records('daily_operations')
    component_records = _snapshot_records('component_reliability')
    fleet_records = _snapshot_records('fleet_status_snapshot')
    executive_records = _snapshot_records('executive_kpis')
    return {
        'status': 'ok',
        'generated_at_utc': _utc_now_iso(),
        'snapshots': {
            'executive_kpis': {'rows': len(executive_records), 'path': _snapshot_directory('executive_kpis')},
            'daily_operations': {'rows': len(daily_records), 'path': _snapshot_directory('daily_operations')},
            'component_reliability': {'rows': len(component_records), 'path': _snapshot_directory('component_reliability')},
            'fleet_status_snapshot': {'rows': len(fleet_records), 'path': _snapshot_directory('fleet_status_snapshot')},
        }
    }


def executive_kpis():
    records = _snapshot_records('executive_kpis')
    if not records:
        return {
            'generated_at_utc': _utc_now_iso(),
            'fleet_aircraft': 0,
            'aircraft_in_aog': 0,
            'aircraft_with_open_issues': 0,
            'aircraft_with_critical_issues': 0,
        }
    return records[0]


def recent_daily_operations(days=14):
    cutoff = datetime.now(timezone.utc).date() - timedelta(days=days)
    grouped = {}
    for record in _snapshot_records('daily_operations'):
        event_date = _parse_date(record.get('event_date'))
        if event_date is None or event_date.date() < cutoff:
            continue
        date_key = event_date.date().isoformat()
        bucket = grouped.setdefault(
            date_key,
            {
                'event_date': date_key,
                'total_events': 0,
                'open_events': 0,
                'aog_events': 0,
                'critical_events': 0,
            },
        )
        bucket['total_events'] += _safe_int(record.get('total_events'))
        bucket['open_events'] += _safe_int(record.get('open_events'))
        bucket['aog_events'] += _safe_int(record.get('aog_events'))
        bucket['critical_events'] += _safe_int(record.get('critical_events'))
    return sorted(grouped.values(), key=lambda item: item['event_date'], reverse=True)


def component_reliability_kpis(days=7, limit=20):
    cutoff = datetime.now(timezone.utc).date() - timedelta(days=days)
    grouped = {}
    for record in _snapshot_records('component_reliability'):
        event_date = _parse_date(record.get('event_date'))
        if event_date is None or event_date.date() < cutoff:
            continue
        component = record.get('component') or 'Unknown'
        bucket = grouped.setdefault(
            component,
            {
                'component': component,
                'total_events_lookback': 0,
                'aog_events_lookback': 0,
                'critical_events_lookback': 0,
                'unscheduled_events_lookback': 0,
                'avg_inspection_age_hours': 0.0,
                'inspection_age_samples': 0,
            },
        )
        bucket['total_events_lookback'] += _safe_int(record.get('total_events'))
        bucket['aog_events_lookback'] += _safe_int(record.get('aog_events'))
        bucket['critical_events_lookback'] += _safe_int(record.get('critical_events'))
        bucket['unscheduled_events_lookback'] += _safe_int(record.get('unscheduled_events'))
        if record.get('avg_inspection_age_hours') is not None:
            bucket['avg_inspection_age_hours'] += float(record['avg_inspection_age_hours'])
            bucket['inspection_age_samples'] += 1

    results = []
    for bucket in grouped.values():
        inspection_samples = bucket.pop('inspection_age_samples')
        bucket['avg_inspection_age_hours'] = round(
            bucket['avg_inspection_age_hours'] / inspection_samples,
            2,
        ) if inspection_samples else None
        results.append(bucket)

    return sorted(
        results,
        key=lambda item: (
            item['aog_events_lookback'],
            item['critical_events_lookback'],
            item['total_events_lookback'],
        ),
        reverse=True,
    )[:limit]


def fleet_watchlist(limit=50):
    results = [
        record
        for record in _snapshot_records('fleet_status_snapshot')
        if _safe_int(record.get('aog_flag')) == 1
        or _safe_int(record.get('open_issue_flag')) == 1
        or (record.get('current_severity') or '') in {'High', 'Critical'}
    ]
    return sorted(
        results,
        key=lambda item: (
            _safe_int(item.get('aog_flag')),
            item.get('current_severity') or '',
            item.get('latest_event_timestamp') or '',
        ),
        reverse=True,
    )[:limit]


def openapi_document(server_url):
    spec_path = Path(__file__).with_name('gold_kpi_api_openapi.json')
    spec = json.loads(spec_path.read_text())
    spec['servers'] = [{'url': server_url}]
    return spec