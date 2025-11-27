import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/screens/testimonial/testimonialDetails/given_testimonial.dart';
import 'package:master_mind/screens/testimonial/testimonialDetails/requested_testimonial.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/testimonial_provider.dart';
import 'package:master_mind/providers/Auth_provider.dart';
import 'package:master_mind/utils/const.dart';
// Removed unused import
import 'package:master_mind/screens/testimonial/testimonialDetails/received_testimonial.dart';

class TestimonialListingScreen extends StatefulWidget {
  const TestimonialListingScreen({super.key});

  @override
  State<TestimonialListingScreen> createState() =>
      _TestimonialListingScreenState();
}

class _TestimonialListingScreenState extends State<TestimonialListingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCounts();
    });
  }

  Future<void> _fetchCounts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final testimonialProvider =
        Provider.of<TestimonialProvider>(context, listen: false);
    final getToken = authProvider.authRepository.getAuthToken;
    await testimonialProvider.fetchTestimonialCountsWithToken(getToken);
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Colors.white;
    final Color iconColor = buttonColor;
    final Color textColor = buttonColor;
    final Color shadowColor = Colors.black12;
    final double borderRadius = 16;

    return PlatformWidget.scaffold(
      context: context,
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: kPrimaryColor, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Testimonials',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetchCounts,
            icon: const Icon(Icons.refresh, color: kPrimaryColor),
          ),
        ],
      ),
      body: Consumer<TestimonialProvider>(
        builder: (context, testimonialProvider, child) {
          if (testimonialProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (testimonialProvider.error != null) {
            // Show only the first 4 words of the error message
            String reason = testimonialProvider.error!;
            List<String> words = reason.split(' ');
            String shortReason = words.take(4).join(' ');
            return Center(child: Text('Error: $shortReason'));
          }
          final counts = testimonialProvider.testimonialCounts;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                _TestimonialCard(
                  icon: Icons.move_to_inbox_rounded,
                  label: 'Testimonials Received',
                  count: counts['received'] ?? 0,
                  iconColor: iconColor,
                  textColor: textColor,
                  cardColor: cardColor,
                  shadowColor: shadowColor,
                  borderRadius: borderRadius,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ReceivedTestimonialsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _TestimonialCard(
                  icon: Icons.outbox_rounded,
                  label: 'Testimonials Given',
                  count: counts['given'] ?? 0,
                  iconColor: iconColor,
                  textColor: textColor,
                  cardColor: cardColor,
                  shadowColor: shadowColor,
                  borderRadius: borderRadius,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GivenTestimonialsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _TestimonialCard(
                  icon: Icons.forum_rounded,
                  label: 'Testimonials Requests',
                  count: counts['asked'] ?? 0,
                  iconColor: iconColor,
                  textColor: textColor,
                  cardColor: cardColor,
                  shadowColor: shadowColor,
                  borderRadius: borderRadius,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestedTestimonialsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color iconColor;
  final Color textColor;
  final Color cardColor;
  final Color shadowColor;
  final double borderRadius;
  final VoidCallback onTap;

  const _TestimonialCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.iconColor,
    required this.textColor,
    required this.cardColor,
    required this.shadowColor,
    required this.borderRadius,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Text(
              '($count)',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: iconColor, size: 28),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return "Unknown date";
  final now = DateTime.now();
  final difference = now.difference(date);
  if (difference.inDays > 0) {
    return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
  } else if (difference.inHours > 0) {
    return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
  } else if (difference.inMinutes > 0) {
    return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
  } else {
    return "Just now";
  }
}

class _TestimonialRequestsPlaceholder extends StatelessWidget {
  const _TestimonialRequestsPlaceholder();
  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(title: const Text('Testimonial Requests')),
      body: const Center(
          child: Text('TODO: Testimonial Requests Page (not implemented yet)')),
    );
  }
}
