import 'package:flutter/material.dart';
import 'package:master_mind/models/tip_model.dart';
import 'package:master_mind/repository/tip_repository.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';

class TipProvider extends ChangeNotifier {
  final TipRepository _repository;

  List<Tip> _tips = [];
  Tip? _selectedTip;
  bool _isLoading = false;
  bool _isLoadingLike = false;
  String? _error;
  String? _currentUserId;

  TipProvider({required TipRepository repository}) : _repository = repository;

  List<Tip> get tips => _tips;
  Tip? get selectedTip => _selectedTip;
  bool get isLoading => _isLoading;
  bool get isLoadingLike => _isLoadingLike;
  String? get error => _error;
  bool get hasError => _error != null;
  String? get currentUserId => _currentUserId;

  Future<List<Tip>> loadAllTips() async {
    if (_isLoading) return _tips;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _repository.getAllTips();
      _tips = data;
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<Tip?> loadTipById(String tipId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _repository.getTipById(tipId);
      _selectedTip = data;
      // If already present in list, update it
      final idx = _tips.indexWhere((t) => t.id == data.id);
      if (idx != -1) {
        _tips[idx] = data;
      }
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> likeTip(String tipId) async {
    if (_isLoadingLike) return false;

    // Get current tip state
    final tipIndex = _tips.indexWhere((tip) => tip.id == tipId);
    if (tipIndex == -1) return false;

    final currentTip = _tips[tipIndex];
    final isCurrentlyLiked = currentTip.likes.contains('current_user');
    final isCurrentlyDisliked = currentTip.dislikes.contains('current_user');

    // Optimistic update
    _isLoadingLike = true;
    _updateTipOptimistically(
        tipId, isCurrentlyLiked, isCurrentlyDisliked, true);
    notifyListeners();

    try {
      final resp = await _repository.likeTip(tipId);
      _applyReactionsFromServer(tipId, resp.data);
      _isLoadingLike = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      // Revert optimistic update on error
      _revertTipOptimistically(tipId, isCurrentlyLiked, isCurrentlyDisliked);
      _isLoadingLike = false;
      _error = ErrorHandler.getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> dislikeTip(String tipId) async {
    if (_isLoadingLike) return false;

    // Get current tip state
    final tipIndex = _tips.indexWhere((tip) => tip.id == tipId);
    if (tipIndex == -1) return false;

    final currentTip = _tips[tipIndex];
    final isCurrentlyLiked = currentTip.likes.contains('current_user');
    final isCurrentlyDisliked = currentTip.dislikes.contains('current_user');

    // Optimistic update
    _isLoadingLike = true;
    _updateTipOptimistically(
        tipId, isCurrentlyLiked, isCurrentlyDisliked, false);
    notifyListeners();

    try {
      final resp = await _repository.dislikeTip(tipId);
      _applyReactionsFromServer(tipId, resp.data);
      _isLoadingLike = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      // Revert optimistic update on error
      _revertTipOptimistically(tipId, isCurrentlyLiked, isCurrentlyDisliked);
      _isLoadingLike = false;
      _error = ErrorHandler.getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  void _updateTipOptimistically(
      String tipId, bool wasLiked, bool wasDisliked, bool isLikeAction) {
    final tipIndex = _tips.indexWhere((tip) => tip.id == tipId);
    if (tipIndex == -1) return;

    final tip = _tips[tipIndex];
    List<String> newLikes = List.from(tip.likes);
    List<String> newDislikes = List.from(tip.dislikes);
    final userId = _getCurrentUserId();

    if (isLikeAction) {
      // Like action
      if (wasLiked) {
        // Remove like
        newLikes.remove(userId);
      } else {
        // Add like and remove dislike if exists
        if (!newLikes.contains(userId)) {
          newLikes.add(userId);
        }
        newDislikes.remove(userId);
      }
    } else {
      // Dislike action
      if (wasDisliked) {
        // Remove dislike
        newDislikes.remove(userId);
      } else {
        // Add dislike and remove like if exists
        if (!newDislikes.contains(userId)) {
          newDislikes.add(userId);
        }
        newLikes.remove(userId);
      }
    }

    _updateTipInList(tipIndex, newLikes, newDislikes);
    _updateSelectedTip(tipId, newLikes, newDislikes);
  }

  void _revertTipOptimistically(String tipId, bool wasLiked, bool wasDisliked) {
    final tipIndex = _tips.indexWhere((tip) => tip.id == tipId);
    if (tipIndex == -1) return;

    final tip = _tips[tipIndex];
    List<String> newLikes = List.from(tip.likes);
    List<String> newDislikes = List.from(tip.dislikes);
    final userId = _getCurrentUserId();

    // Revert to original state
    if (wasLiked && !newLikes.contains(userId)) {
      newLikes.add(userId);
    } else if (!wasLiked && newLikes.contains(userId)) {
      newLikes.remove(userId);
    }

    if (wasDisliked && !newDislikes.contains(userId)) {
      newDislikes.add(userId);
    } else if (!wasDisliked && newDislikes.contains(userId)) {
      newDislikes.remove(userId);
    }

    _updateTipInList(tipIndex, newLikes, newDislikes);
    _updateSelectedTip(tipId, newLikes, newDislikes);
  }

  void _updateTipInList(
      int tipIndex, List<String> likes, List<String> dislikes) {
    final tip = _tips[tipIndex];
    _tips[tipIndex] = Tip(
      id: tip.id,
      title: tip.title,
      userId: tip.userId,
      description: tip.description,
      images: tip.images,
      videos: tip.videos,
      isActive: tip.isActive,
      likes: likes,
      dislikes: dislikes,
      tags: tip.tags,
      createdAt: tip.createdAt,
      updatedAt: tip.updatedAt,
    );
  }

  void _updateSelectedTip(
      String tipId, List<String> likes, List<String> dislikes) {
    if (_selectedTip?.id == tipId) {
      final tip = _selectedTip!;
      _selectedTip = Tip(
        id: tip.id,
        title: tip.title,
        userId: tip.userId,
        description: tip.description,
        images: tip.images,
        videos: tip.videos,
        isActive: tip.isActive,
        likes: likes,
        dislikes: dislikes,
        tags: tip.tags,
        createdAt: tip.createdAt,
        updatedAt: tip.updatedAt,
      );
    }
  }

  void _applyReactionsFromServer(String tipId, Map<String, dynamic> data) {
    final likes =
        (data['likes'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    final dislikes =
        (data['dislikes'] as List?)?.map((e) => e.toString()).toList() ??
            const [];

    // Update in tips list
    final tipIndex = _tips.indexWhere((tip) => tip.id == tipId);
    if (tipIndex != -1) {
      _updateTipInList(tipIndex, likes, dislikes);
    }

    // Update selected tip
    _updateSelectedTip(tipId, likes, dislikes);
  }

  String _getCurrentUserId() {
    // For now, use a placeholder. In a real app, this would come from AuthProvider
    return _currentUserId ?? 'current_user';
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  void clearData() {
    _tips = [];
    _selectedTip = null;
    _error = null;
    _isLoading = false;
    _isLoadingLike = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
