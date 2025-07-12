# Deploy AI Backend to Render

Render is another excellent option with a free tier and easy deployment.

## 🚀 Quick Deploy Steps

### 1. Create Render Account
1. Go to [render.com](https://render.com)
2. Sign up with GitHub
3. Connect your repository

### 2. Create New Web Service
1. Click "New +"
2. Select "Web Service"
3. Connect your GitHub repo
4. Choose the `ai_backend` directory

### 3. Configure Service
```
Name: dressapp-ai-backend
Environment: Python 3
Build Command: pip install -r requirements.txt
Start Command: python start_server.py
```

### 4. Deploy
Click "Create Web Service"

## 📋 Detailed Configuration

### Environment Variables
Add these in Render dashboard:
```
PYTHON_VERSION=3.11.0
PORT=10000
FLASK_ENV=production
FLASK_DEBUG=0
```

### Auto-Deploy Settings
- ✅ Auto-Deploy: Yes
- ✅ Branch: main
- ✅ Health Check Path: /health

## 🔧 Update Flutter App

```dart
// In lib/core/services/ai_backend_manager.dart
class AIBackendManager {
  // Replace with your Render URL
  static const String baseUrl = 'https://your-app-name.onrender.com';
}
```

## 💰 Pricing

- **Free Tier**: 750 hours/month
- **Starter**: $7/month
- **Standard**: $25/month

## 🐛 Troubleshooting

### Common Issues

1. **Build Timeout**
   - Free tier has 15-minute build limit
   - Consider upgrading for larger models

2. **Memory Issues**
   - Free tier: 512MB RAM
   - Upgrade for AI model requirements

3. **Cold Start**
   - Free tier services sleep after 15 minutes
   - First request may take 30-60 seconds

## ✅ Success Checklist

- [ ] Render account created
- [ ] Web service configured
- [ ] Environment variables set
- [ ] Deployment successful
- [ ] Health check passes
- [ ] Flutter app updated
- [ ] Tested with sample image 