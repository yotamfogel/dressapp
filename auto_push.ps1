# Auto-push script for AI backend
# Run this script after making changes to automatically push to GitHub

Write-Host "🤖 Auto-pushing AI backend changes to GitHub..." -ForegroundColor Green

# Get current timestamp for commit message
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Add all changes
Write-Host "📁 Adding files..." -ForegroundColor Yellow
git add .

# Check if there are changes to commit
$status = git status --porcelain
if ($status) {
    # Commit changes with timestamp
    Write-Host "💾 Committing changes..." -ForegroundColor Yellow
    git commit -m "Auto-update: $timestamp - AI backend changes"
    
    # Push to GitHub
    Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Yellow
    git push origin main
    
    Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No changes to commit." -ForegroundColor Blue
}

Write-Host "🎉 Auto-push complete!" -ForegroundColor Green 