import 'dart:io';
import 'package:flutter/material.dart';
import 'package:master_mind/utils/const.dart';

class ProfileHeader extends StatelessWidget {
  final dynamic profile;
  final File? image;
  final VoidCallback onImageTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.image,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onImageTap,
          child: Stack(
            children: [
              SizedBox(
                height: 140,
                child: CircleAvatar(
                  key: ValueKey(profile?.imageUrl ?? 'no-image'),
                  radius: 70,
                  backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
                  backgroundImage: (profile?.imageUrl != null &&
                          profile!.imageUrl!.isNotEmpty)
                      ? NetworkImage(profile.imageUrl!)
                      : null,
                  child: (image == null &&
                          (profile == null ||
                              profile.imageUrl == null ||
                              profile.imageUrl!.isEmpty))
                      ? Icon(Icons.camera_alt, size: 40, color: kPrimaryColor)
                      : null,
                ),
              ),
              // Add a camera icon overlay to indicate it's tappable
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          height: 160,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (profile?.name != null && (profile!.name?.isNotEmpty ?? false))
                Text(
                  profile!.name ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: kPrimaryColor,
                  ),
                ),
              if (profile?.company != null &&
                  (profile!.company?.isNotEmpty ?? false))
                Text(
                  profile!.company ?? '',
                  style: TextStyle(
                      fontSize: 14,
                      color: kPrimaryColor.withValues(alpha: 0.7)),
                ),
              const SizedBox(height: 10),
              if (profile?.region != null &&
                  (profile!.region?.isNotEmpty ?? false))
                Text(
                  "Region: ${profile!.region ?? ''}",
                  style: TextStyle(color: kPrimaryColor.withValues(alpha: 0.8)),
                ),
              const SizedBox(height: 10),
              if (profile?.memberSince != null &&
                  (profile!.memberSince?.isNotEmpty ?? false))
                Text(
                  "Member Since : ${profile!.memberSince ?? ''}",
                  style: TextStyle(color: kPrimaryColor.withValues(alpha: 0.8)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
