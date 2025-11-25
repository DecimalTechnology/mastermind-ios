class DiscountCoupon {
  final String id;
  final String restaurantName;
  final int discountPercentage;
  final String description;
  final bool isActive;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String qrCode;

  DiscountCoupon({
    required this.id,
    required this.restaurantName,
    required this.discountPercentage,
    required this.description,
    required this.isActive,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.qrCode,
  });

  factory DiscountCoupon.fromJson(Map<String, dynamic> json) {
    try {
      return DiscountCoupon(
        id: json['_id'] ?? '',
        restaurantName: json['restaurantName'] ?? '',
        discountPercentage: json['discountPercentage'] ?? 0,
        description: json['description'] ?? '',
        isActive: json['isActive'] ?? false,
        image: json['image'] ?? '',
        createdAt: DateTime.parse(
            json['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            json['updatedAt'] ?? DateTime.now().toIso8601String()),
        version: json['__v'] ?? 0,
        qrCode: json['QRCode'] ?? '',
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantName': restaurantName,
      'discountPercentage': discountPercentage,
      'description': description,
      'isActive': isActive,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      'QRCode': qrCode,
    };
  }

  // Helper getters
  String get discountText => '$discountPercentage% OFF';
  String get restaurantLogo => image;
  String get qrCodeUrl => qrCode;
  bool get isValid => isActive;

  // Format date for display
  String get formattedCreatedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class DiscountCouponResponse {
  final bool success;
  final List<DiscountCoupon> data;

  DiscountCouponResponse({
    required this.success,
    required this.data,
  });

  factory DiscountCouponResponse.fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic> dataList = json['data'] ?? [];
      final coupons =
          dataList.map((item) => DiscountCoupon.fromJson(item)).toList();

      return DiscountCouponResponse(
        success: json['success'] ?? false,
        data: coupons,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((coupon) => coupon.toJson()).toList(),
    };
  }
}
