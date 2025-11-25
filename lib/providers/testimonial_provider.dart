import 'package:flutter/material.dart';
import 'package:master_mind/repository/testimonial_repository/testimonial_repository.dart'; // Imports both TestimonialRepository and GivenTestimonial for consistency.
import 'package:master_mind/core/error_handling/exceptions/custom_exceptions.dart';

class TestimonialProvider extends ChangeNotifier {
  final TestimonialRepository _repository = TestimonialRepository();

  List<GivenTestimonial> _givenTestimonials = [];
  List<GivenTestimonial> _receivedTestimonials = [];
  List<GivenTestimonial> _requestedTestimonials = [];
  bool _isLoading = false;
  String? _error;

  Map<String, int> _testimonialCounts = {'received': 0, 'given': 0, 'asked': 0};
  Map<String, int> get testimonialCounts => _testimonialCounts;

  // Getters
  List<GivenTestimonial> get givenTestimonials => _givenTestimonials;
  List<GivenTestimonial> get receivedTestimonials => _receivedTestimonials;
  List<GivenTestimonial> get requestedTestimonials => _requestedTestimonials;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Give testimonial
  Future<bool> giveTestimonial(String userId, String message) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.giveTestimonial(userId, message);
      await loadGivenTestimonials();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      if (e is AppException) {
        _error = e.message;
      } else {
        _error = 'An unexpected error occurred';
      }
      notifyListeners();
      return false;
    }
  }

  // ask testimonial
  Future<bool> askTestimonial(String userId, String message) async {
    try {
      print('TestimonialProvider: Asking testimonial from user: $userId');
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _repository.requestTestimonial(userId, message);
      print('TestimonialProvider: Request testimonial result: $success');

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('TestimonialProvider: Error asking testimonial: $e');
      _isLoading = false;
      if (e is AppException) {
        _error = e.message;
      } else {
        _error = 'An unexpected error occurred';
      }
      notifyListeners();
      return false;
    }
  }

  // Load user's given testimonials
  Future<void> loadGivenTestimonials() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _givenTestimonials = await _repository.getGivenTestimonials();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (e is AppException) {
        _error = e.message;
      } else {
        _error = 'An unexpected error occurred';
      }
      notifyListeners();
    }
  }

  // Load user's received testimonials
  Future<void> loadReceivedTestimonials() async {
    try {
      print('TestimonialProvider: Loading received testimonials for user: ');
      _isLoading = true;
      _error = null;
      notifyListeners();

      _receivedTestimonials = await _repository.getReceivedTestimonials();
      print(
          'TestimonialProvider: Loaded ${_receivedTestimonials.length} received testimonials');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('TestimonialProvider: Error loading received testimonials: $e');
      _isLoading = false;
      if (e is AppException) {
        _error = e.message;
      } else {
        _error = 'An unexpected error occurred';
      }
      notifyListeners();
    }
  }

  // Load testimonials requested by the user
  Future<void> loadRequestedTestimonials() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _requestedTestimonials = await _repository.getRequestedTestimonials();
      print('Loaded requested testimonials: ${_requestedTestimonials.length}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (e is AppException) {
        _error = e.message;
      } else {
        _error = 'An unexpected error occurred';
      }
      notifyListeners();
    }
  }

  // Refresh all testimonials
  Future<void> refreshTestimonials(String userId) async {
    await Future.wait([
      loadGivenTestimonials(),
      loadReceivedTestimonials(),
      loadRequestedTestimonials(),
    ]);
  }

  // Clear all data
  void clearData() {
    _givenTestimonials.clear();
    _receivedTestimonials.clear();
    _requestedTestimonials.clear();
    _error = null;
    notifyListeners();
  }

  Future<void> fetchTestimonialCountsWithToken(
      Future<String?> Function() getToken) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final token = await getToken();
      if (token == null) {
        _error = 'No auth token found';
        _isLoading = false;
        notifyListeners();
        return;
      }
      final counts = await _repository.getTestimonialCountsWithToken(token);
      _testimonialCounts = counts;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (e is AppException) {
        _error = e.message;
      } else {
        _error = 'An unexpected error occurred';
      }
      notifyListeners();
    }
  }
}
