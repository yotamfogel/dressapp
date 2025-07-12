#!/usr/bin/env python3
"""
Test script for the AI Clothing Detection system
"""

import numpy as np
import cv2
from clothing_detector import ClothingDetector
import time

def create_test_image():
    """Create a test image with different colored regions"""
    # Create a 400x400 test image
    image = np.zeros((400, 400, 3), dtype=np.uint8)
    
    # Add red region (70% of image)
    image[0:280, 0:400] = [255, 0, 0]  # Red
    
    # Add black region (30% of image)
    image[280:400, 0:400] = [0, 0, 0]  # Black
    
    return image

def test_clothing_detector():
    """Test the clothing detector with a simple image"""
    print("🧪 Testing Clothing Detector...")
    
    try:
        # Initialize detector
        detector = ClothingDetector()
        print("✅ Detector initialized successfully")
        
        # Create test image
        test_image = create_test_image()
        print("✅ Test image created")
        
        # Test color detection
        print("\n🎨 Testing color detection...")
        colors = detector.get_color_percentages(test_image)
        
        print("Detected colors:")
        for rgb, percentage in colors:
            color_name = detector.closest_color_name(rgb)
            print(f"  - {color_name}: {percentage*100:.1f}% (RGB: {rgb})")
        
        # Test description generation
        print("\n📝 Testing description generation...")
        description = detector.describe_outfit(colors)
        print(f"Description: {description}")
        
        # Test full detection pipeline
        print("\n🔍 Testing full detection pipeline...")
        start_time = time.time()
        results = detector.detect_clothing_from_array(test_image)
        end_time = time.time()
        
        print(f"Detection completed in {end_time - start_time:.2f} seconds")
        print(f"Results: {results}")
        
        print("\n✅ All tests passed!")
        return True
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False

def test_with_real_image(image_path):
    """Test with a real image file"""
    print(f"🧪 Testing with real image: {image_path}")
    
    try:
        detector = ClothingDetector()
        results = detector.analyze_clothing(image_path)
        
        print("Results:")
        print(results)
        
        return True
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False

if __name__ == "__main__":
    print("🚀 AI Clothing Detection Test Suite")
    print("=" * 40)
    
    # Test with synthetic image
    success = test_clothing_detector()
    
    if success:
        print("\n🎉 All tests completed successfully!")
    else:
        print("\n💥 Some tests failed!")
        exit(1) 