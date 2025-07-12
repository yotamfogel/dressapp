from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import io
from PIL import Image
import numpy as np
import cv2
from clothing_detector import ClothingDetector
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

# Initialize the clothing detector
detector = ClothingDetector()

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy', 
        'message': 'AI Clothing Detection API is running',
        'models_loaded': {
            'yolo': True,
            'sam': detector.sam_predictor is not None
        }
    })

@app.route('/detect-clothing', methods=['POST'])
def detect_clothing():
    """Detect clothing types and colors from uploaded image"""
    try:
        # Get image data from request
        if 'image' not in request.files and 'image_base64' not in request.json:
            return jsonify({'error': 'No image provided'}), 400
        
        # Handle base64 encoded image
        if 'image_base64' in request.json:
            image_data = request.json['image_base64']
            # Remove data URL prefix if present
            if image_data.startswith('data:image'):
                image_data = image_data.split(',')[1]
            
            image_bytes = base64.b64decode(image_data)
            image = Image.open(io.BytesIO(image_bytes))
        
        # Handle file upload
        elif 'image' in request.files:
            file = request.files['image']
            image = Image.open(file.stream)
        
        # Convert to RGB if necessary
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Convert PIL image to numpy array
        image_array = np.array(image)
        
        # Detect clothing
        results = detector.detect_clothing_from_array(image_array)
        
        return jsonify(results)
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/analyze-closet', methods=['POST'])
def analyze_closet():
    """Analyze multiple clothing items from closet"""
    try:
        if 'images' not in request.json:
            return jsonify({'error': 'No images provided'}), 400
        
        images_data = request.json['images']
        results = []
        
        for i, image_data in enumerate(images_data):
            try:
                # Remove data URL prefix if present
                if image_data.startswith('data:image'):
                    image_data = image_data.split(',')[1]
                
                image_bytes = base64.b64decode(image_data)
                image = Image.open(io.BytesIO(image_bytes))
                
                if image.mode != 'RGB':
                    image = image.convert('RGB')
                
                image_array = np.array(image)
                detection = detector.detect_clothing_from_array(image_array)
                
                results.append({
                    'index': i,
                    'success': True,
                    'detection': detection
                })
                
            except Exception as e:
                results.append({
                    'index': i,
                    'success': False,
                    'error': str(e)
                })
        
        return jsonify({
            'success': True,
            'results': results
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/test', methods=['GET'])
def test_detection():
    """Test endpoint to verify the detector is working"""
    try:
        # Create a simple test image (red rectangle)
        test_image = np.zeros((300, 300, 3), dtype=np.uint8)
        test_image[:, :, 0] = 255  # Red channel
        
        results = detector.detect_clothing_from_array(test_image)
        
        return jsonify({
            'success': True,
            'test_results': results,
            'message': 'Test completed successfully'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True) 