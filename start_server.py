#!/usr/bin/env python3
"""
Startup script for the AI Clothing Detection API
"""

import os
import sys
from app import app

if __name__ == '__main__':
    # Set environment variables
    os.environ['FLASK_ENV'] = 'development'
    os.environ['FLASK_DEBUG'] = '1'
    
    # Get port from environment or use default
    port = int(os.environ.get('PORT', 5000))
    
    print(f"🚀 Starting AI Clothing Detection API on port {port}")
    print(f"📡 API will be available at: http://localhost:{port}")
    print(f"🏥 Health check: http://localhost:{port}/health")
    print(f"👕 Clothing detection: http://localhost:{port}/detect-clothing")
    print(f"👗 Closet analysis: http://localhost:{port}/analyze-closet")
    print(f"🧪 Test endpoint: http://localhost:{port}/test")
    print("\nPress Ctrl+C to stop the server")
    
    try:
        app.run(host='0.0.0.0', port=port, debug=True)
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"❌ Error starting server: {e}")
        sys.exit(1) 