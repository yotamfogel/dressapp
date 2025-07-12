# Local AI Backend Startup Script for DressApp
Write-Host "🤖 Starting Local AI Backend for DressApp..." -ForegroundColor Green
Write-Host ""
Write-Host "📍 Server will run on: http://localhost:5000" -ForegroundColor Yellow
Write-Host "📱 For Android emulator, use: http://10.0.2.2:5000" -ForegroundColor Yellow
Write-Host "🍎 For iOS simulator, use: http://localhost:5000" -ForegroundColor Yellow
Write-Host ""

# Check if Python is installed
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python not found. Please install Python 3.8+ first." -ForegroundColor Red
    exit 1
}

# Check if virtual environment exists
if (Test-Path "venv\Scripts\Activate.ps1") {
    Write-Host "🐍 Activating virtual environment..." -ForegroundColor Yellow
    & "venv\Scripts\Activate.ps1"
} else {
    Write-Host "⚠️  Virtual environment not found. Creating new one..." -ForegroundColor Yellow
    python -m venv venv
    & "venv\Scripts\Activate.ps1"
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    pip install -r requirements.txt
}

Write-Host ""
Write-Host "🚀 Starting AI Backend Server..." -ForegroundColor Green
Write-Host ""

# Start the server
try {
    python start_local_server.py
} catch {
    Write-Host "❌ Failed to start server: $_" -ForegroundColor Red
    Write-Host "💡 Make sure all dependencies are installed correctly." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 