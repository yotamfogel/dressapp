#!/usr/bin/env python3
"""
Script to deploy AI backend to various cloud platforms
"""

import os
import sys
import subprocess
import json
import requests
from pathlib import Path

class CloudDeployer:
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.ai_backend_path = self.project_root / "ai_backend"
        
    def check_prerequisites(self):
        """Check if all required files exist"""
        required_files = [
            "Dockerfile",
            "requirements.txt", 
            "app.py",
            "clothing_detector.py",
            "start_server.py"
        ]
        
        missing_files = []
        for file in required_files:
            if not (self.ai_backend_path / file).exists():
                missing_files.append(file)
        
        if missing_files:
            print(f"❌ Missing required files: {missing_files}")
            return False
        
        print("✅ All required files found")
        return True
    
    def deploy_railway(self):
        """Deploy to Railway"""
        print("🚂 Deploying to Railway...")
        
        try:
            # Check if Railway CLI is installed
            result = subprocess.run(["railway", "--version"], 
                                  capture_output=True, text=True)
            if result.returncode != 0:
                print("❌ Railway CLI not found.")
                print("📦 Installing Railway CLI...")
                
                # Check if npm is available
                npm_result = subprocess.run(["npm", "--version"], 
                                          capture_output=True, text=True)
                if npm_result.returncode != 0:
                    print("❌ npm not found. Please install Node.js first:")
                    print("   Download from: https://nodejs.org/")
                    print("   Then run: npm install -g @railway/cli")
                    return None
                
                try:
                    subprocess.run(["npm", "install", "-g", "@railway/cli"], check=True)
                    print("✅ Railway CLI installed successfully")
                except subprocess.CalledProcessError:
                    print("❌ Failed to install Railway CLI via npm")
                    print("🔧 Alternative installation methods:")
                    print("   1. Download from: https://railway.app/cli")
                    print("   2. Or use: curl -fsSL https://railway.app/install.sh | sh")
                    return None
            
            # Navigate to AI backend
            os.chdir(self.ai_backend_path)
            
            # Initialize Railway project
            print("📦 Initializing Railway project...")
            subprocess.run(["railway", "init"], check=True)
            
            # Deploy
            print("🚀 Deploying...")
            subprocess.run(["railway", "up"], check=True)
            
            # Get URL
            print("🔗 Getting deployment URL...")
            result = subprocess.run(["railway", "domain"], 
                                  capture_output=True, text=True, check=True)
            url = result.stdout.strip()
            
            print(f"✅ Deployed successfully!")
            print(f"🌐 URL: {url}")
            print(f"🏥 Health check: {url}/health")
            
            return url
            
        except subprocess.CalledProcessError as e:
            print(f"❌ Railway deployment failed: {e}")
            return None
    
    def deploy_render(self):
        """Deploy to Render (manual steps)"""
        print("🎨 Render Deployment Instructions:")
        print("=" * 50)
        print("1. Go to https://render.com")
        print("2. Sign up with GitHub")
        print("3. Click 'New +' → 'Web Service'")
        print("4. Connect your GitHub repository")
        print("5. Choose 'ai_backend' directory")
        print("6. Configure:")
        print("   - Name: dressapp-ai-backend")
        print("   - Environment: Python 3")
        print("   - Build Command: pip install -r requirements.txt")
        print("   - Start Command: python start_server.py")
        print("7. Add environment variables:")
        print("   - PYTHON_VERSION=3.11.0")
        print("   - PORT=10000")
        print("   - FLASK_ENV=production")
        print("   - FLASK_DEBUG=0")
        print("8. Click 'Create Web Service'")
        print("=" * 50)
        
        # Ask for the actual URL
        url = input("\nEnter your Render URL (e.g., https://your-app.onrender.com): ").strip()
        if not url:
            url = "https://your-app-name.onrender.com"
        
        return url
    
    def deploy_railway_manual(self):
        """Deploy to Railway (manual steps)"""
        print("🚂 Railway Manual Deployment Instructions:")
        print("=" * 50)
        print("1. Go to https://railway.app")
        print("2. Sign up with GitHub")
        print("3. Click 'New Project'")
        print("4. Choose 'Deploy from GitHub repo'")
        print("5. Select your repository")
        print("6. Choose 'ai_backend' directory")
        print("7. Railway will automatically detect and deploy")
        print("8. Wait for deployment to complete")
        print("=" * 50)
        
        # Ask for the actual URL
        url = input("\nEnter your Railway URL (e.g., https://your-app.up.railway.app): ").strip()
        if not url:
            url = "https://your-app-name.up.railway.app"
        
        return url
    
    def deploy_heroku(self):
        """Deploy to Heroku"""
        print("🦸 Deploying to Heroku...")
        
        try:
            # Check if Heroku CLI is installed
            result = subprocess.run(["heroku", "--version"], 
                                  capture_output=True, text=True)
            if result.returncode != 0:
                print("❌ Heroku CLI not found. Please install from:")
                print("https://devcenter.heroku.com/articles/heroku-cli")
                return None
            
            # Navigate to AI backend
            os.chdir(self.ai_backend_path)
            
            # Login to Heroku
            print("🔐 Logging into Heroku...")
            subprocess.run(["heroku", "login"], check=True)
            
            # Create Heroku app
            app_name = input("Enter Heroku app name (or press Enter for auto-generate): ").strip()
            if not app_name:
                subprocess.run(["heroku", "create"], check=True)
            else:
                subprocess.run(["heroku", "create", app_name], check=True)
            
            # Add buildpacks
            print("📦 Adding buildpacks...")
            subprocess.run(["heroku", "buildpacks:add", "heroku/python"], check=True)
            
            # Deploy
            print("🚀 Deploying...")
            subprocess.run(["git", "add", "."], check=True)
            subprocess.run(["git", "commit", "-m", "Deploy AI backend"], check=True)
            subprocess.run(["git", "push", "heroku", "main"], check=True)
            
            # Get URL
            result = subprocess.run(["heroku", "info", "-s"], 
                                  capture_output=True, text=True, check=True)
            url = None
            for line in result.stdout.split('\n'):
                if line.startswith('web_url='):
                    url = line.split('=')[1]
                    break
            
            print(f"✅ Deployed successfully!")
            print(f"🌐 URL: {url}")
            print(f"🏥 Health check: {url}/health")
            
            return url
            
        except subprocess.CalledProcessError as e:
            print(f"❌ Heroku deployment failed: {e}")
            return None
    
    def test_deployment(self, url):
        """Test the deployed backend"""
        print(f"🧪 Testing deployment at {url}...")
        
        try:
            # Test health endpoint
            response = requests.get(f"{url}/health", timeout=10)
            if response.status_code == 200:
                print("✅ Health check passed")
                data = response.json()
                print(f"📊 Models loaded: {data.get('models_loaded', {})}")
            else:
                print(f"❌ Health check failed: {response.status_code}")
                return False
            
            # Test detection endpoint
            print("🧪 Testing detection endpoint...")
            test_response = requests.get(f"{url}/test", timeout=30)
            if test_response.status_code == 200:
                print("✅ Detection test passed")
                return True
            else:
                print(f"❌ Detection test failed: {test_response.status_code}")
                return False
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Test failed: {e}")
            return False
    
    def update_flutter_config(self, url):
        """Update Flutter app configuration with new URL"""
        print("📱 Updating Flutter configuration...")
        
        # Find AI backend manager file
        ai_manager_path = self.project_root / "lib" / "core" / "services" / "ai_backend_manager.dart"
        
        if not ai_manager_path.exists():
            print("⚠️ AI backend manager file not found")
            return False
        
        # Read current file
        with open(ai_manager_path, 'r') as f:
            content = f.read()
        
        # Update URL
        import re
        updated_content = re.sub(
            r"static const String baseUrl = '.*?';",
            f"static const String baseUrl = '{url}';",
            content
        )
        
        # Write updated file
        with open(ai_manager_path, 'w') as f:
            f.write(updated_content)
        
        print(f"✅ Updated Flutter config with URL: {url}")
        return True

