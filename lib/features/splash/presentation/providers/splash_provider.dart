import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'splash_provider.freezed.dart';

@freezed
class SplashState with _$SplashState {
  const factory SplashState({
    @Default(false) bool isLoading,
    @Default(false) bool isInitialized,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _SplashState;
}

class SplashNotifier extends StateNotifier<SplashState> {
  final Ref _ref;
  
  SplashNotifier(this._ref) : super(const SplashState());

  Future<void> initializeApp() async {
    state = state.copyWith(isLoading: true, hasError: false);

    try {
      // Initialize core services
      await _initializeServices();
      
      // Check authentication status
      await _checkAuthenticationStatus();
      
      // Load user preferences
      await _loadUserPreferences();
      
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _initializeServices() async {
    // Simulate service initialization
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: Initialize actual services
    // - Firebase
    // - Secure storage
    // - Network client
    // - Analytics
    // - Crash reporting
  }

  Future<void> _checkAuthenticationStatus() async {
    // Initialize authentication state from stored data
    await _ref.read(authProvider.notifier).initializeAuth();
    
    // Wait a bit for the auth state to be properly set
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _loadUserPreferences() async {
    // Simulate loading preferences
    await Future.delayed(const Duration(milliseconds: 200));
    
    // TODO: Load user preferences
    // - Theme settings
    // - Language preferences
    // - Notification settings
    // - App settings
  }

  void retry() {
    initializeApp();
  }
}

final splashProvider = StateNotifierProvider<SplashNotifier, SplashState>(
  (ref) => SplashNotifier(ref),
);
