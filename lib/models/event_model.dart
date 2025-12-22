import 'package:master_mind/models/accountability_slip.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String time;
  final String place;
  final String duration;
  final String? image;
  final String location;
  final String createdBy;
  final String audienceType;
  final List<String> attendees;
  final String eventType;
  final String chapterId;
  final String status;
  final Map<String, dynamic>? customFields;
  final List<dynamic> rsvp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool registered;
  final List<Meeting> meetings;
  AccountabilitySlip? accountabilitySlip;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.place,
    required this.duration,
    this.image,
    required this.location,
    required this.createdBy,
    required this.audienceType,
    required this.attendees,
    required this.eventType,
    required this.chapterId,
    required this.status,
    this.customFields,
    required this.rsvp,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.registered,
    required this.meetings,
    this.accountabilitySlip,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      final rawDate = json['date'];
      print(
          '🕐 Event.fromJson: Raw date field: "$rawDate" (type: ${rawDate.runtimeType})');

      DateTime parsedDate;
      if (rawDate == null) {
        parsedDate = DateTime.now();
        print('⚠️  Event.fromJson: date is null, using DateTime.now()');
      } else if (rawDate is String) {
        try {
          String dateStr = rawDate.trim();

          // If the string doesn't have timezone info (no 'Z' or timezone offset),
          // treat it as UTC (servers typically store dates in UTC)
          final hasTimezone = dateStr.endsWith('Z') ||
              RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(dateStr);

          if (!hasTimezone && dateStr.contains('T')) {
            // No timezone indicator - assume UTC and append 'Z'
            dateStr = '$dateStr Z';
            print('   → No timezone info, treating as UTC: "$dateStr"');
          }

          parsedDate = DateTime.parse(dateStr);
          // Ensure we have a UTC DateTime for consistency
          final utcParsed = parsedDate.isUtc ? parsedDate : parsedDate.toUtc();

          print('   → Parsed as: $utcParsed (isUtc: ${utcParsed.isUtc})');
          print(
              '   → UTC: ${utcParsed.toUtc()}, Local: ${utcParsed.toLocal()}');
          parsedDate = utcParsed;
        } catch (e) {
          print('❌ Event.fromJson: Error parsing date "$rawDate": $e');
          parsedDate = DateTime.now().toUtc();
        }
      } else {
        print(
            '⚠️  Event.fromJson: Unexpected date type ${rawDate.runtimeType}');
        parsedDate = DateTime.now();
      }

      final event = Event(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        date: parsedDate,
        time: json['time'] ?? '',
        place: json['place'] ?? '',
        duration: json['duration'] ?? '',
        image: json['image'],
        location: json['location'] ?? '',
        createdBy: json['createdBy'] ?? '',
        audienceType: json['audienceType'] ?? '',
        attendees: List<String>.from(json['attendees'] ?? []),
        eventType: json['eventType'] ?? '',
        chapterId: json['chapterId'] ?? '',
        status: json['status'] ?? '',
        customFields: json['customFields'],
        rsvp: json['rsvp'] ?? [],
        createdAt: Event._parseDateTimeSafely(
            json['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: Event._parseDateTimeSafely(
            json['updatedAt'] ?? DateTime.now().toIso8601String()),
        version: json['__v'] ?? 0,
        registered: json['registered'] ?? false,
        meetings: _parseMeetings(json['meetings']),
      );

      return event;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'place': place,
      'duration': duration,
      'image': image,
      'location': location,
      'createdBy': createdBy,
      'audienceType': audienceType,
      'attendees': attendees,
      'eventType': eventType,
      'chapterId': chapterId,
      'status': status,
      'customFields': customFields,
      'rsvp': rsvp,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      'registered': registered,
      'meetings': meetings.map((m) => m.toJson()).toList(),
    };
  }

  // Helper getters for backward compatibility
  String get title => name;
  DateTime get startTime => date;
  DateTime get endTime =>
      date.add(Duration(hours: int.tryParse(duration) ?? 2));
  String get region => place;
  String get chapter => chapterId;
  int get maxAttendees => 0; // Not provided in API
  int get currentAttendees => attendees.length;
  String? get imageUrl => image;
  bool get isReminderSet => false; // Not provided in API

  static List<Meeting> _parseMeetings(dynamic meetingsValue) {
    if (meetingsValue == null) return [];
    if (meetingsValue is List) {
      return meetingsValue
          .map((meetingJson) => Meeting.fromJson(meetingJson))
          .toList();
    }
    return [];
  }

  // Helper method to parse DateTime safely (for createdAt, updatedAt)
  static DateTime _parseDateTimeSafely(dynamic dateValue) {
    if (dateValue == null) return DateTime.now().toUtc();
    if (dateValue is DateTime)
      return dateValue.isUtc ? dateValue : dateValue.toUtc();
    if (dateValue is String) {
      try {
        String dateStr = dateValue.trim();
        final hasTimezone = dateStr.endsWith('Z') ||
            RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(dateStr);
        if (!hasTimezone && dateStr.contains('T')) {
          dateStr = '$dateStr Z';
        }
        final parsed = DateTime.parse(dateStr);
        return parsed.isUtc ? parsed : parsed.toUtc();
      } catch (e) {
        return DateTime.now().toUtc();
      }
    }
    return DateTime.now().toUtc();
  }
}

