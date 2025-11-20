# MovieApp - Flutter Setup & Run Script
# Run this in PowerShell

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  MovieApp - Flutter Web Setup & Run" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# Step 1: Clean
Write-Host "[1/3] Cleaning project..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: flutter clean failed" -ForegroundColor Red
    exit 1
}

# Step 2: Get dependencies
Write-Host ""
Write-Host "[2/3] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: flutter pub get failed" -ForegroundColor Red
    exit 1
}

# Step 3: Run on Chrome
Write-Host ""
Write-Host "[3/3] Running on Chrome..." -ForegroundColor Yellow
Write-Host ""
Write-Host "App will launch at: http://localhost:63119" -ForegroundColor Cyan
Write-Host ""

flutter run -d chrome

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  App Running! Press Ctrl+C to stop" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
