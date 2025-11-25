import 'package:flutter/material.dart';
import 'package:master_mind/models/event_model.dart';
import 'package:master_mind/repository/event_repository.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';

class EventProvider extends ChangeNotifier {
  final EventRepository _repository;
  List<Event> _events = [];
  List<Meeting> _meetings = [];
  List<String> _regions = [];
  List<String> _chapters = [];
  bool _isLoading = false;
  bool _isLoadingRegions = false;
  bool _isLoadingChapters = false;
  bool _isLoadingEventDetails = false;
  bool _isLoadingRSVP = false;
  String? _error;
  String? _successMessage;
  Event? _eventDetails;
  DateTime? _selectedDate;

  EventProvider({required EventRepository repository})
      : _repository = repository;

  // Getters
  List<Event> get events => _events;
  List<Meeting> get meetings => _meetings;
  List<String> get regions => _regions;
  List<String> get chapters => _chapters;
  bool get isLoading => _isLoading;
  bool get isLoadingRegions => _isLoadingRegions;
  bool get isLoadingChapters => _isLoadingChapters;
  bool get isLoadingEventDetails => _isLoadingEventDetails;
  bool get isLoadingRSVP => _isLoadingRSVP;
  String? get error => _error;
  String? get successMessage => _successMessage;
  Event? get eventDetails => _eventDetails;
  DateTime? get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Clear all messages and errors
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // Clear only errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear only success messages
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  Future<void> loadEvents({
    String? sort,
    String? filter,
    String? chapterId,
    String? regionId,
    String? localId,
    String? nationId,
    String? userId,
    String? date,
  }) async {
    if (_isLoading) {
      return;
    }

    try {
      _startLoading();
      clearMessages();

      final result = await _repository.getEvents(
        sort: sort,
        filter: filter,
        chapterId: chapterId,
        regionId: regionId,
        localId: localId,
        nationId: nationId,
        userId: userId,
        date: date,
      );

      _events = result['events'] as List<Event>;
      _meetings = result['meetings'] as List<Meeting>;
      _finishLoading();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> loadRegions() async {
    if (_isLoadingRegions) {
      return;
    }

    try {
      _startLoadingRegions();
      clearMessages();

      _regions = await _repository.getRegions();
      _finishLoadingRegions();
    } catch (e) {
      _handleRegionsError(e);
    }
  }

  Future<void> loadChapters(String region) async {
    if (_isLoadingChapters) {
      return;
    }

    try {
      _startLoadingChapters();
      clearMessages();

      _chapters = await _repository.getChapters(region);
      _finishLoadingChapters();
    } catch (e) {
      _handleChaptersError(e);
    }
  }

  Future<bool> registerForEvent(String eventId) async {
    if (_isLoadingRSVP) return false;

    try {
      _startLoadingRSVP();
      clearMessages();

      final success = await _repository.registerForEvent(eventId);
      if (success) {
        _successMessage = 'Successfully registered for event';
        // Refresh events to update status
        await loadEvents();
      } else {
        _error = 'Failed to register for event. Please try again.';
      }
      _finishLoadingRSVP();
      return success;
    } catch (e) {
      _handleRSError(e);
      return false;
    }
  }

  Future<bool> setReminder(String eventId, bool setReminder) async {
    if (_isLoadingRSVP) return false;

    try {
      _startLoadingRSVP();
      clearMessages();

      final success = await _repository.setReminder(eventId, setReminder);
      if (success) {
        _successMessage = setReminder
            ? 'Reminder set successfully'
            : 'Reminder removed successfully';
        // Refresh events to update reminder status
        await loadEvents();
      } else {
        _error = setReminder
            ? 'Failed to set reminder. Please try again.'
            : 'Failed to remove reminder. Please try again.';
      }
      _finishLoadingRSVP();
      return success;
    } catch (e) {
      _handleRSError(e);
      return false;
    }
  }

  Future<bool> patchRegisterForEvent(String eventId) async {
    if (_isLoadingRSVP) return false;

    try {
      _startLoadingRSVP();
      clearMessages();

      final success = await _repository.patchRegisterForEvent(eventId);
      if (success) {
        _successMessage = 'Successfully registered for event';
        // Refresh event details to update registration status
        if (_eventDetails != null && _eventDetails!.id == eventId) {
          await loadEventDetails(eventId);
        }
        await loadEvents();
      } else {
        _error = 'Failed to register for event. Please try again.';
      }
      _finishLoadingRSVP();
      return success;
    } catch (e) {
      _handleRSError(e);
      return false;
    }
  }

  Future<bool> cancelRegisterForEvent(String eventId) async {
    if (_isLoadingRSVP) return false;

    try {
      _startLoadingRSVP();
      clearMessages();

      final success = await _repository.cancelRegisterForEvent(eventId);
      if (success) {
        _successMessage = 'Registration cancelled successfully';
        // Refresh event details to update registration status
        if (_eventDetails != null && _eventDetails!.id == eventId) {
          await loadEventDetails(eventId);
        }
        await loadEvents();
      } else {
        _error = 'Failed to cancel registration. Please try again.';
      }
      _finishLoadingRSVP();
      return success;
    } catch (e) {
      _handleRSError(e);
      return false;
    }
  }

  Future<void> loadEventDetails(String eventId) async {
    if (_isLoadingEventDetails) {
      return;
    }

    try {
      _startLoadingEventDetails();
      clearMessages();

      _eventDetails = await _repository.getEventDetails(eventId);
      _finishLoadingEventDetails();
    } catch (e) {
      _handleEventDetailsError(e);
    }
  }

  // Loading state management
  void _startLoading() {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  void _finishLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _startLoadingRegions() {
    _isLoadingRegions = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  void _finishLoadingRegions() {
    _isLoadingRegions = false;
    notifyListeners();
  }

  void _startLoadingChapters() {
    _isLoadingChapters = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  void _finishLoadingChapters() {
    _isLoadingChapters = false;
    notifyListeners();
  }

  void _startLoadingEventDetails() {
    _isLoadingEventDetails = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  void _finishLoadingEventDetails() {
    _isLoadingEventDetails = false;
    notifyListeners();
  }

  void _startLoadingRSVP() {
    _isLoadingRSVP = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  void _finishLoadingRSVP() {
    _isLoadingRSVP = false;
    notifyListeners();
  }

  // Manually remove an event from the local list (for immediate UI update)
  void removeEventFromList(String eventId) {
    _events.removeWhere((event) => event.id == eventId);
    notifyListeners();
  }

  // Clear the events list (for fresh data loading)
  void clearEventsList() {
    _events.clear();
    notifyListeners();
  }

  // Error handling
  void _handleError(dynamic e) {
    print('=== EVENT PROVIDER ERROR ===');
    print('Original error: $e');
    print('Error type: ${e.runtimeType}');
    print('Error message: ${ErrorHandler.getErrorMessage(e)}');
    print('===========================');
    _error = ErrorHandler.getErrorMessage(e);
    _isLoading = false;
    notifyListeners();
  }

  void _handleRegionsError(dynamic e) {
    print('=== REGIONS ERROR ===');
    print('Original error: $e');
    print('Error type: ${e.runtimeType}');
    print('Error message: ${ErrorHandler.getErrorMessage(e)}');
    print('=====================');
    _finishLoadingRegions();
    _error = ErrorHandler.getErrorMessage(e);
    notifyListeners();
  }

  void _handleChaptersError(dynamic e) {
    _finishLoadingChapters();
    _error = ErrorHandler.getErrorMessage(e);
    notifyListeners();
  }

  void _handleEventDetailsError(dynamic e) {
    _finishLoadingEventDetails();
    _error = ErrorHandler.getErrorMessage(e);
    notifyListeners();
  }

  void _handleRSError(dynamic e) {
    _finishLoadingRSVP();
    _error = ErrorHandler.getErrorMessage(e);
    notifyListeners();
  }
}
