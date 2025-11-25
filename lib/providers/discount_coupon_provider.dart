import 'package:flutter/material.dart';
import 'package:master_mind/models/discount_coupon_model.dart';
import 'package:master_mind/repository/discount_coupon_repository.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';

class DiscountCouponProvider extends ChangeNotifier {
  final DiscountCouponRepository repository;

  DiscountCouponProvider({required this.repository});

  List<DiscountCoupon> _coupons = [];
  bool _isLoading = false;
  String? _error;
  DiscountCoupon? _selectedCoupon;

  // Getters
  List<DiscountCoupon> get coupons => _coupons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DiscountCoupon? get selectedCoupon => _selectedCoupon;

  // Get active coupons only
  List<DiscountCoupon> get activeCoupons =>
      _coupons.where((coupon) => coupon.isActive).toList();

  // Get coupons by restaurant
  List<DiscountCoupon> getCouponsByRestaurant(String restaurantName) {
    return _coupons
        .where((coupon) => coupon.restaurantName
            .toLowerCase()
            .contains(restaurantName.toLowerCase()))
        .toList();
  }

  // Load all discount coupons
  Future<void> loadDiscountCoupons() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await repository.getDiscountCoupons();
      _coupons = response.data;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      ErrorHandler.logError(e, StackTrace.current,
          context: 'DiscountCouponProvider.loadDiscountCoupons');
    } finally {
      _setLoading(false);
    }
  }

  // Load specific coupon details
  Future<void> loadCouponDetails(String couponId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedCoupon = await repository.getDiscountCouponById(couponId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      ErrorHandler.logError(e, StackTrace.current,
          context: 'DiscountCouponProvider.loadCouponDetails');
    } finally {
      _setLoading(false);
    }
  }

  // Use a discount coupon
  Future<bool> useCoupon(String couponId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await repository.useDiscountCoupon(couponId);
      if (success) {
        // Update the coupon status locally
        final index = _coupons.indexWhere((coupon) => coupon.id == couponId);
        if (index != -1) {
          // You might want to refresh the coupon data or mark it as used
          await loadDiscountCoupons(); // Refresh the list
        }
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      ErrorHandler.logError(e, StackTrace.current,
          context: 'DiscountCouponProvider.useCoupon');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search coupons
  List<DiscountCoupon> searchCoupons(String query) {
    if (query.isEmpty) return _coupons;

    return _coupons
        .where((coupon) =>
            coupon.restaurantName.toLowerCase().contains(query.toLowerCase()) ||
            coupon.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Filter coupons by discount percentage
  List<DiscountCoupon> filterCouponsByDiscount(int minDiscount) {
    return _coupons
        .where((coupon) => coupon.discountPercentage >= minDiscount)
        .toList();
  }

  // Clear selected coupon
  void clearSelectedCoupon() {
    _selectedCoupon = null;
    notifyListeners();
  }

  // Refresh coupons
  Future<void> refreshCoupons() async {
    await loadDiscountCoupons();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Dispose method
  @override
  void dispose() {
    super.dispose();
  }
}
