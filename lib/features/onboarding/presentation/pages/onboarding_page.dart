import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_content_widget.dart';
import '../widgets/onboarding_indicators.dart';
import '../widgets/auth_options_widget.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    ref.read(onboardingProvider.notifier).updatePage(page);
  }

  void _nextPage() {
    if (_pageController.page! < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToAuth() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingContent = ref.watch(onboardingContentProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top buttons row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side - empty for balance
                  const SizedBox(width: 80),
                  
                  // Center - Skip button (only on first two pages)
                  if (!onboardingState.isLastPage)
                    TextButton(
                      onPressed: _skipToAuth,
                      child: Text(
                        'Skip',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  
                  // Right side - Settings button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // TODO: Navigate to settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings - Coming Soon!')),
                        );
                      },
                      icon: Icon(
                        Icons.settings,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: onboardingContent.length,
                itemBuilder: (context, index) {
                  if (index == 2) {
                    // Last page - show auth options directly
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          OnboardingContentWidget(
                            content: onboardingContent[index],
                            isLastPage: true,
                          ),
                          const SizedBox(height: 24),
                          const AuthOptionsWidget(),
                        ],
                      ),
                    );
                  } else {
                    // First two pages - show content only
                    return SingleChildScrollView(
                      child: OnboardingContentWidget(
                        content: onboardingContent[index],
                        isLastPage: false,
                      ),
                    );
                  }
                },
              ),
            ),

            // Bottom section with indicators only
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: OnboardingIndicators(
                currentPage: onboardingState.currentPage,
                totalPages: onboardingContent.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
