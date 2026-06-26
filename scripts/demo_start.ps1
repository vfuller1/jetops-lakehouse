# JetOps Demo — run this once per terminal session before demo_questions.py
$env:PATH = "C:\Users\vfull\AppData\Local\Programs\Python\Python312\;" + "C:\Users\vfull\AppData\Local\Programs\Python\Python312\Scripts\;" + "C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\;" + $env:PATH
if (-not $env:JETOPS_API_KEY) {
    Write-Host "JETOPS_API_KEY is not set. Set it before running this script, e.g.:" -ForegroundColor Red
    Write-Host '  $env:JETOPS_API_KEY = "<your local Gold API key>"' -ForegroundColor Yellow
    Write-Host "(Only needed for direct Gold API calls / smoke tests, not for ask_copilot.py or demo_questions.py.)" -ForegroundColor Yellow
}
Write-Host "Environment ready." -ForegroundColor Green
Write-Host "Next: az login --tenant 5ef08eb8-8ed2-49b3-8eb2-46fba1215518  (then select sub-jetops-prod)" -ForegroundColor Yellow
Write-Host "Then: python scripts/demo_questions.py 1" -ForegroundColor Green
