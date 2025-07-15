# 🚀 Remote AI Backend Setup Guide

## 📋 Overview
This guide will help you deploy your AI backend to the cloud and integrate it with your Flutter app.

## 🔧 Step 1: Deploy AI Backend to Railway

### Option A: Using Railway Web Interface (Recommended)
1. **Go to Railway**: Visit [railway.app](https://railway.app/)
2. **Sign up/Login**: Use your GitHub account
3. **Create New Project**: Click "New Project"
4. **Connect Repository**: Select "Deploy from GitHub repo"
5. **Choose Repository**: Select your `ai_clothing_backend` repository
6. **Auto-Detection**: Railway will detect it's a Python app
7. **Deploy**: Click "Deploy" and wait 5-10 minutes

### Option B: Using Railway CLI
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Deploy from your ai_backend directory
cd ai_backend
railway up
```

## 🌐 Step 2: Get Your Backend URL

After deployment, Railway will provide a URL like:
```
https://your-app-name.railway.app
```

## 🧪 Step 3: Test Your Backend

Test the health endpoint:
```
https://your-app-name.railway.app/health
```

You should see: `{"status": "healthy", "message": "AI Backend is running"}`

## 📱 Step 4: Update Flutter App

### Update the Backend URL
Edit `lib/core/services/ai_backend_manager.dart`:

```dart
// Change this line:
static const String _baseUrl = 'https://your-ai-backend.railway.app';

// To your actual Railway URL:
static const String _baseUrl = 'https://your-app-name.railway.app';
```

### Test the Integration
1. **Run your Flutter app**
2. **Navigate to the AI Test Widget** (you can add it to your home screen)
3. **Test the connection** - it should show "AI Backend Available"
4. **Try analyzing an image** - upload a photo and test the AI

## 🔄 Step 5: Auto-Push Setup

### Using the Auto-Push Script
After making changes to your AI backend:

```bash
# Navigate to ai_backend directory
cd ai_backend

# Run the auto-push script
./auto_push.bat
```

Or manually:
```bash
git add .
git commit -m "Your commit message"
git push origin main
```

### Git Hook (Automatic)
The post-commit hook will automatically push to GitHub after every commit.

## 🎯 Step 6: Integration Examples

### Basic Usage in Flutter
```dart
import 'dart:io';
import 'package:your_app/core/services/ai_clothing_service.dart';

// Check if backend is available
bool isAvailable = await AIClothingService.isAvailable();

// Analyze an image
File imageFile = File('path/to/image.jpg');
ClothingAnalysis? analysis = await AIClothingService.analyzeClothing(imageFile);

if (analysis != null) {
  // Access results
  List<ClothingItem> items = analysis.clothingItems;
  ColorAnalysis? colors = analysis.colorAnalysis;
}
```

### Add AI Test to Your App
Add this to your home screen or settings:

```dart
// In your home page or navigation
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AITestWidget(),
      ),
    );
  },
  child: const Text('Test AI Backend'),
)
```

## 🔍 Troubleshooting

### Backend Not Available
1. **Check Railway deployment**: Ensure it's running
2. **Verify URL**: Make sure the URL in `ai_backend_manager.dart` is correct
3. **Check logs**: View Railway logs for errors
4. **Test endpoint**: Try the health endpoint in browser

### Image Analysis Fails
1. **Check image format**: Ensure it's a valid image file
2. **Image size**: Try smaller images (under 5MB)
3. **Network**: Check internet connection
4. **Backend logs**: Check Railway logs for errors

### Auto-Push Issues
1. **Git credentials**: Ensure Git is configured
2. **Repository access**: Check GitHub permissions
3. **Network**: Ensure internet connection

## 📊 Monitoring

### Railway Dashboard
- **Logs**: View real-time logs
- **Metrics**: Monitor performance
- **Deployments**: Track deployment history

### Health Checks
Your app can check backend health:
```dart
bool isHealthy = await AIClothingService.isAvailable();
```

## 🚀 Next Steps

1. **Deploy to Railway** using the guide above
2. **Update the Flutter app** with your Railway URL
3. **Test the integration** using the AI Test Widget
4. **Integrate AI features** into your main app flow
5. **Monitor performance** and optimize as needed

## 📞 Support

If you encounter issues:
1. Check Railway logs
2. Verify network connectivity
3. Test endpoints manually
4. Review error messages in Flutter console

---

**🎉 Congratulations!** Your AI backend is now deployed and ready to use with your Flutter app! 