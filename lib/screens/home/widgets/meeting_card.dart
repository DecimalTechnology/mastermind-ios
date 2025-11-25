import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/home_provider.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/common_styles.dart';

class MeetingCard extends StatelessWidget {
  const MeetingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final nextMeeting = homeProvider.nextMeeting;
        final meetingInfo = _getMeetingInfo(nextMeeting);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: kPaddingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimaryColor, kGradientEndColor],
            ),
            borderRadius: BorderRadius.circular(kBorderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(kPaddingLarge),
            child: Column(
              children: [
                Text("NEXT MEETING",
                    style: kButtonTextStyle.copyWith(fontSize: 14)),
                const SizedBox(height: kPaddingMedium),
                Text(
                  meetingInfo.formattedDate,
                  style: kButtonTextStyle.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                if (nextMeeting != null) ...[
                  const SizedBox(height: kPaddingLarge),
                  _buildMeetingLocation(nextMeeting.place),
                  const SizedBox(height: kPaddingMedium),
                  Text("Time: ${meetingInfo.formattedTime}",
                      style: kButtonTextStyle.copyWith(fontSize: 14)),
                ],
                const SizedBox(height: kPaddingLarge),
                const SizedBox(height: kPaddingMedium),
                _buildMeetingStats(nextMeeting, meetingInfo.formattedTime),
              ],
            ),
          ),
        );
      },
    );
  }

  MeetingInfo _getMeetingInfo(dynamic nextMeeting) {
    if (nextMeeting == null) {
      return MeetingInfo(
        formattedDate: "No upcoming meetings",
        formattedTime: "TBD",
      );
    }

    final date = nextMeeting.date;
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final formattedDate =
        "${dayNames[date.weekday - 1]}, ${monthNames[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";

    // Extract time from the date field and format it
    final formattedTime = _formatTimeFromDate(date);

    return MeetingInfo(
        formattedDate: formattedDate, formattedTime: formattedTime);
  }

  String _formatTimeFromDate(DateTime date) {
    // Convert to local time
    final localDate = date.toLocal();

    final hour = localDate.hour;
    final minute = localDate.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildMeetingLocation(String place) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: kPaddingMedium, vertical: kPaddingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Text(
        "Meeting: $place",
        style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildMeetingStats(dynamic nextMeeting, String formattedTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Members", style: kButtonTextStyle),
        Text(nextMeeting?.members.length.toString() ?? "0",
            style: kButtonTextStyle),
        Text("Time", style: kButtonTextStyle),
        Text(formattedTime, style: kButtonTextStyle),
      ],
    );
  }
}

// Helper class for meeting data
class MeetingInfo {
  final String formattedDate;
  final String formattedTime;

  MeetingInfo({
    required this.formattedDate,
    required this.formattedTime,
  });
}
