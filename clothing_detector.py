import cv2
import numpy as np
from sklearn.cluster import KMeans
import webcolors
from ultralytics import YOLO
from segment_anything import SamPredictor, sam_model_registry
import os
from typing import List, Tuple, Dict, Any

class ClothingDetector:
    def __init__(self):
        """Initialize the clothing detector with YOLO and SAM models"""
        print("🚀 Initializing Clothing Detector...")
        
        # Initialize YOLO model for clothing detection
        self.yolo_model = YOLO('yolov8n.pt')
        print("✅ YOLO model loaded")
        
        # Initialize SAM for segmentation
        try:
            self.sam = sam_model_registry["vit_b"](checkpoint="sam_vit_b.pth")
            self.sam_predictor = SamPredictor(self.sam)
            print("✅ SAM model loaded")
        except FileNotFoundError:
            print("⚠️ SAM model not found, using basic segmentation")
            self.sam_predictor = None
        
        # Clothing categories from COCO dataset
        self.clothing_categories = [
            'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck', 'boat',
            'traffic light', 'fire hydrant', 'stop sign', 'parking meter', 'bench', 'bird', 'cat',
            'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe', 'backpack',
            'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee', 'skis', 'snowboard', 'sports ball',
            'kite', 'baseball bat', 'baseball glove', 'skateboard', 'surfboard', 'tennis racket',
            'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple',
            'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake',
            'chair', 'couch', 'potted plant', 'bed', 'dining table', 'toilet', 'tv', 'laptop',
            'mouse', 'remote', 'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink',
            'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear', 'hair drier',
            'toothbrush'
        ]
        
        print("✅ Clothing Detector initialized successfully")
    
    def load_image(self, image_path: str) -> np.ndarray:
        """Step 1: Load and preprocess image"""
        image = cv2.imread(image_path)
        if image is None:
            raise ValueError(f"Could not load image from {image_path}")
        return cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    
    def detect_clothing(self, image: np.ndarray) -> np.ndarray:
        """Step 2: Detect clothing with YOLOv8"""
        results = self.yolo_model.predict(image)
        if len(results) == 0 or len(results[0].boxes) == 0:
            return np.array([])
        
        # Get bounding boxes for person class (index 0) and clothing-related items
        clothing_boxes = []
        for result in results:
            boxes = result.boxes
            if boxes is not None:
                for box in boxes:
                    # Filter for person and clothing-related items
                    class_id = int(box.cls[0])
                    if class_id == 0:  # person
                        clothing_boxes.append(box.xyxy[0].cpu().numpy())
        
        return np.array(clothing_boxes)
    
    def crop_regions(self, image: np.ndarray, boxes: np.ndarray) -> List[np.ndarray]:
        """Step 3: Crop detected clothes"""
        crops = []
        for box in boxes:
            x1, y1, x2, y2 = map(int, box)
            # Ensure coordinates are within image bounds
            x1 = max(0, x1)
            y1 = max(0, y1)
            x2 = min(image.shape[1], x2)
            y2 = min(image.shape[0], y2)
            
            if x2 > x1 and y2 > y1:
                crop = image[y1:y2, x1:x2]
                crops.append(crop)
        
        return crops
    
    def get_masks(self, crop: np.ndarray) -> np.ndarray:
        """Step 4: Segment clothes using SAM"""
        if self.sam_predictor is None:
            # Fallback to basic segmentation
            return np.ones(crop.shape[:2], dtype=np.uint8)
        
        try:
            self.sam_predictor.set_image(crop)
            masks, _, _ = self.sam_predictor.predict(
                point_coords=None, 
                point_labels=None, 
                multimask_output=False
            )
            return masks[0]  # binary mask
        except Exception as e:
            print(f"⚠️ SAM segmentation failed: {e}")
            # Fallback to basic segmentation
            return np.ones(crop.shape[:2], dtype=np.uint8)
    
    def get_color_percentages(self, image: np.ndarray, mask: np.ndarray = None, k: int = 3) -> List[Tuple[np.ndarray, float]]:
        """Step 5: Extract dominant colors + percentages"""
        # Apply mask if provided
        if mask is not None:
            masked_image = image[mask > 0]
            if len(masked_image) == 0:
                return []
            image = masked_image
        
        # Reshape image for clustering
        image = image.reshape(-1, 3)
        
        # Run KMeans to find dominant colors
        kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
        kmeans.fit(image)
        colors = kmeans.cluster_centers_.astype(int)
        labels = kmeans.labels_
        
        # Calculate percentages
        unique, counts = np.unique(labels, return_counts=True)
        percentages = counts / counts.sum()
        
        return list(zip(colors, percentages))
    
    def closest_color_name(self, rgb: np.ndarray) -> str:
        """Step 6: Convert RGB to named colors"""
        try:
            return webcolors.rgb_to_name(tuple(rgb))
        except ValueError:
            # Find closest named color
            min_dist = float('inf')
            closest_name = None
            for name, hex_val in webcolors.CSS3_NAMES_TO_HEX.items():
                r_c, g_c, b_c = webcolors.hex_to_rgb(hex_val)
                dist = sum((rgb[i] - [r_c, g_c, b_c][i]) ** 2 for i in range(3))
                if dist < min_dist:
                    min_dist = dist
                    closest_name = name
            return closest_name or 'unknown'
    
    def describe_outfit(self, clothing_color_data: List[Tuple[np.ndarray, float]]) -> str:
        """Step 7: Generate description using color data"""
        if not clothing_color_data:
            return "No clothing detected."
        
        description = []
        for rgb, pct in clothing_color_data:
            color_name = self.closest_color_name(rgb)
            description.append(f"{int(pct*100)}% {color_name}")
        
        return "The clothing item contains: " + ", ".join(description) + "."
    
    def analyze_clothing(self, image_path: str) -> Dict[str, Any]:
        """Step 8: End-to-End Runner"""
        try:
            # Load image
            image = self.load_image(image_path)
            
            # Detect clothing
            boxes = self.detect_clothing(image)
            
            if len(boxes) == 0:
                return {
                    'success': False,
                    'error': 'No clothing detected in the image',
                    'detections': []
                }
            
            # Crop regions
            crops = self.crop_regions(image, boxes)
            
            results = []
            for i, crop in enumerate(crops):
                try:
                    # Get segmentation mask
                    mask = self.get_masks(crop)
                    
                    # Get color percentages
                    colors = self.get_color_percentages(crop, mask)
                    
                    # Generate description
                    description = self.describe_outfit(colors)
                    
                    # Format color data for response
                    color_data = []
                    for rgb, percentage in colors:
                        color_name = self.closest_color_name(rgb)
                        color_data.append({
                            'name': color_name,
                            'rgb': rgb.tolist(),
                            'percentage': float(percentage * 100)
                        })
                    
                    results.append({
                        'index': i,
                        'success': True,
                        'description': description,
                        'colors': color_data,
                        'clothing_type': 'person',  # Default for now
                        'confidence': 0.8  # Default confidence
                    })
                    
                except Exception as e:
                    results.append({
                        'index': i,
                        'success': False,
                        'error': str(e)
                    })
            
            return {
                'success': True,
                'detections': results
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'detections': []
            }
    
    def detect_clothing_from_array(self, image_array: np.ndarray) -> Dict[str, Any]:
        """Analyze clothing from numpy array (for API use)"""
        try:
            # Convert BGR to RGB if needed
            if len(image_array.shape) == 3 and image_array.shape[2] == 3:
                image = cv2.cvtColor(image_array, cv2.COLOR_BGR2RGB)
            else:
                image = image_array
            
            # Detect clothing
            boxes = self.detect_clothing(image)
            
            if len(boxes) == 0:
                return {
                    'success': False,
                    'error': 'No clothing detected in the image',
                    'detections': []
                }
            
            # Crop regions
            crops = self.crop_regions(image, boxes)
            
            results = []
            for i, crop in enumerate(crops):
                try:
                    # Get segmentation mask
                    mask = self.get_masks(crop)
                    
                    # Get color percentages
                    colors = self.get_color_percentages(crop, mask)
                    
                    # Generate description
                    description = self.describe_outfit(colors)
                    
                    # Format color data for response
                    color_data = []
                    for rgb, percentage in colors:
                        color_name = self.closest_color_name(rgb)
                        color_data.append({
                            'name': color_name,
                            'rgb': rgb.tolist(),
                            'percentage': float(percentage * 100)
                        })
                    
                    results.append({
                        'index': i,
                        'success': True,
                        'description': description,
                        'colors': color_data,
                        'clothing_type': 'person',  # Default for now
                        'confidence': 0.8  # Default confidence
                    })
                    
                except Exception as e:
                    results.append({
                        'index': i,
                        'success': False,
                        'error': str(e)
                    })
            
            return {
                'success': True,
                'detections': results
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'detections': []
            } 