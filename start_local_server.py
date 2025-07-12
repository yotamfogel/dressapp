#!/usr/bin/env python3
"""
Local AI Backend Server for DressApp
Runs on localhost:5000 for emulator testing
"""

import os
import sys
from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import cv2
import numpy as np
from clothing_detector import ClothingDetector
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Initialize the clothing detector
detector = None

def initialize_detector():
    """Initialize the clothing detector with SAM"""
    global detector
    try:
        logger.info("🚀 Initializing Clothing Detector with SAM...")
        detector = ClothingDetector()
        logger.info("✅ Clothing Detector initialized successfully!")
        return True
    except Exception as e:
        logger.error(f"❌ Failed to initialize detector: {e}")
        return False

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'message': 'AI Backend is running locally',
        'sam_loaded': detector is not None
    })

@app.route('/detect-clothing', methods=['POST'])
def detect_clothing():
    """Detect clothing items in an image"""
    try:
        if detector is None:
            return jsonify({
                'success': False,
                'error': 'AI detector not initialized'
            }), 500

        # Get image data from request
        data = request.get_json()
        if not data or 'image' not in data:
            return jsonify({
                'success': False,
                'error': 'No image data provided'
            }), 400

        # Decode base64 image
        image_data = base64.b64decode(data['image'])
        nparr = np.frombuffer(image_data, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if image is None:
            return jsonify({
                'success': False,
                'error': 'Invalid image data'
            }), 400

        # Save temporary image for analysis
        temp_path = 'temp_image.jpg'
        cv2.imwrite(temp_path, image)
        
        try:
            # Analyze clothing
            result = detector.analyze_clothing(temp_path)
            
            # Clean up temp file
            if os.path.exists(temp_path):
                os.remove(temp_path)
            
            return jsonify(result)
            
        except Exception as e:
            # Clean up temp file on error
            if os.path.exists(temp_path):
                os.remove(temp_path)
            raise e

    except Exception as e:
        logger.error(f"Error in detect-clothing: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/analyze-colors', methods=['POST'])
def analyze_colors():
    """Analyze colors in an image"""
    try:
        if detector is None:
            return jsonify({
                'success': False,
                'error': 'AI detector not initialized'
            }), 500

        # Get image data from request
        data = request.get_json()
        if not data or 'image' not in data:
            return jsonify({
                'success': False,
                'error': 'No image data provided'
            }), 400

        # Decode base64 image
        image_data = base64.b64decode(data['image'])
        nparr = np.frombuffer(image_data, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if image is None:
            return jsonify({
                'success': False,
                'error': 'Invalid image data'
            }), 400

        # Save temporary image for analysis
        temp_path = 'temp_image.jpg'
        cv2.imwrite(temp_path, image)
        
        try:
            # Analyze clothing
            result = detector.analyze_clothing(temp_path)
            
            # Clean up temp file
            if os.path.exists(temp_path):
                os.remove(temp_path)
            
            # Extract color analysis from result
            if result.get('success') and result.get('detections'):
                # Get the first detection's color analysis
                first_detection = result['detections'][0]
                color_analysis = {
                    'success': True,
                    'dominant_colors': first_detection.get('colors', []),
                    'description': first_detection.get('description', 'No color analysis available')
                }
                return jsonify(color_analysis)
            else:
                return jsonify({
                    'success': False,
                    'error': 'No clothing detected for color analysis'
                })
            
        except Exception as e:
            # Clean up temp file on error
            if os.path.exists(temp_path):
                os.remove(temp_path)
            raise e

    except Exception as e:
        logger.error(f"Error in analyze-colors: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/test', methods=['GET'])
def test_endpoint():
    """Test endpoint for debugging"""
    return jsonify({
        'message': 'Local AI Backend is working!',
        'detector_loaded': detector is not None,
        'endpoints': [
            '/health',
            '/detect-clothing',
            '/analyze-colors',
            '/test'
        ]
    })

if __name__ == '__main__':
    print("🤖 Starting Local AI Backend Server...")
    print("📍 Server will run on: http://localhost:5000")
    print("📱 For Android emulator, use: http://10.0.2.2:5000")
    print("🍎 For iOS simulator, use: http://localhost:5000")
    print()
    
    # Initialize detector
    if not initialize_detector():
        print("❌ Failed to initialize AI detector. Exiting...")
        sys.exit(1)
    
    # Start the server
    print("🚀 Starting Flask server...")
    app.run(
        host='0.0.0.0',  # Allow external connections
        port=5000,
        debug=True,  # Enable debug mode for development
        threaded=True
    ) 