import 'package:flutter/material.dart';
import 'package:master_mind/models/discount_coupon_model.dart';
import 'package:master_mind/screens/discount_coupon/widgets/coupon_card.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/base_screen.dart';
import 'package:master_mind/screens/discount_coupon/widgets/qr_code_dialog.dart';

class CouponDetailScreen extends BaseScreenWithAppBar {
  final DiscountCoupon coupon;

  const CouponDetailScreen({
    super.key,
    required this.coupon,
  }) : super(title: 'Coupon Details');

  @override
  State<CouponDetailScreen> createState() => _CouponDetailScreenState();
}

class _CouponDetailScreenState
    extends BaseScreenWithAppBarState<CouponDetailScreen> {
  @override
  Widget buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple Coupon Card
          CouponCard(
            coupon: widget.coupon,
            onTap: () {}, // Empty callback since we're already in detail view
          ),
          const SizedBox(height: 20),

          // Simple Details
          _buildSimpleDetails(),
          const SizedBox(height: 20),

          // QR Code Button
          _buildQRButton(),
        ],
      ),
    );
  }

  Widget _buildSimpleCouponCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Restaurant Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.coupon.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.restaurant, size: 40),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Restaurant Name
          Text(
            widget.coupon.restaurantName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Discount
          Text(
            widget.coupon.discountText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.coupon.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSimpleDetailItem('Coupon ID', widget.coupon.id),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSimpleDetailItem(
                    'Created', widget.coupon.formattedCreatedDate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showQRCode(),
        icon: const Icon(Icons.qr_code, size: 20),
        label: const Text('Show QR Code'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => QRCodeDialog(
        coupon: widget.coupon,
      ),
    );
  }
}
