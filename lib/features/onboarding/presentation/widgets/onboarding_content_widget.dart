import 'package:flutter/material.dart';
import '../providers/onboarding_provider.dart';

class OnboardingContentWidget extends StatelessWidget {
  final OnboardingContent content;
  final bool isLastPage;

  const OnboardingContentWidget({
    super.key,
    required this.content,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration/Image placeholder
          Container(
            width: size.width * 0.7,
            height: size.height * 0.35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                  theme.colorScheme.tertiary.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: _buildIllustration(context),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            content.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            content.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (isLastPage) ...[
            const SizedBox(height: 24),
            Text(
              'Ready to transform your style?',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final theme = Theme.of(context);
    
    // Create different illustrations for each page
    switch (content.title) {
      case 'Digital Wardrobe Management':
        return _buildWardrobeIllustration(theme);
      case 'Smart Outfit Planning':
        return _buildOutfitIllustration(theme);
      case 'Personal Style Tracker':
        return _buildStyleIllustration(theme);
      default:
        return _buildDefaultIllustration(theme);
    }
  }

  Widget _buildWardrobeIllustration(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Wardrobe representation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 40,
                  height: 60,
                  decoration: BoxDecoration(
                    color: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                      theme.colorScheme.tertiary,
                    ][index],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    [Icons.checkroom, Icons.local_mall, Icons.style][index],
                    color: Colors.white,
                    size: 24,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),
          Icon(
            Icons.inventory_2,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitIllustration(ThemeData theme) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outfit planning representation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.secondary,
                  theme.colorScheme.tertiary,
                ],
              ),
            ),
          ),
          // Outfit icon
          Icon(
            Icons.style,
            size: 60,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStyleIllustration(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Style tracking representation
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.trending_up,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            Icons.person,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIllustration(ThemeData theme) {
    return Icon(
      Icons.checkroom,
      size: 80,
      color: theme.colorScheme.primary,
    );
  }
}
