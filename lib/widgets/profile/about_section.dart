import 'package:flutter/material.dart';
import 'package:master_mind/utils/const.dart';

class AboutSection extends StatelessWidget {
  final dynamic profile;

  const AboutSection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    if (profile?.about == null || profile!.about!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile?.name != null && (profile!.name?.isNotEmpty ?? false))
            Text(
              "About ${profile!.name ?? ''}",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: kPrimaryColor),
            ),
          const SizedBox(height: 10),
          Text(
            profile!.about ?? '',
            style: TextStyle(
                fontSize: 14, color: kPrimaryColor.withValues(alpha: 0.7)),
            textAlign: TextAlign.justify,
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
