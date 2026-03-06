# PowerShell script to send orders from orders.csv to Azure Function

 # Set your Function App HTTP endpoint here
 $functionUrl = "https://herbalife-eventhub-func.azurewebsites.net/api/EventHubTrigger?code=<REDACTED>"

# Path to orders.csv
$csvPath = "C:\LocalRepo\jetops-lakehouse\sample_data\orders.csv"

# Import CSV and send each order as JSON
Import-Csv $csvPath | ForEach-Object {
    $orderJson = $_ | ConvertTo-Json
    Invoke-RestMethod -Uri $functionUrl -Method POST -ContentType "application/json" -Body $orderJson
    Write-Host "Sent order: $($orderJson)"
}

# Replace <your-function-url> with your actual Function App HTTP endpoint before running.