class Meeting {
  final String id;
  final String place;
  final DateTime date;
  final String time;
  final String userId;
  final List<String> members;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Meeting({
    required this.id,
    required this.place,
    required this.date,
    required this.time,
    required this.userId,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    try {
      return Meeting(
        id: json['_id']?.toString() ?? '',
        place: json['place']?.toString() ?? '',
        date: _parseDateTime(json['date']),
        time: json['time']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        members: _parseMembers(json['members']),
        createdAt: _parseDateTime(
            json['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: _parseDateTime(
            json['updatedAt'] ?? DateTime.now().toIso8601String()),
        version: json['__v'] is int ? json['__v'] : 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      print(
          '⚠️  Meeting._parseDateTime: dateValue is null, using DateTime.now()');
      return DateTime.now().toUtc();
    }
    if (dateValue is DateTime) {
      print(
          '⚠️  Meeting._parseDateTime: dateValue is already DateTime: $dateValue');
      return dateValue.isUtc ? dateValue : dateValue.toUtc();
    }
    if (dateValue is String) {
      try {
        print('🕐 Meeting._parseDateTime: Parsing string "$dateValue"');

        String dateStr = dateValue.trim();

        // If the string doesn't have timezone info (no 'Z' or timezone offset),
        // treat it as UTC (servers typically store dates in UTC)
        final hasTimezone = dateStr.endsWith('Z') ||
            RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(dateStr);

        if (!hasTimezone && dateStr.contains('T')) {
          // No timezone indicator - assume UTC and append 'Z'
          dateStr = '$dateStr Z';
          print('   → No timezone info, treating as UTC: "$dateStr"');
        }

        final parsed = DateTime.parse(dateStr);
        // Ensure we have a UTC DateTime for consistency
        final utcParsed = parsed.isUtc ? parsed : parsed.toUtc();

        print('   → Parsed as: $utcParsed (isUtc: ${utcParsed.isUtc})');
        print('   → UTC: ${utcParsed.toUtc()}, Local: ${utcParsed.toLocal()}');
        return utcParsed;
      } catch (e) {
        print('❌ Error parsing date: $dateValue - $e');
        return DateTime.now().toUtc();
      }
    }
    print(
        '⚠️  Meeting._parseDateTime: Unexpected type ${dateValue.runtimeType}, using DateTime.now()');
    return DateTime.now().toUtc();
  }

  static List<String> _parseMembers(dynamic membersValue) {
    if (membersValue == null) return [];
    if (membersValue is List) {
      return membersValue.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'place': place,
      'date': date.toIso8601String(),
      'time': time,
      'userId': userId,
      'members': members,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}
