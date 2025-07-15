# PowerShell script to deploy AI backend to cloud
param(
    [string]$Platform = "railway"
)

Write-Host "☁️ AI Backend Cloud Deployment" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Function to check if files exist
function Test-Prerequisites {
    $aiBackendPath = Join-Path $PSScriptRoot "..\ai_backend"
    $requiredFiles = @("Dockerfile", "requirements.txt", "app.py", "clothing_detector.py", "start_server.py")
    
    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $aiBackendPath $file
        if (-not (Test-Path $filePath)) {
            $missingFiles += $file
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-Host "❌ Missing required files: $($missingFiles -join ', ')" -ForegroundColor Red
        return $false
    }
    
    Write-Host "✅ All required files found" -ForegroundColor Green
    return $true
}

# Function to deploy to Railway
function Deploy-Railway {
    Write-Host "🚂 Railway Deployment Instructions:" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "1. Go to https://railway.app" -ForegroundColor Cyan
    Write-Host "2. Sign up with GitHub" -ForegroundColor Cyan
    Write-Host "3. Click 'New Project'" -ForegroundColor Cyan
    Write-Host "4. Choose 'Deploy from GitHub repo'" -ForegroundColor Cyan
    Write-Host "5. Select your repository" -ForegroundColor Cyan
    Write-Host "6. Choose 'ai_backend' directory" -ForegroundColor Cyan
    Write-Host "7. Railway will automatically detect and deploy" -ForegroundColor Cyan
    Write-Host "8. Wait for deployment to complete" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Yellow
    
    $url = Read-Host "Enter your Railway URL (e.g., https://your-app.up.railway.app)"
    if (-not $url) {
        $url = "https://your-app-name.up.railway.app"
    }
    
    return $url
}

# Function to deploy to Render
function Deploy-Render {
    Write-Host "🎨 Render Deployment Instructions:" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "1. Go to https://render.com" -ForegroundColor Cyan
    Write-Host "2. Sign up with GitHub" -ForegroundColor Cyan
    Write-Host "3. Click 'New +' → 'Web Service'" -ForegroundColor Cyan
    Write-Host "4. Connect your GitHub repository" -ForegroundColor Cyan
    Write-Host "5. Choose 'ai_backend' directory" -ForegroundColor Cyan
    Write-Host "6. Configure:" -ForegroundColor Cyan
    Write-Host "   - Name: dressapp-ai-backend" -ForegroundColor White
    Write-Host "   - Environment: Python 3" -ForegroundColor White
    Write-Host "   - Build Command: pip install -r requirements.txt" -ForegroundColor White
    Write-Host "   - Start Command: python start_server.py" -ForegroundColor White
    Write-Host "7. Add environment variables:" -ForegroundColor Cyan
    Write-Host "   - PYTHON_VERSION=3.11.0" -ForegroundColor White
    Write-Host "   - PORT=10000" -ForegroundColor White
    Write-Host "   - FLASK_ENV=production" -ForegroundColor White
    Write-Host "   - FLASK_DEBUG=0" -ForegroundColor White
    Write-Host "8. Click 'Create Web Service'" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Yellow
    
    $url = Read-Host "Enter your Render URL (e.g., https://your-app.onrender.com)"
    if (-not $url) {
        $url = "https://your-app-name.onrender.com"
    }
    
    return $url
}

# Function to test deployment
function Test-Deployment {
    param([string]$Url)
    
    Write-Host "🧪 Testing deployment at $Url..." -ForegroundColor Yellow
    
    try {
        # Test health endpoint
        $response = Invoke-WebRequest -Uri "$Url/health" -TimeoutSec 10 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Health check passed" -ForegroundColor Green
            $data = $response.Content | ConvertFrom-Json
            Write-Host "📊 Models loaded: $($data.models_loaded | ConvertTo-Json)" -ForegroundColor Green
        } else {
            Write-Host "❌ Health check failed: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
        
        # Test detection endpoint
        Write-Host "🧪 Testing detection endpoint..." -ForegroundColor Yellow
        $testResponse = Invoke-WebRequest -Uri "$Url/test" -TimeoutSec 30 -UseBasicParsing
        if ($testResponse.StatusCode -eq 200) {
            Write-Host "✅ Detection test passed" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Detection test failed: $($testResponse.StatusCode)" -ForegroundColor Red
            return $false
        }
        
    } catch {
        Write-Host "❌ Test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to update Flutter config
function Update-FlutterConfig {
    param([string]$Url)
    
    Write-Host "📱 Updating Flutter configuration..." -ForegroundColor Yellow
    
    $aiManagerPath = Join-Path $PSScriptRoot "..\lib\core\services\ai_backend_manager.dart"
    
    if (-not (Test-Path $aiManagerPath)) {
        Write-Host "⚠️ AI backend manager file not found" -ForegroundColor Yellow
        return $false
    }
    
    # Read current file
    $content = Get-Content $aiManagerPath -Raw
    
    # Update URL
    $updatedContent = $content -replace "static const String baseUrl = '.*?';", "static const String baseUrl = '$Url';"
    
    # Write updated file
    Set-Content $aiManagerPath $updatedContent
    
    Write-Host "✅ Updated Flutter config with URL: $Url" -ForegroundColor Green
    return $true
}

# Main execution
try {
    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Host "❌ Prerequisites not met. Please check missing files." -ForegroundColor Red
        exit 1
    }
    
    # Choose platform
    Write-Host "`nChoose deployment platform:" -ForegroundColor Cyan
    Write-Host "1. Railway (Recommended - Free tier)" -ForegroundColor White
    Write-Host "2. Render (Free tier)" -ForegroundColor White
    Write-Host "3. Exit" -ForegroundColor White
    
    $choice = Read-Host "`nEnter your choice (1-3)"
    
    $url = $null
    
    switch ($choice) {
        "1" { $url = Deploy-Railway }
        "2" { $url = Deploy-Render }
        "3" { 
            Write-Host "👋 Goodbye!" -ForegroundColor Green
            exit 0
        }
        default {
            Write-Host "❌ Invalid choice" -ForegroundColor Red
            exit 1
        }
    }
    
    if ($url) {
        # Test deployment
        if (Test-Deployment $url) {
            Write-Host "🎉 Deployment successful!" -ForegroundColor Green
            
            # Update Flutter config
            Update-FlutterConfig $url
            
            Write-Host "`n📱 Next steps:" -ForegroundColor Cyan
            Write-Host "1. Build your Flutter app: flutter build apk --release" -ForegroundColor White
            Write-Host "2. Install on your phone: flutter install" -ForegroundColor White
            Write-Host "3. Test AI features with the cloud backend" -ForegroundColor White
            
        } else {
            Write-Host "❌ Deployment test failed" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Deployment failed" -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 