import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final int currentIndex;

  const HomeState({
    this.currentIndex = 1, // Start with Inspiration (index 1) as default
  });

  HomeState copyWith({
    int? currentIndex,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
); 