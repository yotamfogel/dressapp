import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared Preferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

// App State Provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier(ref);
});

class AppState {
  final bool isFirstLaunch;
  final bool isAuthenticated;
  final String? userId;
  final ThemeMode themeMode;

  const AppState({
    this.isFirstLaunch = true,
    this.isAuthenticated = false,
    this.userId,
    this.themeMode = ThemeMode.system,
  });

  AppState copyWith({
    bool? isFirstLaunch,
    bool? isAuthenticated,
    String? userId,
    ThemeMode? themeMode,
  }) {
    return AppState(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  final Ref ref;

  AppStateNotifier(this.ref) : super(const AppState());

  Future<void> initialize() async {
    final prefs = ref.read(sharedPreferencesProvider);
    
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    final userId = prefs.getString('userId');
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    
    state = state.copyWith(
      isFirstLaunch: isFirstLaunch,
      isAuthenticated: isAuthenticated,
      userId: userId,
      themeMode: ThemeMode.values[themeModeIndex],
    );
  }

  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('isFirstLaunch', false);
    
    state = state.copyWith(isFirstLaunch: false);
  }

  Future<void> setAuthenticated(String userId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('userId', userId);
    
    state = state.copyWith(
      isAuthenticated: true,
      userId: userId,
    );
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove('userId');
    
    state = state.copyWith(
      isAuthenticated: false,
      userId: null,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('themeMode', themeMode.index);
    
    state = state.copyWith(themeMode: themeMode);
  }
}
