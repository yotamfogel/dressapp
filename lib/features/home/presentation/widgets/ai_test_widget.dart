import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ai_clothing_service.dart';
import '../../../../core/services/ai_backend_manager.dart';

class AITestWidget extends StatefulWidget {
  const AITestWidget({super.key});

  @override
  State<AITestWidget> createState() => _AITestWidgetState();
}

class _AITestWidgetState extends State<AITestWidget> {
  bool _isLoading = false;
  bool _isBackendAvailable = false;
  String _result = '';
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _checkBackendAvailability();
  }

  Future<void> _checkBackendAvailability() async {
    setState(() => _isLoading = true);
    try {
      final isAvailable = await AIClothingService.isAvailable();
      setState(() {
        _isBackendAvailable = isAvailable;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isBackendAvailable = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = '';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);
    
    try {
      final analysis = await AIClothingService.analyzeClothing(_selectedImage!);
      
      if (analysis != null) {
        String resultText = 'Analysis Results:\n\n';
        
        if (analysis.clothingItems.isNotEmpty) {
          resultText += 'Detected Clothing:\n';
          for (final item in analysis.clothingItems) {
            resultText += '• ${item.label} (${(item.confidence * 100).toStringAsFixed(1)}%)\n';
          }
          resultText += '\n';
        }
        
        if (analysis.colorAnalysis != null) {
          resultText += 'Color Analysis:\n';
          resultText += analysis.colorAnalysis!.description;
        }
        
        setState(() {
          _result = resultText;
          _isLoading = false;
        });
      } else {
        setState(() {
          _result = 'Analysis failed. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Backend Test'),
        backgroundColor: const Color(0xFF461700),
        foregroundColor: const Color(0xFFFEFAD4),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkBackendAvailability,
            tooltip: 'Refresh Connection',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFEFAD4)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Backend Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isBackendAvailable ? Icons.check_circle : Icons.error,
                            color: _isBackendAvailable ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isBackendAvailable 
                                ? 'AI Backend Available' 
                                : 'AI Backend Unavailable',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mode: ${AIBackendManager.isLocalMode ? "Local Development" : "Production"}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'URL: ${AIBackendManager.getBackendUrl()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Image Selection
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF461700),
                  foregroundColor: const Color(0xFFFEFAD4),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Selected Image
              if (_selectedImage != null) ...[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF461700)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Analyze Button
                ElevatedButton.icon(
                  onPressed: _isBackendAvailable ? _analyzeImage : null,
                  icon: const Icon(Icons.psychology),
                  label: const Text('Analyze with AI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF461700),
                    foregroundColor: const Color(0xFFFEFAD4),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Loading Indicator
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF461700)),
                  ),
                ),
              
              // Results
              if (_result.isNotEmpty) ...[
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF461700)),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF461700),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 