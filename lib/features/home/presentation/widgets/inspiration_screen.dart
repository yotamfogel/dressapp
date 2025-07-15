import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/widgets/settings_button.dart';
import '../providers/saved_fits_provider.dart';

class InspirationScreen extends ConsumerWidget {
  const InspirationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search bar and settings
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Search bar
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for inspiration...',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Settings button
                  const SettingsButton(),
                ],
              ),
            ),
            
            // Inspiration content
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: 10, // Show 10 sets of 4-photo frames
                itemBuilder: (context, index) {
                  return _buildPhotoFrame(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoFrame(BuildContext context, int index) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final frameWidth = (size.width - 48) / 2; // 2 columns with padding
    final fitId = 'fit_$index';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column (2 photos with dynamic heights)
          Expanded(
            child: Column(
              children: [
                _buildPhotoTile(
                  context,
                  frameWidth,
                  _getDynamicHeight(index * 4 + 1),
                  'assets/images/inspiration_${index * 4 + 1}.jpg',
                  index * 4 + 1,
                ),
                const SizedBox(height: 8),
                _buildPhotoTile(
                  context,
                  frameWidth,
                  _getDynamicHeight(index * 4 + 2),
                  'assets/images/inspiration_${index * 4 + 2}.jpg',
                  index * 4 + 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right column (2 photos with dynamic heights)
          Expanded(
            child: Column(
              children: [
                _buildPhotoTile(
                  context,
                  frameWidth,
                  _getDynamicHeight(index * 4 + 3),
                  'assets/images/inspiration_${index * 4 + 3}.jpg',
                  index * 4 + 3,
                ),
                const SizedBox(height: 8),
                _buildPhotoTile(
                  context,
                  frameWidth,
                  _getDynamicHeight(index * 4 + 4),
                  'assets/images/inspiration_${index * 4 + 4}.jpg',
                  index * 4 + 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getDynamicHeight(int photoIndex) {
    // Create different aspect ratios for variety
    final aspectRatios = [1.0, 1.2, 1.5, 0.8, 1.3, 1.1, 0.9, 1.4];
    final baseHeight = 120.0; // Base height in pixels
    final ratio = aspectRatios[photoIndex % aspectRatios.length];
    return baseHeight * ratio;
  }

  Widget _buildPhotoTile(
    BuildContext context,
    double width,
    double height,
    String imagePath,
    int photoIndex,
  ) {
    final theme = Theme.of(context);
    final fitId = 'photo_$photoIndex';
    
    return Consumer(
      builder: (context, ref, child) {
        final savedFitsState = ref.watch(savedFitsProvider);
        final isSaved = savedFitsState.isFitSaved(fitId);
        
        return GestureDetector(
          onTap: () {
            // TODO: Navigate to photo detail or save to favorites
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Photo $photoIndex - Coming Soon!')),
            );
          },
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getGradientColor(photoIndex, 0),
                  _getGradientColor(photoIndex, 1),
                  _getGradientColor(photoIndex, 2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Placeholder for actual image
                Center(
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                // Save button overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (isSaved) {
                          ref.read(savedFitsProvider.notifier).removeFit(fitId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Removed from saved fits')),
                          );
                        } else {
                          final newFit = SavedFit(
                            id: fitId,
                            title: 'Photo $photoIndex',
                            description: 'A beautiful photo for inspiration',
                            imageUrls: [imagePath],
                            savedAt: DateTime.now(),
                            tags: {
                              'style': 'inspiration',
                              'category': 'photo',
                            },
                          );
                          ref.read(savedFitsProvider.notifier).saveFit(newFit);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved to fits!')),
                          );
                        }
                      },
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isSaved 
                            ? theme.colorScheme.error 
                            : theme.colorScheme.primary,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getGradientColor(int photoIndex, int colorIndex) {
    final colors = [
      [Colors.purple, Colors.pink, Colors.orange],
      [Colors.blue, Colors.cyan, Colors.teal],
      [Colors.green, Colors.lime, Colors.yellow],
      [Colors.red, Colors.orange, Colors.pink],
      [Colors.indigo, Colors.purple, Colors.pink],
      [Colors.teal, Colors.cyan, Colors.blue],
      [Colors.amber, Colors.orange, Colors.red],
      [Colors.pink, Colors.purple, Colors.indigo],
    ];
    
    return colors[photoIndex % colors.length][colorIndex % 3];
  }
} 