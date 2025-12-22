import 'package:flutter/material.dart';
import 'package:master_mind/models/accountability_slip.dart';
import 'package:master_mind/utils/const.dart';
import 'package:intl/intl.dart';

class AccountabilitySlipCard extends StatelessWidget {
  final AccountabilitySlip slip;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AccountabilitySlipCard({
    Key? key,
    required this.slip,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    // Removed unused variable

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Icon and Status
                Row(
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kPrimaryColor,
                            kAccentPurple,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Title and Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accountability Slip',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: kTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(slip.date),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Builder(
                      builder: (context) {
                        final now = DateTime.now();

                        // Convert UTC date to local time first, then extract components
                        final localDate = slip.date.toLocal();

                        // Create meeting DateTime in local timezone
                        final meetingDateTime = DateTime(
                          localDate.year,
                          localDate.month,
                          localDate.day,
                          localDate.hour,
                          localDate.minute,
                        );
                        final isPast = meetingDateTime.isBefore(now);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isPast
                                ? Colors.grey.withValues(alpha: 0.1)
                                : kSuccessColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPast
                                  ? Colors.grey.withValues(alpha: 0.3)
                                  : kSuccessColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            isPast ? 'Completed' : 'Active',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isPast ? Colors.grey : kSuccessColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Location and Time Row
                Row(
                  children: [
                    // Location
                    Expanded(
                      child: _buildInfoRow(
                        context,
                        icon: Icons.location_on,
                        label: 'Location',
                        value: slip.place,
                        color: kAccentPurple,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Time
                    Expanded(
                      child: _buildInfoRow(
                        context,
                        icon: Icons.access_time,
                        label: 'Time',
                        value: DateFormat.jm().format(slip.date.toLocal()),
                        color: kBlue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Members Section
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Participants',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${slip.members.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Members List (show first 3)
                if (slip.members.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: slip.members.take(3).map((member) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kLightGreyColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member.name ?? 'Unknown',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: kTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (slip.members.length > 3) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+${slip.members.length - 3} more',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final now = DateTime.now();

                          // Convert UTC date to local time first, then extract components
                          final localDate = slip.date.toLocal();

                          // Create meeting DateTime in local timezone
                          final meetingDateTime = DateTime(
                            localDate.year,
                            localDate.month,
                            localDate.day,
                            localDate.hour,
                            localDate.minute,
                          );
                          final isPast = meetingDateTime.isBefore(now);

                          return OutlinedButton.icon(
                            onPressed: isPast ? null : onEdit,
                            icon: Icon(Icons.edit,
                                size: 18,
                                color: isPast ? Colors.grey : kPrimaryColor),
                            label: Text('Edit',
                                style: TextStyle(
                                    color:
                                        isPast ? Colors.grey : kPrimaryColor)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  isPast ? Colors.grey : kPrimaryColor,
                              side: BorderSide(
                                  color: isPast
                                      ? Colors.grey.withValues(alpha: 0.3)
                                      : kPrimaryColor.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: kRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: onDelete,
                          icon: Icon(
                            Icons.delete_outline,
                            color: kRed,
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: kTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
