import 'package:flutter/material.dart';
import '../models/accountability_slip.dart';
import '../repository/accountability_repository.dart';

class AccountabilityProvider extends ChangeNotifier {
  final AccountabilityRepository _repo = AccountabilityRepository();

  List<AccountabilitySlip> _slips = [];
  bool _isLoading = false;
  String? _error;

  List<AccountabilitySlip> get slips => _slips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createSlip(
      {required String token, required AccountabilitySlip slip}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.createSlip(token: token, slip: slip);
      await fetchSlips(token: token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSlips({required String token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _slips = await _repo.getSlips(token: token);
    } catch (e) {
      _error = _slips.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSlip(
      {required String token, required String slipId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.deleteSlip(token: token, slipId: slipId);
      await fetchSlips(token: token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editSlip({
    required String token,
    required String slipId,
    required AccountabilitySlip slip,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.editSlip(token: token, slipId: slipId, slip: slip);
      await fetchSlips(token: token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
