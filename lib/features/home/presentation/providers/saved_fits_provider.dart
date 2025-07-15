import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/app_providers.dart';

class SavedFit {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final DateTime savedAt;
  final Map<String, String> tags;

  const SavedFit({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.savedAt,
    this.tags = const {},
  });

  SavedFit copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? imageUrls,
    DateTime? savedAt,
    Map<String, String>? tags,
  }) {
    return SavedFit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      savedAt: savedAt ?? this.savedAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'savedAt': savedAt.toIso8601String(),
      'tags': tags,
    };
  }

  factory SavedFit.fromJson(Map<String, dynamic> json) {
    return SavedFit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      savedAt: DateTime.parse(json['savedAt'] as String),
      tags: Map<String, String>.from(json['tags'] as Map),
    );
  }
}

class SavedFitsState {
  final List<SavedFit> savedFits;
  final bool isLoading;
  final String? error;

  const SavedFitsState({
    this.savedFits = const [],
    this.isLoading = false,
    this.error,
  });

  SavedFitsState copyWith({
    List<SavedFit>? savedFits,
    bool? isLoading,
    String? error,
  }) {
    return SavedFitsState(
      savedFits: savedFits ?? this.savedFits,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool isFitSaved(String fitId) {
    return savedFits.any((fit) => fit.id == fitId);
  }
}

class SavedFitsNotifier extends StateNotifier<SavedFitsState> {
  final SharedPreferences _prefs;
  static const String _savedFitsKey = 'saved_fits';

  SavedFitsNotifier(this._prefs) : super(const SavedFitsState()) {
    _loadSavedFits();
  }

  Future<void> _loadSavedFits() async {
    state = state.copyWith(isLoading: true);

    try {
      final savedFitsJson = _prefs.getString(_savedFitsKey);
      if (savedFitsJson != null) {
        final List<dynamic> savedFitsList = jsonDecode(savedFitsJson);
        final savedFits = savedFitsList
            .map((json) => SavedFit.fromJson(json as Map<String, dynamic>))
            .toList();
        
        state = state.copyWith(
          savedFits: savedFits,
          isLoading: false,
        );
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

  Future<void> _saveFits() async {
    final savedFitsJson = jsonEncode(
      state.savedFits.map((fit) => fit.toJson()).toList(),
    );
    await _prefs.setString(_savedFitsKey, savedFitsJson);
  }

  Future<void> saveFit(SavedFit fit) async {
    try {
      final updatedFits = [...state.savedFits, fit];
      state = state.copyWith(savedFits: updatedFits);
      await _saveFits();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFit(String fitId) async {
    try {
      final updatedFits = state.savedFits.where((fit) => fit.id != fitId).toList();
      state = state.copyWith(savedFits: updatedFits);
      await _saveFits();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final savedFitsProvider = StateNotifierProvider<SavedFitsNotifier, SavedFitsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SavedFitsNotifier(prefs);
}); 