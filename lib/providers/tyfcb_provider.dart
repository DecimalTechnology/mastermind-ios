import 'package:flutter/material.dart';
import '../repository/tyfcb_repository.dart';
import '../models/tyfcb_model.dart';
import '../repository/Auth_repository.dart';

class TYFCBProvider extends ChangeNotifier {
  final TYFCBRepository repository;
  final AuthRepository _authRepository = AuthRepository();
  bool isLoading = false;
  String? error;
  bool success = false;

  // For Activity Feed
  List<TYFCBModel> receivedTYFCBs = [];
  List<TYFCBModel> sentTYFCBs = [];
  bool isReceivedLoading = false;
  bool isSentLoading = false;

  double? totalTYFCBAmount;
  bool isTotalAmountLoading = false;

  TYFCBProvider({required this.repository});

  Future<void> submitTYFCB(TYFCBModel model) async {
    isLoading = true;
    error = null;
    success = false;
    notifyListeners();
    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        error = 'No auth token found';
        success = false;
        isLoading = false;
        notifyListeners();
        return;
      }
      final result = await repository.submitTYFCB(model, token);
      success = result;
    } catch (e) {
      error = e.toString();
      success = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReceivedTYFCBs() async {
    isReceivedLoading = true;
    notifyListeners();
    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        error = 'No auth token found';
        isReceivedLoading = false;
        notifyListeners();
        return;
      }
      receivedTYFCBs = await repository.getReceivedTYFCBs(token);
    } catch (e) {
      error = e.toString();
    } finally {
      isReceivedLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSentTYFCBs() async {
    isSentLoading = true;
    notifyListeners();
    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        error = 'No auth token found';
        isSentLoading = false;
        notifyListeners();
        return;
      }
      sentTYFCBs = await repository.getSentTYFCBs(token);
    } catch (e) {
      error = e.toString();
    } finally {
      isSentLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTotalTYFCBAmount() async {
    isTotalAmountLoading = true;
    notifyListeners();
    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        error = 'No auth token found';
        isTotalAmountLoading = false;
        notifyListeners();
        return;
      }
      totalTYFCBAmount = await repository.fetchTotalTYFCBAmount(token);
    } catch (e) {
      error = e.toString();
      totalTYFCBAmount = 0.0;
    } finally {
      isTotalAmountLoading = false;
      notifyListeners();
    }
  }
}
