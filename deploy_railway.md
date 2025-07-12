# Deploy AI Backend to Railway

Railway is the easiest way to deploy your AI backend with a generous free tier.

## 🚀 Quick Deploy Steps

### 1. Install Railway CLI
```bash
# Install Railway CLI
npm install -g @railway/cli

# Or using curl
curl -fsSL https://railway.app/install.sh | sh
```

### 2. Login to Railway
```bash
railway login
```

### 3. Initialize Project
```bash
cd ai_backend
railway init
```

### 4. Deploy
```bash
railway up
```

### 5. Get Your URL
```bash
railway domain
```

## 📋 Detailed Steps

### Step 1: Prepare Your Code
Make sure you have these files in `ai_backend/`:
- ✅ `Dockerfile`
- ✅ `requirements.txt`
- ✅ `app.py`
- ✅ `clothing_detector.py`
- ✅ `start_server.py`

### Step 2: Create Railway Project
1. Go to [railway.app](https://railway.app)
2. Click "New Project"
3. Choose "Deploy from GitHub repo"
4. Select your repository
5. Choose the `ai_backend` directory

### Step 3: Configure Environment
In Railway dashboard:
1. Go to your project
2. Click "Variables"
3. Add these environment variables:
   ```
   PORT=5000
   FLASK_ENV=production
   FLASK_DEBUG=0
   ```

### Step 4: Deploy
```bash
# Deploy from command line
railway up

# Or use Railway dashboard
# Click "Deploy" button
```

### Step 5: Get Your URL
```bash
# Get your deployment URL
railway domain

# Example output: https://dressapp-ai-backend-production.up.railway.app
```

## 🔧 Update Flutter App

Update your Flutter app to use the cloud URL:

```dart
// In lib/core/services/ai_backend_manager.dart
class AIBackendManager {
  // Replace localhost with your Railway URL
  static const String baseUrl = 'https://your-app-name.up.railway.app';
}
```

## 📊 Monitoring

### Check Logs
```bash
railway logs
```

### Check Status
```bash
railway status
```

### Health Check
```bash
curl https://your-app-name.up.railway.app/health
```

## 💰 Pricing

- **Free Tier**: $5 credit/month
- **Pro**: $20/month
- **Team**: $20/user/month

## 🐛 Troubleshooting

### Common Issues

1. **Build Fails**
   ```bash
   # Check logs
   railway logs
   
   # Rebuild
   railway up --force
   ```

2. **Model Download Issues**
   - Railway will download models on first run
   - May take 2-3 minutes for first deployment

3. **Memory Issues**
   - Upgrade to Pro plan for more memory
   - Or optimize model size

### Performance Tips

1. **Enable Caching**
   ```python
   # Add to app.py
   from flask_caching import Cache
   cache = Cache(app, config={'CACHE_TYPE': 'simple'})
   ```

2. **Optimize Models**
   - Use smaller YOLO model (yolov8n)
   - Consider disabling SAM for faster processing

## ✅ Success Checklist

- [ ] Railway CLI installed
- [ ] Project created on Railway
- [ ] Code deployed successfully
- [ ] Health check passes
- [ ] Flutter app updated with new URL
- [ ] Tested with sample image

## 🎉 You're Done!

Your AI backend is now running in the cloud and accessible from anywhere! 