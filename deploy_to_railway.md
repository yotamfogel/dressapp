# Deploy AI Backend to Railway

## Step 1: Prepare Your Repository
1. Make sure your code is pushed to GitHub
2. Your repository should be public or you need to connect your GitHub account to Railway

## Step 2: Deploy via Railway Web Interface
1. Go to [Railway.app](https://railway.app/)
2. Sign up/Login with your GitHub account
3. Click "New Project"
4. Select "Deploy from GitHub repo"
5. Choose your `ai_clothing_backend` repository
6. Railway will automatically detect it's a Python app

## Step 3: Configure Environment Variables
Add these environment variables in Railway dashboard:
- `PORT`: `8000`
- `PYTHON_VERSION`: `3.9`

## Step 4: Deploy
1. Click "Deploy"
2. Wait for the build to complete (5-10 minutes)
3. Once deployed, Railway will give you a URL like: `https://your-app-name.railway.app`

## Step 5: Test the Deployment
Test your API endpoint:
```
https://your-app-name.railway.app/health
```

## Step 6: Update Flutter App
Once you have the URL, update your Flutter app's AI backend URL.

## Alternative: Deploy to Render
If Railway doesn't work, you can also deploy to Render:
1. Go to [Render.com](https://render.com/)
2. Create a new Web Service
3. Connect your GitHub repo
4. Use the same configuration 