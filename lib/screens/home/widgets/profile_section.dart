import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/profile_provider.dart';
import 'package:master_mind/providers/home_provider.dart';
import 'package:master_mind/models/profile_model.dart';
import 'package:master_mind/screens/profile/profile_edit_screen.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/common_styles.dart';
import 'package:master_mind/widgets/base_screen.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, HomeProvider>(
      builder: (context, profileProvider, homeProvider, child) {
        final profile = profileProvider.profile;
        final userInfo = homeProvider.userInfo;

        final displayData = _getDisplayData(userInfo, profile);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: _buildCardDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfileAvatar(displayData.image),
              const SizedBox(width: kPaddingMedium),
              Expanded(
                child: _buildProfileInfo(displayData, profile, context),
              ),
            ],
          ),
        );
      },
    );
  }

  DisplayData _getDisplayData(dynamic userInfo, ProfileModel? profile) {
    return DisplayData(
      name: userInfo?.name.isNotEmpty == true
          ? userInfo!.name
          : profile?.name ?? "No name",
      image: userInfo?.image.isNotEmpty == true
          ? userInfo!.image
          : profile?.imageUrl,
      chapter: userInfo?.chapter.isNotEmpty == true
          ? userInfo!.chapter
          : profile?.chapter,
      region: userInfo?.region.isNotEmpty == true
          ? userInfo!.region
          : profile?.region,
      memberSince: userInfo?.memberSince.isNotEmpty == true
          ? userInfo!.memberSince
          : profile?.memberSince,
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 25,
          offset: const Offset(0, 10),
          spreadRadius: 2,
        ),
        BoxShadow(
          color: kPrimaryColor.withValues(alpha: 0.1),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(String? imageUrl) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(color: kPrimaryColor.withValues(alpha: 0.3), width: 3),
        boxShadow: [
          BoxShadow(
            color: kShadowColor,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: kLightGreyColor,
        backgroundImage:
            (imageUrl?.isNotEmpty ?? false) ? NetworkImage(imageUrl!) : null,
        child: (imageUrl == null || imageUrl.isEmpty)
            ? const Icon(Icons.person, size: 50, color: kGreyTextColor)
            : null,
      ),
    );
  }

  Widget _buildProfileInfo(
      DisplayData displayData, ProfileModel? profile, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayData.name, style: kSubheadingTextStyle),
        const SizedBox(height: 4),
        _buildSimpleProfileIndicator(profile, context),
        if (displayData.chapter?.isNotEmpty ?? false) ...[
          const SizedBox(height: kPaddingSmall),
          _buildInfoRow(Icons.location_on, displayData.chapter!),
        ],
        if (displayData.region?.isNotEmpty ?? false) ...[
          const SizedBox(height: kPaddingSmall),
          _buildInfoRow(Icons.public, displayData.region!),
        ],
        if (displayData.memberSince?.isNotEmpty ?? false) ...[
          const SizedBox(height: kPaddingSmall),
          _buildInfoRow(
              Icons.calendar_today, "Member since ${displayData.memberSince}"),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: kCaptionTextStyle),
      ],
    );
  }

  Widget _buildSimpleProfileIndicator(
      ProfileModel? profile, BuildContext context) {
    if (profile == null) return const SizedBox.shrink();

    final hasBasicInfo = profile.name.isNotEmpty && profile.company.isNotEmpty;
    final hasImage = profile.imageUrl != null && profile.imageUrl!.isNotEmpty;
    final hasContactInfo =
        (profile.email != null && profile.email!.isNotEmpty) ||
            (profile.phonenumbers.isNotEmpty);

    if (hasBasicInfo && hasImage && hasContactInfo) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        // Navigate to profile edit screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileEditScreen(),
          ),
        );
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: kPaddingSmall, vertical: 4),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: kPrimaryColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 14, color: kPrimaryColor),
            const SizedBox(width: 4),
            Text(
              'Complete your profile',
              style: kCaptionTextStyle.copyWith(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for profile data
class DisplayData {
  final String name;
  final String? image;
  final String? chapter;
  final String? region;
  final String? memberSince;

  DisplayData({
    required this.name,
    this.image,
    this.chapter,
    this.region,
    this.memberSince,
  });
}
