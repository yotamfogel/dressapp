import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_provider.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentPage,
    @Default(false) bool isLastPage,
    @Default(false) bool showAuthOptions,
  }) = _OnboardingState;
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void updatePage(int page) {
    state = state.copyWith(
      currentPage: page,
      isLastPage: page == 2, // Third page (index 2) is the last page
      showAuthOptions: page == 2, // Show auth options on the third page
    );
  }

  void nextPage() {
    if (state.currentPage < 2) {
      updatePage(state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      updatePage(state.currentPage - 1);
    }
  }

  void reset() {
    state = const OnboardingState();
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);

// Onboarding content data
class OnboardingContent {
  final String title;
  final String description;
  final String imagePath;
  final String? lottieAsset;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.imagePath,
    this.lottieAsset,
  });
}

final onboardingContentProvider = Provider<List<OnboardingContent>>((ref) {
  return [
    const OnboardingContent(
      title: 'Digital Wardrobe Management',
      description: 'Organize your clothing collection digitally and keep track of all your favorite pieces in one place.',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    const OnboardingContent(
      title: 'Smart Outfit Planning',
      description: 'Plan your outfits ahead of time and never worry about what to wear again.',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    const OnboardingContent(
      title: 'Personal Style Tracker',
      description: 'Track your style preferences and discover new ways to wear your existing clothes.',
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];
});
