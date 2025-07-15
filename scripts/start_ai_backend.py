#!/usr/bin/env python3
"""
Script to start the AI backend as part of the Flutter build process
"""

import os
import sys
import subprocess
import time
import requests
import signal
from pathlib import Path

class AIBackendManager:
    def __init__(self, backend_path=None):
        self.backend_path = backend_path or Path(__file__).parent.parent / "ai_backend"
        self.process = None
        self.port = 5000
        
    def start_backend(self):
        """Start the AI backend server"""
        print("🚀 Starting AI Backend...")
        
        # Check if backend directory exists
        if not self.backend_path.exists():
            print(f"❌ AI backend directory not found: {self.backend_path}")
            return False
            
        # Change to backend directory
        os.chdir(self.backend_path)
        
        # Check if virtual environment exists
        venv_path = self.backend_path / "venv"
        if not venv_path.exists():
            print("📦 Creating virtual environment...")
            subprocess.run([sys.executable, "-m", "venv", "venv"], check=True)
        
        # Activate virtual environment and install dependencies
        if os.name == 'nt':  # Windows
            python_path = venv_path / "Scripts" / "python.exe"
            pip_path = venv_path / "Scripts" / "pip.exe"
        else:  # Unix/Linux/macOS
            python_path = venv_path / "bin" / "python"
            pip_path = venv_path / "bin" / "pip"
        
        # Install dependencies
        print("📦 Installing dependencies...")
        subprocess.run([str(pip_path), "install", "-r", "requirements.txt"], check=True)
        
        # Start the server
        print("🌐 Starting Flask server...")
        self.process = subprocess.Popen([
            str(python_path), "start_server.py"
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        # Wait for server to start
        print("⏳ Waiting for server to start...")
        for i in range(30):  # Wait up to 30 seconds
            try:
                response = requests.get(f"http://localhost:{self.port}/health", timeout=1)
                if response.status_code == 200:
                    print("✅ AI Backend started successfully!")
                    return True
            except requests.exceptions.RequestException:
                pass
            time.sleep(1)
        
        print("❌ Failed to start AI backend")
        return False
    
    def stop_backend(self):
        """Stop the AI backend server"""
        if self.process:
            print("🛑 Stopping AI Backend...")
            self.process.terminate()
            try:
                self.process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.process.kill()
            print("✅ AI Backend stopped")
    
    def is_running(self):
        """Check if the backend is running"""
        try:
            response = requests.get(f"http://localhost:{self.port}/health", timeout=1)
            return response.status_code == 200
        except requests.exceptions.RequestException:
            return False

def main():
    """Main function"""
    import argparse
    
    parser = argparse.ArgumentParser(description="AI Backend Manager")
    parser.add_argument("--start", action="store_true", help="Start the AI backend")
    parser.add_argument("--stop", action="store_true", help="Stop the AI backend")
    parser.add_argument("--status", action="store_true", help="Check backend status")
    parser.add_argument("--port", type=int, default=5000, help="Port number")
    
    args = parser.parse_args()
    
    manager = AIBackendManager()
    manager.port = args.port
    
    if args.start:
        if manager.is_running():
            print("✅ AI Backend is already running")
        else:
            success = manager.start_backend()
            if success:
                # Keep the process running
                try:
                    manager.process.wait()
                except KeyboardInterrupt:
                    manager.stop_backend()
    
    elif args.stop:
        manager.stop_backend()
    
    elif args.status:
        if manager.is_running():
            print("✅ AI Backend is running")
        else:
            print("❌ AI Backend is not running")
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main() 