def main():
    """Main deployment function"""
    print("☁️ AI Backend Cloud Deployment")
    print("=" * 40)
    
    deployer = CloudDeployer()
    
    # Check prerequisites
    if not deployer.check_prerequisites():
        print("❌ Prerequisites not met. Please check missing files.")
        return
    
    # Choose platform
    print("\nChoose deployment platform:")
    print("1. Railway (Recommended - Free tier)")
    print("2. Railway Manual (No CLI required)")
    print("3. Render (Free tier)")
    print("4. Heroku (Paid)")
    print("5. Exit")
    
    choice = input("\nEnter your choice (1-5): ").strip()
    
    url = None
    
    if choice == "1":
        url = deployer.deploy_railway()
    elif choice == "2":
        url = deployer.deploy_railway_manual()
    elif choice == "3":
        url = deployer.deploy_render()
    elif choice == "4":
        url = deployer.deploy_heroku()
    elif choice == "5":
        print("👋 Goodbye!")
        return
    else:
        print("❌ Invalid choice")
        return
    
    if url:
        # Test deployment
        if deployer.test_deployment(url):
            print("🎉 Deployment successful!")
            
            # Update Flutter config
            deployer.update_flutter_config(url)
            
            print("\n📱 Next steps:")
            print("1. Build your Flutter app: flutter build apk --release")
            print("2. Install on your phone: flutter install")
            print("3. Test AI features with the cloud backend")
            
        else:
            print("❌ Deployment test failed")
    else:
        print("❌ Deployment failed")

if __name__ == "__main__":
    main() 