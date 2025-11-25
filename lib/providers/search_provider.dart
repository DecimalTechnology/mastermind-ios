// providers/search_provider.dart
import 'package:flutter/material.dart';
import 'package:master_mind/models/search_model.dart';
import 'package:master_mind/repository/Search_repository/search_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider with ChangeNotifier {
  final SearchRepository _repository;
  List<SearchResult> _results = [];
  String _query = '';
  bool _isLoading = false;
  String? _error;
  List<String> _recentSearches = [];
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 5;

  SearchProvider(this._repository) {
    _loadRecentSearches();
  }

  List<SearchResult> get results => _results;
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get recentSearches => _recentSearches;

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
      notifyListeners();
    } catch (e) {
      _error = 'Load failed';
      notifyListeners();
    }
  }

  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, _recentSearches);
    } catch (e) {
      _error = 'Failed to save recent searches: ${e.toString()}';
      notifyListeners();
    }
  }

  void _addToRecentSearches(String search) {
    _recentSearches.remove(search); // Remove if exists
    _recentSearches.insert(0, search); // Add to beginning
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
    }
    _saveRecentSearches();
    notifyListeners();
  }

  Future<void> search(String query, String type, int page, String? location,
      String? company) async {
    if (query.trim().isEmpty) return;

    _query = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _repository.search(query, type, page, location, company);
      _addToRecentSearches(query);
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearResults() async {
    _results = [];
    _query = '';
    _error = null;
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches = [];
    _saveRecentSearches();
    notifyListeners();
  }
}
