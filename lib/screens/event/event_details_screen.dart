import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/models/event_model.dart';
import 'package:master_mind/utils/const.dart';
// Removed unused import
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/platform_button.dart';
import 'package:master_mind/widgets/home_drawer.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/event_provider.dart';
import 'package:intl/intl.dart';
// Removed unused import
import 'package:master_mind/widgets/shimmer_avatar.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _loadingAction = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<EventProvider>(context, listen: false)
          .loadEventDetails(widget.eventId);
      setState(() {});
    });
  }

  Future<void> _handleRSVP(Event event, bool isRegistered) async {
    final provider = Provider.of<EventProvider>(context, listen: false);
    bool success;

    if (isRegistered) {
      print('Cancelling registration for event: ${event.id}');
      success = await provider.cancelRegisterForEvent(event.id);
    } else {
      print('Registering for event: ${event.id}');
      success = await provider.patchRegisterForEvent(event.id);
    }

    if (success) {
      // Refresh the event details to get updated registration status
      await provider.loadEventDetails(event.id);
      setState(() {});

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isRegistered
                ? 'Registration cancelled successfully!'
                : 'Successfully registered for event!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ??
                (isRegistered
                    ? 'Failed to cancel registration'
                    : 'Failed to register for event')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final event = provider.eventDetails;

    // Show success message if available
    if (provider.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.successMessage!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        provider.clearSuccessMessage();
      });
    }

    // Show loading state
    if (provider.isLoadingEventDetails || event == null) {
      return PlatformWidget.scaffold(
        context: context,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Events',
            style:
                TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon:
                const Icon(CupertinoIcons.back, color: kPrimaryColor, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(const Color(0xFF4B204B)),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading event details...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error state
    if (provider.error != null) {
      return PlatformWidget.scaffold(
        context: context,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Events',
            style:
                TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon:
                const Icon(CupertinoIcons.back, color: kPrimaryColor, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Load failed',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.error!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  provider.loadEventDetails(widget.eventId);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B204B),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isRegistered = event.registered;
    final dateStr = DateFormat('d MMM yyyy, h:mm a').format(event.date);

    // Check if the event is in the past
    final now = DateTime.now();
    final isPastEvent = event.date.isBefore(now);

    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Events',
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B204B)),
            ),
            const SizedBox(height: 12),
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Color(0xFF4B204B), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Date',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
                const SizedBox(width: 10),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.people, color: Color(0xFF4B204B), size: 20),
                const SizedBox(width: 8),
                Text('Attendees',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(width: 10),
                ...event.attendees.take(4).map((a) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: ShimmerAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        imageUrl:
                            'https://randomuser.me/api/portraits/men/${a.hashCode % 100}.jpg',
                      ),
                    )),
                if (event.attendees.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '+${event.attendees.length - 4}',
                      style: const TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(width: 6),
                Text('${event.attendees.length}+'),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.location_on,
                    color: Color(0xFF4B204B), size: 20),
                const SizedBox(width: 8),
                Text('Location',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('About this Event',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              event.description,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPastEvent
                    ? null
                    : () async {
                        final String title = event.title;
                        final String description = event.description;
                        final String location = event.location ?? '';
                        final String startTime =
                            '${event.startTime.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';
                        final String endTime =
                            '${event.endTime.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';

                        final String url =
                            'https://www.google.com/calendar/render?action=TEMPLATE'
                            '&text=${Uri.encodeComponent(title)}'
                            '&details=${Uri.encodeComponent(description)}'
                            '&location=${Uri.encodeComponent(location)}'
                            '&dates=$startTime/$endTime';

                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isPastEvent ? Colors.grey : const Color(0xFF4B204B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                    isPastEvent ? 'Event has passed' : 'Add to My Calender',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: (provider.isLoadingRSVP || isPastEvent)
                    ? null
                    : () => _handleRSVP(event, isRegistered),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isPastEvent ? Colors.grey : const Color(0xFF4B204B),
                  side: BorderSide(
                      color:
                          isPastEvent ? Colors.grey : const Color(0xFF4B204B)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: provider.isLoadingRSVP
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isPastEvent
                            ? 'Event has passed'
                            : (isRegistered ? 'Cancel RSVP' : 'RSVP'),
                        style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
