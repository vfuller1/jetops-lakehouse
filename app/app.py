import pyodbc
from flask import Flask, render_template

app = Flask(__name__)

def get_db_connection():
    # Use SQL authentication for urgent connectivity
    conn_str = (
        "Driver={ODBC Driver 18 for SQL Server};"
        "Server=sql-server-aviator-jetops01.database.windows.net,1433;"
        "Database=db-airplane-maintenance;"
        "UID=aviatoradmin;PWD=Jesusch!1;"
        "Encrypt=yes;"
        "TrustServerCertificate=yes;"
    )
    return pyodbc.connect(conn_str)

@app.route('/')
def index():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # Fetching your 280 verified records
        cursor.execute("SELECT LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate FROM dbo.MaintenanceLogs")
        rows = cursor.fetchall()
        conn.close()
        return render_template('index.html', rows=rows)
    except Exception as e:
        import traceback
        print(f"!!! NEW STRATEGY FAILURE: {str(e)}")
        traceback.print_exc()
        return f"Database Error: {str(e)}", 500


# Start the Flask app if this script is run directly
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
