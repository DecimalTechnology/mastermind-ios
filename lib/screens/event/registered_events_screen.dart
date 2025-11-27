import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/models/event_model.dart';
import 'package:master_mind/providers/event_provider.dart';
import 'package:master_mind/providers/auth_provider.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/screens/event/event_details_screen.dart';
import 'package:master_mind/utils/const.dart';
import 'package:provider/provider.dart';

class RegisteredEventsScreen extends StatefulWidget {
  const RegisteredEventsScreen({super.key});

  @override
  State<RegisteredEventsScreen> createState() => _RegisteredEventsScreenState();
}

class _RegisteredEventsScreenState extends State<RegisteredEventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _cancelledEventIds = {}; // Track locally cancelled events

  @override
  void initState() {
    super.initState();

    _loadRegisteredEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRegisteredEvents() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? userId = authProvider.user?.id;

    try {
      // Clear any existing errors first
      eventProvider.clearMessages();

      // Clear the events list to ensure fresh data
      eventProvider.clearEventsList();

      await eventProvider.loadEvents(
        sort: 'chapter',
        filter: 'rsvp',
        chapterId: null,
        regionId: null,
        localId: null,
        nationId: null,
        userId: userId,
        date: null, // Do not filter by date
      );

      print('Loaded registered events: ${eventProvider.events.length}');
      for (var e in eventProvider.events) {
        print('Event: ${e.name}, registered: ${e.registered}');
      }
    } catch (e) {
      print('Error loading registered events: $e');
    }
  }

  List<Event> _getFilteredEvents(List<Event> events) {
    // First filter to only show events where user is actually registered
    List<Event> registeredEvents =
        events.where((event) => event.registered == true).toList();

    // Then filter out locally cancelled events
    registeredEvents = registeredEvents
        .where((event) => !_cancelledEventIds.contains(event.id))
        .toList();

    // Then apply search filter if needed
    if (_searchQuery.isEmpty) return registeredEvents;

    return registeredEvents
        .where((event) =>
            event.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            event.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: kPrimaryColor, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Registered Events",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Consumer<EventProvider>(
          builder: (context, eventProvider, child) {
            // Show success message if available
            if (eventProvider.successMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(eventProvider.successMessage!),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
                eventProvider.clearSuccessMessage();
              });
            }

            final filteredEvents = _getFilteredEvents(eventProvider.events);
            print('UI events count: ${eventProvider.events.length}');
            print('Filtered registered events count: ${filteredEvents.length}');
            print(
                'Events with registered=true: ${eventProvider.events.where((e) => e.registered == true).length}');

            // Debug: Print all events and their registration status
            for (int i = 0; i < eventProvider.events.length; i++) {
              final event = eventProvider.events[i];
              print(
                  'Event $i: ${event.name} (ID: ${event.id}) - registered: ${event.registered}');
            }

            // Show loading state for initial load
            if (eventProvider.isLoading && eventProvider.events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading registered events...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show error state
            if (eventProvider.error != null && eventProvider.events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load registered events',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eventProvider.error!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadRegisteredEvents,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Show loading indicator at top if events are being refreshed
                if (eventProvider.isLoading && eventProvider.events.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(kPrimaryColor),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Refreshing events...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search registered events...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                // Events list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadRegisteredEvents,
                    child: filteredEvents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No registered events found'
                                      : 'No events match your search',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredEvents.length,
                            itemBuilder: (context, index) {
                              final event = filteredEvents[index];
                              return _buildEventCard(event, eventProvider);
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, EventProvider eventProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(eventId: event.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Event image
              if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    event.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.event, color: kPrimaryColor),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.event, color: kPrimaryColor),
                ),
              const SizedBox(width: 16),
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name.isNotEmpty ? event.name : 'Untitled Event',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (event.description.isNotEmpty)
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: kPrimaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '${event.date.day}/${event.date.month}/${event.date.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: kPrimaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Cancel Registration button
              ElevatedButton(
                onPressed: eventProvider.isLoadingRSVP
                    ? null
                    : () async {
                        // Show immediate feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cancelling registration...'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 1),
                          ),
                        );

                        final success = await eventProvider
                            .cancelRegisterForEvent(event.id);
                        if (success) {
                          // Add to locally cancelled events set
                          setState(() {
                            _cancelledEventIds.add(event.id);
                          });

                          // Immediately remove the event from the UI for instant feedback
                          eventProvider.removeEventFromList(event.id);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Registration cancelled successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }

                          // Also refresh from server to ensure consistency
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                          await _loadRegisteredEvents();
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(eventProvider.error ??
                                    'Failed to cancel registration'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: eventProvider.isLoadingRSVP
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 12),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
