import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:master_mind/repository/chat_repository/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;
  List<QueryDocumentSnapshot> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  Stream<QuerySnapshot>? _messageStream;
  bool _isInitialized = false;

  ChatProvider({required ChatRepository chatRepository})
      : _chatRepository = chatRepository {
    initializeChat();
  }

  List<QueryDocumentSnapshot> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isInitialized => _isInitialized;

  Future<void> initializeChat() async {
    if (_isLoading) return;

    try {
      _startLoading();
      _messageStream = _chatRepository.getMessages();
      _messageStream?.listen(
        (snapshot) {
          _messages = snapshot.docs;
          _isInitialized = true;
          _finishLoading();
        },
        onError: (error) {
          _handleError(error);
        },
      );
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> sendMessage(String text) async {
    if (_isLoading) return;

    try {
      _startLoading();
      await _chatRepository.sendMessage(text);
      _successMessage = 'Message sent successfully';
      _finishLoading();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    if (_isLoading) return;

    try {
      _startLoading();
      await _chatRepository.deleteMessage(messageId);
      _successMessage = 'Message deleted successfully';
      _finishLoading();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateMessage(String messageId, String newText) async {
    if (_isLoading) return;

    try {
      _startLoading();
      await _chatRepository.updateMessage(messageId, newText);
      _successMessage = 'Message updated successfully';
      _finishLoading();
    } catch (e) {
      _handleError(e);
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

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

  void _handleError(dynamic e) {
    _error = e is Exception ? e.toString() : 'An unexpected error occurred';
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _messages = [];
    _isLoading = false;
    _error = null;
    _successMessage = null;
    _messageStream = null;
    _isInitialized = false;
    super.dispose();
  }
}
