import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/discount_coupon_provider.dart';
import 'package:master_mind/models/discount_coupon_model.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/base_screen.dart';
import 'package:master_mind/screens/discount_coupon/coupon_detail_screen.dart';
import 'package:master_mind/screens/discount_coupon/widgets/coupon_card.dart';

class DiscountCouponScreen extends BaseScreenWithAppBar {
  const DiscountCouponScreen({super.key}) : super(title: 'Discount Coupons');

  @override
  State<DiscountCouponScreen> createState() => _DiscountCouponScreenState();
}

class _DiscountCouponScreenState
    extends BaseScreenWithAppBarState<DiscountCouponScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscountCouponProvider>().loadDiscountCoupons();
    });
  }

  @override
  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(CupertinoIcons.back, color: kPrimaryColor, size: 28),
      ),
      title: const Text(
        'Discount Coupons',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget buildContent() {
    return Consumer<DiscountCouponProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.coupons.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kOxygenMMPurple),
            ),
          );
        }

        if (provider.error != null && provider.coupons.isEmpty) {
          return _buildErrorState(provider);
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshCoupons(),
          color: kOxygenMMPurple,
          child: provider.coupons.isEmpty
              ? _buildEmptyState()
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.grey[50]!,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: provider.coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = provider.coupons[index];
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        curve: Curves.easeOutCubic,
                        child: CouponCard(
                          coupon: coupon,
                          onTap: () => _navigateToCouponDetail(coupon),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildErrorState(DiscountCouponProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load coupons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.loadDiscountCoupons(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kOxygenMMPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No coupons found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new offers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCouponDetail(DiscountCoupon coupon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CouponDetailScreen(coupon: coupon),
      ),
    );
  }
}
