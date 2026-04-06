import hmac
import os

import pyodbc
from flask import Flask, abort, jsonify, render_template, request

from gold_kpi_service import (
    component_reliability_kpis,
    executive_kpis,
    fleet_watchlist,
    gold_api_health,
    gold_api_metadata,
    openapi_document,
    recent_daily_operations,
)

app = Flask(__name__)

API_KEY_HEADER = 'x-api-key'

def get_db_connection():
    conn_str = os.environ.get('JETOPS_SQL_CONNECTION_STRING')
    if not conn_str:
        raise RuntimeError('JETOPS_SQL_CONNECTION_STRING is not configured for the legacy dashboard route.')
    return pyodbc.connect(conn_str)


def _query_int_arg(name, default, minimum, maximum):
    raw_value = request.args.get(name, str(default))
    parsed = int(raw_value)
    return max(minimum, min(parsed, maximum))


def _auth_required():
    return request.path.startswith('/api/gold/')


def _validate_api_key():
    configured_key = os.environ.get('JETOPS_API_KEY')
    if not configured_key:
        raise RuntimeError('JETOPS_API_KEY is not configured for the Gold API.')

    provided_key = request.headers.get(API_KEY_HEADER, '')
    return hmac.compare_digest(provided_key, configured_key)


@app.before_request
def require_api_key():
    if not _auth_required():
        return None

    if not _validate_api_key():
        abort(401)

    return None

@app.route('/')
def index():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # Fetching your 280 verified records
        cursor.execute("SELECT LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate FROM dbo.MaintenanceLogs")
        rows = cursor.fetchall()
        conn.close()
        return render_template('index.htm', rows=rows)
    except RuntimeError:
        return (
            '<h1>JetOps Gold KPI API</h1>'
            '<p>The legacy dashboard database is not configured in this deployment.</p>'
            '<ul>'
            '<li><a href="/api/gold/health">/api/gold/health</a></li>'
            '<li><a href="/api/gold/metadata">/api/gold/metadata</a></li>'
            '<li><a href="/api/gold/openapi.json">/api/gold/openapi.json</a></li>'
            '<li><a href="/api/gold/kpis/executive">/api/gold/kpis/executive</a></li>'
            '</ul>'
        )
    except Exception as e:
        import traceback
        print(f"!!! NEW STRATEGY FAILURE: {str(e)}")
        traceback.print_exc()
        return f"Database Error: {str(e)}", 500


@app.route('/api/gold/health')
def api_gold_health():
    return jsonify(gold_api_health())


@app.route('/api/gold/metadata')
def api_gold_metadata():
    return jsonify(gold_api_metadata())


@app.route('/api/gold/openapi.json')
def api_gold_openapi():
    public_base_url = os.environ.get('PUBLIC_BASE_URL')
    if not public_base_url:
        forwarded_proto = request.headers.get('X-Forwarded-Proto', request.scheme)
        forwarded_host = request.headers.get('X-Forwarded-Host', request.host)
        public_base_url = f'{forwarded_proto}://{forwarded_host}'
    return jsonify(openapi_document(public_base_url.rstrip('/')))


@app.route('/api/gold/kpis/executive')
def api_gold_executive_kpis():
    return jsonify(executive_kpis())


@app.route('/api/gold/kpis/daily-operations')
def api_gold_daily_operations():
    days = _query_int_arg('days', 14, 1, 90)
    return jsonify({
        'days': days,
        'results': recent_daily_operations(days=days),
    })


@app.route('/api/gold/kpis/component-reliability')
def api_gold_component_reliability():
    days = _query_int_arg('days', 7, 1, 90)
    limit = _query_int_arg('limit', 20, 1, 200)
    return jsonify({
        'days': days,
        'limit': limit,
        'results': component_reliability_kpis(days=days, limit=limit),
    })


@app.route('/api/gold/kpis/fleet-watchlist')
def api_gold_fleet_watchlist():
    limit = _query_int_arg('limit', 50, 1, 500)
    return jsonify({
        'limit': limit,
        'results': fleet_watchlist(limit=limit),
    })


@app.errorhandler(RuntimeError)
def handle_runtime_error(exc):
    return jsonify({'error': str(exc)}), 500


@app.errorhandler(ValueError)
def handle_value_error(exc):
    return jsonify({'error': str(exc)}), 400


@app.errorhandler(401)
def handle_unauthorized(_exc):
    response = jsonify({'error': f'Missing or invalid {API_KEY_HEADER} header.'})
    response.headers['WWW-Authenticate'] = 'ApiKey'
    return response, 401


# Start the Flask app if this script is run directly
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get('PORT', '8000')))
