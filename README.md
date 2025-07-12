# AI Clothing Detection System

This system detects clothing items in images and analyzes their color distribution using advanced AI models.

## 🚀 Features

- **YOLOv8 Object Detection**: Detects people and clothing items in images
- **SAM Segmentation**: Precise segmentation of clothing items
- **Color Analysis**: Extracts dominant colors with percentages
- **Named Color Mapping**: Converts RGB values to human-readable color names
- **REST API**: Flask-based API for easy integration

## 📋 Requirements

- Python 3.8+
- CUDA-compatible GPU (optional, for faster processing)
- 4GB+ RAM

## 🛠️ Installation

1. **Clone the repository and navigate to the AI backend:**
   ```bash
   cd ai_backend
   ```

2. **Create a virtual environment:**
   ```bash
   python -m venv venv
   
   # On Windows:
   venv\Scripts\activate
   
   # On macOS/Linux:
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Download SAM model (optional):**
   ```bash
   # Download SAM model for better segmentation
   wget https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth -O sam_vit_b.pth
   ```

## 🧪 Testing

Run the test suite to verify everything is working:

```bash
python test_ai.py
```

## 🚀 Running the Server

Start the AI backend server:

```bash
python start_server.py
```

The server will be available at `http://localhost:5000`

## 📡 API Endpoints

### Health Check
```
GET /health
```
Returns server status and model information.

### Single Image Detection
```
POST /detect-clothing
```
Analyzes a single image for clothing detection.

**Request Body:**
```json
{
  "image_base64": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ..."
}
```

**Response:**
```json
{
  "success": true,
  "detections": [
    {
      "index": 0,
      "success": true,
      "description": "The clothing item contains: 70% red, 30% black.",
      "colors": [
        {
          "name": "red",
          "rgb": [255, 0, 0],
          "percentage": 70.0
        },
        {
          "name": "black",
          "rgb": [0, 0, 0],
          "percentage": 30.0
        }
      ],
      "clothing_type": "person",
      "confidence": 0.8
    }
  ]
}
```

### Multiple Images Analysis
```
POST /analyze-closet
```
Analyzes multiple images (for closet analysis).

**Request Body:**
```json
{
  "images": [
    "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...",
    "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ..."
  ]
}
```

### Test Endpoint
```
GET /test
```
Tests the system with a synthetic image.

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the `ai_backend` directory:

```env
PORT=5000
FLASK_ENV=development
FLASK_DEBUG=1
```

### Model Configuration

- **YOLO Model**: Uses `yolov8n.pt` by default (lightweight)
- **SAM Model**: Uses `sam_vit_b.pth` for segmentation (optional)

## 📊 Performance

- **YOLO Detection**: ~100-200ms per image
- **SAM Segmentation**: ~500-1000ms per image (if available)
- **Color Analysis**: ~50-100ms per image
- **Total Pipeline**: ~1-2 seconds per image

## 🐛 Troubleshooting

### Common Issues

1. **CUDA Out of Memory**
   - Use CPU-only mode or reduce image size
   - Add `torch.cuda.empty_cache()` in code

2. **SAM Model Not Found**
   - System will fall back to basic segmentation
   - Download the model manually if needed

3. **Import Errors**
   - Ensure all dependencies are installed
   - Check Python version compatibility

### Debug Mode

Enable debug logging:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## 🔄 Integration with Flutter App

The Flutter app can integrate with this AI backend by:

1. **Sending images** via the `/detect-clothing` endpoint
2. **Receiving analysis results** in JSON format
3. **Displaying color information** in the UI

Example Flutter integration:

```dart
Future<Map<String, dynamic>> analyzeClothing(String imageBase64) async {
  final response = await http.post(
    Uri.parse('http://localhost:5000/detect-clothing'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'image_base64': imageBase64}),
  );
  
  return jsonDecode(response.body);
}
```

## 📝 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📞 Support

For issues and questions:
- Check the troubleshooting section
- Review the test suite
- Open an issue on GitHub 