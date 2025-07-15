import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/models/auth_db_helper.dart';
import '../../../../core/providers/app_providers.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;
  final AuthDbHelper _authDbHelper;

  AuthNotifier(this._prefs, this._authDbHelper) : super(const AuthState());

  /// Initialize authentication state from stored data
  Future<void> initializeAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final storedEmail = _prefs.getString('user_email');
      final storedProvider = _prefs.getString('user_provider');
      
      if (storedEmail != null && storedProvider != null) {
        // Try to retrieve user from database
        final user = await _authDbHelper.getUserByEmailAndProvider(storedEmail, storedProvider);
        
        if (user != null) {
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
        } else {
          // User not found in database, clear stored data
          await _clearStoredAuthData();
          state = state.copyWith(isLoading: false);
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign in user and store authentication data
  Future<void> signIn(UserModel user) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Save user to database
      await _authDbHelper.upsertUser(user);
      
      // Store authentication data in SharedPreferences
      await _storeAuthData(user);
      
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign out user and clear stored data
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Clear stored authentication data
      await _clearStoredAuthData();
      
      // Reset authentication state
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Store authentication data in SharedPreferences
  Future<void> _storeAuthData(UserModel user) async {
    await _prefs.setString('user_email', user.email);
    await _prefs.setString('user_provider', user.provider);
    await _prefs.setBool('is_authenticated', true);
    
    // Store additional user data if available
    if (user.displayName != null) {
      await _prefs.setString('user_display_name', user.displayName!);
    }
    if (user.photoUrl != null) {
      await _prefs.setString('user_photo_url', user.photoUrl!);
    }
  }

  /// Clear stored authentication data
  Future<void> _clearStoredAuthData() async {
    await _prefs.remove('user_email');
    await _prefs.remove('user_provider');
    await _prefs.remove('is_authenticated');
    await _prefs.remove('user_display_name');
    await _prefs.remove('user_photo_url');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final authDbHelper = AuthDbHelper();
  return AuthNotifier(prefs, authDbHelper);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
}); 