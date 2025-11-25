import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/models/event_model.dart';
import 'package:master_mind/providers/event_provider.dart';
// Removed unused import
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/screens/event/event_details_screen.dart';
import 'package:master_mind/screens/settings_screen.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/home_drawer.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  // State variables
  String? _selectedRegion;
  String? _selectedChapter;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  final List<String> _sortOptions = ['chapter', 'region', 'local', 'national'];
  final Map<String, String> _sortOptionLabels = {
    'chapter': 'Chapter',
    'region': 'Region',
    'local': 'Local',
    'national': 'National',
  };
  String _selectedSort = 'chapter';
  final List<String> _filterTabs = ['all', 'rsvp', 'upcoming'];
  int _selectedFilterIndex = 0;
  int _selectedTabIndex =
      0; // 0 for All Events, 1 for Registered, 2 for Upcoming
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate;
  int _selectedYear = DateTime.now().year;
  int _selectedMonthNum = DateTime.now().month;
  final List<int> _years = List.generate(11, (i) => 2020 + i);
  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final ScrollController _dateScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _selectedDate =
        DateTime(_selectedMonth.year, _selectedMonth.month, DateTime.now().day);

    // Use a longer delay to ensure proper initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDate();
      // Add a small delay before loading data to ensure provider is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        _loadInitialData();
      });
    });
  }

  void _scrollToCurrentDate() {
    final datesInMonth = _getDatesInMonth(_selectedMonth);
    final index = datesInMonth.indexWhere((date) =>
        date.year == _selectedDate?.year &&
        date.month == _selectedDate?.month &&
        date.day == _selectedDate?.day);
    if (index != -1 && _dateScrollController.hasClients) {
      _dateScrollController.animateTo(
        (index * 68).toDouble(),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // --- Data Loading ---
  Future<void> _loadInitialData() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // Clear any existing errors
      eventProvider.clearMessages();

      // Load regions first
      await eventProvider.loadRegions();

      // Wait for regions to be fully loaded
      while (eventProvider.isLoadingRegions) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Check if regions loaded successfully
      if (eventProvider.error != null) {
        // Continue anyway, regions might not be critical
      }

      // Add a delay to ensure regions are fully processed
      await Future.delayed(const Duration(milliseconds: 500));

      // Then load events
      await _loadEvents();

      // Reset retry count on success
      _retryCount = 0;
    } catch (e) {
      // Increment retry count
      _retryCount++;

      if (_retryCount < _maxRetries) {
        // If initial load fails, try again after a delay
        await Future.delayed(const Duration(seconds: 2));
        await _loadEvents();
      }
    }
  }

  Future<void> _loadEvents() async {
    // Convert selected date to UTC for API
    DateTime? utcDate;
    if (_selectedDate != null) {
      utcDate = _selectedDate!.toUtc();
    } else {
      utcDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1).toUtc();
    }

    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    String sort = _selectedSort;
    String filter = _filterTabs[_selectedFilterIndex];

    // Don't use date filtering for registered events tab or upcoming events tab
    String? date;
    if (_selectedTabIndex != 1 && _selectedTabIndex != 2) {
      date = utcDate.toIso8601String();
    }

    try {
      // Clear any previous errors before loading
      eventProvider.clearMessages();

      await eventProvider.loadEvents(
        sort: sort,
        filter: filter,
        chapterId: _selectedChapter,
        regionId: _selectedRegion,
        localId: null,
        nationId: null,
        userId: null,
        date: date,
      );

      // Reset retry count on successful load
      _retryCount = 0;
    } catch (e) {
      // Don't re-throw the error, let the provider handle it
    }
  }

  // --- UI Helpers ---
  List<DateTime> _getDatesInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final daysInMonth = nextMonth.difference(firstDay).inDays;
    return List.generate(
        daysInMonth, (i) => DateTime(month.year, month.month, i + 1));
  }

  Future<void> _showMonthYearPicker(BuildContext context) async {
    int selectedYear = _selectedMonth.year;
    int selectedMonth = _selectedMonth.month;
    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Month and Year'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: () {
                        if (selectedYear > 2000) {
                          selectedYear--;
                          (context as Element).markNeedsBuild();
                        }
                      },
                    ),
                    Text('$selectedYear', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: () {
                        if (selectedYear < 2100) {
                          selectedYear++;
                          (context as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(12, (index) {
                    return ChoiceChip(
                      label: Text([
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec'
                      ][index]),
                      selected: selectedMonth == index + 1,
                      onSelected: (_) {
                        selectedMonth = index + 1;
                        (context as Element).markNeedsBuild();
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context, DateTime(selectedYear, selectedMonth, 1));
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        _selectedMonth = result;
        _selectedDate = DateTime(result.year, result.month, 1);
      });
      _loadEvents();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToCurrentDate());
    }
  }

  // --- UI Actions ---
  Future<void> _onSortChanged(String? sort) async {
    if (sort != null) {
      setState(() {
        _selectedSort = sort;
      });
      await _loadEvents();
    }
  }

  Future<void> _onRegionChanged(String? region) async {
    setState(() {
      _selectedRegion = region;
      _selectedChapter = null; // Reset chapter when region changes
    });

    if (region != null) {
      // Load chapters for the selected region
      await Provider.of<EventProvider>(context, listen: false)
          .loadChapters(region);
    }

    // Load events with new region
    await _loadEvents();
  }

  Future<void> _onChapterChanged(String? chapter) async {
    setState(() {
      _selectedChapter = chapter;
    });
    await _loadEvents();
  }

  // Manual retry method that resets retry count
  Future<void> _retryLoadEvents() async {
    _retryCount = 0; // Reset retry count for manual retry
    await _loadEvents();
  }

  // Filter events based on selected tab
  List<Event> _getFilteredEvents(List<Event> events) {
    if (_selectedTabIndex == 1) {
      // Registered tab - show only events where user is registered
      final registeredEvents =
          events.where((event) => event.registered == true).toList();
      return registeredEvents;
    } else if (_selectedTabIndex == 2) {
      // Upcoming tab - show all future events (both registered and non-registered)
      final now = DateTime.now();
      final upcomingEvents =
          events.where((event) => event.date.isAfter(now)).toList();
      return upcomingEvents;
    } else {
      // All Events tab - show only current and future events for the selected date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // If viewing today's date, only show events that haven't ended yet
      if (_selectedDate != null) {
        final selectedDate = DateTime(
            _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
        final isToday = selectedDate.isAtSameMomentAs(today);

        if (isToday) {
          // For today, only show events that haven't ended yet
          final currentAndFutureEvents = events.where((event) {
            // Check if event is today and hasn't ended yet
            final eventDate =
                DateTime(event.date.year, event.date.month, event.date.day);
            final isEventToday = eventDate.isAtSameMomentAs(today);

            if (isEventToday) {
              // For today's events, check if they haven't ended yet
              final eventEndTime = event.endTime;
              return eventEndTime.isAfter(now);
            }
            return false; // Don't show events from other days in today's view
          }).toList();

          return currentAndFutureEvents;
        } else {
          // For other dates, show all events for that date
          final dateEvents = events.where((event) {
            final eventDate =
                DateTime(event.date.year, event.date.month, event.date.day);
            final selectedDate = DateTime(
                _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
            return eventDate.isAtSameMomentAs(selectedDate);
          }).toList();

          return dateEvents;
        }
      } else {
        // If no specific date is selected, show all future events
        final futureEvents =
            events.where((event) => event.date.isAfter(now)).toList();
        return futureEvents;
      }
    }
  }

  // --- Main Build ---
  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Events",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: kAppBarIconColor),
            onPressed: () {
              if (PlatformUtils.isIOS) {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => SettingsScreen()));
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()));
              }
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Container(
        color: Colors.white,
        child: Consumer<EventProvider>(
          builder: (context, eventProvider, child) {
            try {
              // Show loading state for initial load or events loading
              if (eventProvider.isLoading && eventProvider.events.isEmpty) {
                return PlatformWidget.scaffold(
                  context: context,
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(buttonColor),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading events...',
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
              if (eventProvider.error != null && eventProvider.events.isEmpty) {
                // Extract only the main reason (first sentence or after 'Exception: ')
                String reason = eventProvider.error!;
                if (reason.contains('Exception:')) {
                  reason = reason.split('Exception:').last.trim();
                }
                if (reason.contains('.')) {
                  reason = reason.split('.').first.trim();
                }
                // Show only the first 4 words
                List<String> words = reason.split(' ');
                String shortReason = words.take(4).join(' ');
                return PlatformWidget.scaffold(
                  context: context,
                  backgroundColor: Colors.white,
                  body: _buildErrorWidget(shortReason, _retryLoadEvents),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadEvents,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show loading indicator at top if events are being refreshed
                      if (eventProvider.isLoading &&
                          eventProvider.events.isNotEmpty)
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      buttonColor),
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

                      // Tab bar
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, left: 16, right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ...[
                              'All Events',
                              'Registered',
                              'Upcoming',
                            ].asMap().entries.map((entry) {
                              int idx = entry.key;
                              String label = entry.value;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTabIndex = idx;
                                    // Update filter based on tab selection
                                    _selectedFilterIndex = idx == 1
                                        ? 1
                                        : idx == 2
                                            ? 2
                                            : 0; // 1 for registered (rsvp), 2 for upcoming, 0 for all
                                  });
                                  _loadEvents();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: _selectedTabIndex == idx
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: _selectedTabIndex == idx
                                              ? buttonColor
                                              : Colors.grey,
                                        ),
                                      ),
                                      if (_selectedTabIndex == idx)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          height: 2,
                                          width: 40,
                                          color: buttonColor,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      // Show different content based on selected tab
                      if (_selectedTabIndex == 1) ...[
                        // Registered Events Tab - Simple list view
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Registered Events",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              // Simple list of registered events
                              ..._buildRegisteredEventsList(
                                  _getFilteredEvents(eventProvider.events)),
                            ],
                          ),
                        ),
                      ] else if (_selectedTabIndex == 2) ...[
                        // Upcoming Events Tab - Simple list view
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Upcoming Events",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              // Simple list of upcoming events
                              ..._buildUpcomingEventsList(
                                  _getFilteredEvents(eventProvider.events)),
                            ],
                          ),
                        ),
                      ] else ...[
                        // All Events Tab - Full calendar view
                        // Sort by dropdowns
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          child: Row(
                            children: [
                              const Text("Sort By:",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(width: 10),
                              // Sort dropdown
                              Container(
                                height: 36,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: _selectedSort != 'chapter'
                                      ? buttonColor.withValues(alpha: 0.1)
                                      : const Color(0xFFEDE7F6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: _selectedSort != 'chapter'
                                      ? Border.all(color: buttonColor, width: 1)
                                      : null,
                                ),
                                child: DropdownButton<String>(
                                  value: _selectedSort,
                                  hint: const Text("Sort"),
                                  underline: Container(),
                                  items: _sortOptions
                                      .map<DropdownMenuItem<String>>((option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(
                                          _sortOptionLabels[option] ?? option),
                                    );
                                  }).toList(),
                                  onChanged: _onSortChanged,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Year dropdown
                              Container(
                                height: 36,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE7F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<int>(
                                  value: _selectedYear,
                                  hint: const Text("Year"),
                                  underline: Container(),
                                  items:
                                      _years.map<DropdownMenuItem<int>>((year) {
                                    return DropdownMenuItem<int>(
                                      value: year,
                                      child: Text(year.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedYear = val;
                                        _selectedMonth = DateTime(_selectedYear,
                                            _selectedMonthNum, 1);
                                      });
                                      _loadEvents();
                                      WidgetsBinding.instance
                                          .addPostFrameCallback(
                                              (_) => _scrollToCurrentDate());
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Month dropdown
                              Container(
                                height: 36,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE7F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<int>(
                                  value: _selectedMonthNum,
                                  hint: const Text("Month"),
                                  underline: Container(),
                                  items: List.generate(12, (i) => i + 1)
                                      .map<DropdownMenuItem<int>>((monthNum) {
                                    return DropdownMenuItem<int>(
                                      value: monthNum,
                                      child: Text(_months[monthNum - 1]),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedMonthNum = val;
                                        _selectedMonth = DateTime(_selectedYear,
                                            _selectedMonthNum, 1);
                                      });
                                      _loadEvents();
                                      WidgetsBinding.instance
                                          .addPostFrameCallback(
                                              (_) => _scrollToCurrentDate());
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Chapter dropdown (separate row)
                        if (eventProvider.chapters.isNotEmpty ||
                            eventProvider.isLoadingChapters)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 16),
                            child: Row(
                              children: [
                                const Text("Chapter:",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(width: 10),
                                Container(
                                  height: 36,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE7F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: eventProvider.isLoadingChapters
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : DropdownButton<String>(
                                          value: _selectedChapter,
                                          hint: const Text("Select Chapter"),
                                          underline: Container(),
                                          items: eventProvider.chapters
                                              .map<DropdownMenuItem<String>>(
                                                  (chapter) {
                                            return DropdownMenuItem<String>(
                                              value: chapter,
                                              child: Text(chapter),
                                            );
                                          }).toList(),
                                          onChanged: _onChapterChanged,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        // Region dropdown (separate row)
                        if (eventProvider.regions.isNotEmpty ||
                            eventProvider.isLoadingRegions)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 16),
                            child: Row(
                              children: [
                                const Text("Region:",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(width: 10),
                                Container(
                                  height: 36,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE7F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: eventProvider.isLoadingRegions
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : DropdownButton<String>(
                                          value: _selectedRegion,
                                          hint: const Text("Select Region"),
                                          underline: Container(),
                                          items: eventProvider.regions
                                              .map<DropdownMenuItem<String>>(
                                                  (region) {
                                            return DropdownMenuItem<String>(
                                              value: region,
                                              child: Text(region),
                                            );
                                          }).toList(),
                                          onChanged: _onRegionChanged,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        // Date carousel
                        // Upcoming Business Events
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Upcoming Business Events",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        // Schedule Today
                        _buildModernDateCarousel(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Schedule on",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${_selectedDate != null ? _selectedDate!.day.toString().padLeft(2, '0') : ''} '
                                    '${_months[_selectedDate != null ? _selectedDate!.month - 1 : 0]}, '
                                    '${_selectedDate != null ? _selectedDate!.year : ''}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Time slots and event cards
                              ..._buildScheduleToday(
                                  _getFilteredEvents(eventProvider.events)),
                            ],
                          ),
                        ),
                        // Meeting Details section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Meeting Details",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Upcoming meetings and discussions",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54),
                              ),
                              const SizedBox(height: 10),
                              ..._buildMeetingDetails(eventProvider.meetings),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            } catch (e) {
              return _buildErrorWidget(
                'An unexpected error occurred. Please try again.',
                _retryLoadEvents,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    if (event.id.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(eventId: event.id),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening event details: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 70,
              child: Row(
                children: [
                  // Expanded: event title and description
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            event.title.isNotEmpty
                                ? event.title
                                : 'Untitled Event',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          if (event.description.isNotEmpty)
                            Text(
                              event.description,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Trailing: event image as avatar
                  if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(event.imageUrl!),
                        onBackgroundImageError: (exception, stackTrace) {},
                      ),
                    ),
                ],
              ),
            ),
            // Show cancel registration button for registered events in Registered tab
            if (_selectedTabIndex == 1 && event.registered)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Consumer<EventProvider>(
                  builder: (context, eventProvider, child) {
                    return ElevatedButton(
                      onPressed: eventProvider.isLoadingRSVP
                          ? null
                          : () async {
                              final success = await eventProvider
                                  .cancelRegisterForEvent(event.id);
                              if (success) {
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
                                // Refresh the events list
                                _loadEvents();
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
                              'Cancel Registration',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDateCarousel() {
    final datesInMonth = _getDatesInMonth(_selectedMonth);
    final today = DateTime.now();

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: datesInMonth.length,
        itemBuilder: (context, index) {
          final date = datesInMonth[index];
          final isSelected = _selectedDate != null &&
              date.year == _selectedDate!.year &&
              date.month == _selectedDate!.month &&
              date.day == _selectedDate!.day;
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            width: isSelected ? 60 : 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? buttonColor.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(18),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: buttonColor.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
              border: isToday
                  ? Border.all(
                      color: isSelected ? Colors.white : buttonColor,
                      width: 2,
                    )
                  : null,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
                _loadEvents();
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToCurrentDate());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: isSelected ? 22 : 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun'
                    ][date.weekday - 1],
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : buttonColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper to build schedule today (time slots and event cards)
  List<Widget> _buildScheduleToday(List<Event> events) {
    // Add null safety check
    if (events.isEmpty) {
      return [
        SizedBox(
          height: 50,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(
                  _selectedTabIndex == 1
                      ? Icons.event_busy
                      : _selectedTabIndex == 2
                          ? Icons.event_available
                          : Icons.event_note,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedTabIndex == 1
                      ? 'No registered events'
                      : _selectedTabIndex == 2
                          ? 'No upcoming events'
                          : 'No events',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_selectedTabIndex == 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    'You haven\'t registered for any events yet',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (_selectedTabIndex == 2) ...[
                  const SizedBox(height: 8),
                  Text(
                    'No future events scheduled',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ];
    }

    // For demo, just show two event cards at 8:00 and 14:00
    return events.map((event) {
      final startTime = event.startTime;
      final endTime = event.endTime;
      final timeLabel =
          '${startTime.hour.toString().padLeft(2, '0')}.${startTime.minute.toString().padLeft(2, '0')}';
      return _buildScheduleSlot(timeLabel, event);
    }).toList();
  }

  Widget _buildScheduleSlot(String time, Event? event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
                ),
                if (event != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Text(
                      '${event.endTime.hour.toString().padLeft(2, '0')}.${event.endTime.minute.toString().padLeft(2, '0')}',
                      style:
                          const TextStyle(fontSize: 18, color: Colors.blueGrey),
                    ),
                  ),
              ],
            ),
          ),
          if (event != null)
            Expanded(child: _buildEventCard(event))
          else
            Expanded(
              child: Container(
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'No events',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper to build meeting details section
  List<Widget> _buildMeetingDetails(List<Meeting> meetings) {
    if (meetings.isEmpty) {
      return [
        _buildMeetingCard("No meetings scheduled", "", "", ""),
      ];
    }

    // Sort meetings by date and take the first 3
    final sortedMeetings = List<Meeting>.from(meetings);
    sortedMeetings.sort((a, b) => a.date.compareTo(b.date));
    return sortedMeetings.take(3).map((meeting) {
      final date =
          '${meeting.date.day.toString().padLeft(2, '0')}/${meeting.date.month.toString().padLeft(2, '0')}/${meeting.date.year}';
      final time = meeting.time;
      final place = meeting.place;
      final members = meeting.members.length;
      return _buildMeetingCard("Meeting", date, time, place, members);
    }).toList();
  }

  Widget _buildMeetingCard(String title, String date, String time, String place,
      [int? memberCount]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4B204B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.meeting_room, color: Color(0xFF4B204B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 4),
                if (place.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$date at $time',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
                if (place.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '📍 $place',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
                if (memberCount != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '👥 $memberCount members',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a simple list of registered events
  List<Widget> _buildRegisteredEventsList(List<Event> registeredEvents) {
    if (registeredEvents.isEmpty) {
      return [
        SizedBox(
          height: 50,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No registered events',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_selectedTabIndex == 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    'You haven\'t registered for any events yet',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ];
    }

    return registeredEvents.map((event) {
      return _buildEventCard(event);
    }).toList();
  }

  // Helper to build a simple list of upcoming events
  List<Widget> _buildUpcomingEventsList(List<Event> upcomingEvents) {
    if (upcomingEvents.isEmpty) {
      return [
        SizedBox(
          height: 50,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No upcoming events',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No future events scheduled',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return upcomingEvents.map((event) {
      return _buildEventCard(event);
    }).toList();
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }
}
