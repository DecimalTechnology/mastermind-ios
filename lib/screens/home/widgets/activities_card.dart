import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/home_provider.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/common_styles.dart';

class ActivitiesCard extends StatelessWidget {
  const ActivitiesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final connectionsCount = homeProvider.connections;
        final weeklyMeetings = homeProvider.weeklyMeetings;
        final stats = _calculateWeeklyStats(weeklyMeetings);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: kPrimaryColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              CommonStyles.sectionHeader(
                title: "This Week's Activities",
                subtitle: "Track your weekly activities and meetings",
              ),
              const SizedBox(height: kPaddingMedium),
              _buildSlipRow("Weekly Meetings", "${stats.totalMeetings}",
                  Icons.meeting_room),
              _buildSlipRow("Upcoming Meetings", "${stats.upcomingMeetings}",
                  Icons.schedule),
              _buildSlipRow(
                  "Past Meetings", "${stats.pastMeetings}", Icons.history),
              _buildSlipRow("Connections", "$connectionsCount", Icons.people),
            ],
          ),
        );
      },
    );
  }

  WeeklyStats _calculateWeeklyStats(List<dynamic> weeklyMeetings) {
    final totalMeetings = weeklyMeetings.length;
    final upcomingMeetings = weeklyMeetings
        .where((meeting) => meeting.date.isAfter(DateTime.now()))
        .length;
    final pastMeetings = totalMeetings - upcomingMeetings;

    return WeeklyStats(
      totalMeetings: totalMeetings,
      upcomingMeetings: upcomingMeetings,
      pastMeetings: pastMeetings,
    );
  }

  Widget _buildSlipRow(String title, String count, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(
            horizontal: kPaddingMedium, vertical: kPaddingSmall),
        decoration: BoxDecoration(
          color: kLightGreyColor,
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: kPrimaryColor),
                const SizedBox(width: kPaddingMedium),
                Text(title, style: kBodyTextStyle),
              ],
            ),
            Text(
              count,
              style: kBodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for weekly statistics
class WeeklyStats {
  final int totalMeetings;
  final int upcomingMeetings;
  final int pastMeetings;

  WeeklyStats({
    required this.totalMeetings,
    required this.upcomingMeetings,
    required this.pastMeetings,
  });
}
