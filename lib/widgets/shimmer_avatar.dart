import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final Widget? child;
  final Color? backgroundColor;
  final Color? shimmerColor;
  final bool isLoading;

  const ShimmerAvatar({
    super.key,
    this.radius = 30,
    this.imageUrl,
    this.child,
    this.backgroundColor,
    this.shimmerColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || imageUrl == null || imageUrl!.isEmpty) {
      return _buildShimmerAvatar();
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade300,
      backgroundImage: NetworkImage(imageUrl!),
      child: child,
    );
  }

  Widget _buildShimmerAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: child ??
            Icon(
              Icons.person,
              size: radius * 0.6,
              color: Colors.grey.shade400,
            ),
      ),
    );
  }
}

class ShimmerAvatarWithFallback extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final Widget? fallbackChild;
  final Color? backgroundColor;
  final bool isLoading;

  const ShimmerAvatarWithFallback({
    super.key,
    this.radius = 30,
    this.imageUrl,
    this.fallbackChild,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildShimmerAvatar();
    }

    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey.shade300,
        child: fallbackChild ??
            Icon(
              Icons.person,
              size: radius * 0.6,
              color: Colors.grey.shade600,
            ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade300,
      backgroundImage: NetworkImage(imageUrl!),
      onBackgroundImageError: (exception, stackTrace) {
        // Handle image loading error
      },
      child: fallbackChild,
    );
  }

  Widget _buildShimmerAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person,
          size: radius * 0.6,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
