import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:master_mind/models/discount_coupon_model.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';

class DiscountCouponRepository {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<String?> getAuthToken() async {
    return await storage.read(key: 'authToken');
  }

  Future<DiscountCouponResponse> getDiscountCoupons() async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw AuthenticationException('No authentication token found.');
      }

      final response = await http.get(
        Uri.parse('$baseurl/v1/discounts'),
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        try {
          return DiscountCouponResponse.fromJson(responseData);
        } catch (e) {
          throw ValidationException(
              'Invalid discount coupon data format: ${e.toString()}');
        }
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to load discount coupons');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to load discount coupons: ${e.toString()}');
    }
  }

  Future<DiscountCoupon> getDiscountCouponById(String couponId) async {
    try {
      // Get all discounts and find the specific one by ID
      final allCoupons = await getDiscountCoupons();
      final coupon = allCoupons.data.firstWhere(
        (coupon) => coupon.id == couponId,
        orElse: () => throw AppException('Coupon not found'),
      );
      return coupon;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException(
          'Failed to load discount coupon details: ${e.toString()}');
    }
  }

  Future<bool> useDiscountCoupon(String couponId) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw AuthenticationException('No authentication token found.');
      }

      final response = await http.post(
        Uri.parse('$baseurl/v1/discounts'),
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
        body: json.encode({'couponId': couponId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to use discount coupon');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to use discount coupon: ${e.toString()}');
    }
  }
}
