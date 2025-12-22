class HomeResponseModel {
  final bool success;
  final String message;
  final HomeData data;

  HomeResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    return HomeResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: HomeData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class HomeData {
  final UserInfo userInfo;
  final NextMeeting? nextMeeting;
  final List<NextMeeting> weeklyMeetings;
  final int connections;

  HomeData({
    required this.userInfo,
    this.nextMeeting,
    required this.weeklyMeetings,
    required this.connections,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    // Parse userInfo from the userInfo object
    UserInfo userInfo = UserInfo.fromJson(json['userInfo'] ?? {});

    // Handle case where nextMeeting might be null or empty
    NextMeeting? nextMeeting;
    if (json['nextMeeting'] != null &&
        json['nextMeeting'] is Map<String, dynamic>) {
      try {
        nextMeeting = NextMeeting.fromJson(json['nextMeeting']);
      } catch (e) {
        nextMeeting = null;
      }
    }

    // Parse weeklyMeetings
    List<NextMeeting> weeklyMeetings = [];
    if (json['weeklyMeetings'] != null && json['weeklyMeetings'] is List) {
      try {
        weeklyMeetings = (json['weeklyMeetings'] as List)
            .map((meeting) => NextMeeting.fromJson(meeting))
            .toList();
      } catch (e) {
        weeklyMeetings = [];
      }
    }

    // Handle case where data field contains an array of meetings (API format)
    if (json['data'] != null && json['data'] is List) {
      try {
        weeklyMeetings = (json['data'] as List)
            .map((meeting) => NextMeeting.fromJson(meeting))
            .toList();

        // Set the first meeting as nextMeeting if available
        if (weeklyMeetings.isNotEmpty) {
          nextMeeting = weeklyMeetings.first;
        }
      } catch (e) {
        weeklyMeetings = [];
      }
    }

    // Get connections count
    int connections = json['connections'] ?? 0;

    return HomeData(
      userInfo: userInfo,
      nextMeeting: nextMeeting,
      weeklyMeetings: weeklyMeetings,
      connections: connections,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userInfo': userInfo.toJson(),
      'nextMeeting': nextMeeting?.toJson(),
      'weeklyMeetings':
          weeklyMeetings.map((meeting) => meeting.toJson()).toList(),
      'connections': connections,
    };
  }
}

class UserInfo {
  final String email;
  final String image;
  final String memberSince;
  final String chapter;
  final String region;
  final String name;
  final String company;
  final String about;
  final String dob;
  final List<String> industries;
  final List<int> phoneNumbers;
  final String googleMapLocation;
  final String website;
  final String nation;
  final String local;

  UserInfo({
    required this.email,
    required this.image,
    required this.memberSince,
    required this.chapter,
    required this.region,
    this.name = '',
    this.company = '',
    this.about = '',
    this.dob = '',
    this.industries = const [],
    this.phoneNumbers = const [],
    this.googleMapLocation = '',
    this.website = '',
    this.nation = '',
    this.local = '',
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      memberSince: json['memberSince'] ?? '',
      chapter: json['chapter'] ?? '',
      region: json['region'] ?? '',
      name: json['name'] ?? '',
      company: json['company'] ?? '',
      about: json['about'] ?? '',
      dob: json['dob'] ?? '',
      industries: _parseIndustries(json['industries']),
      phoneNumbers: _parsePhoneNumbers(json['phoneNumbers']),
      googleMapLocation: json['googleMapLocation'] ?? '',
      website: json['website'] ?? '',
      nation: json['nation'] ?? '',
      local: json['local'] ?? '',
    );
  }

  static List<String> _parseIndustries(dynamic industriesValue) {
    if (industriesValue == null) return [];
    if (industriesValue is List) {
      return industriesValue.map((e) => e.toString()).toList();
    }
    if (industriesValue is String) {
      return industriesValue.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  static List<int> _parsePhoneNumbers(dynamic phoneNumbersValue) {
    if (phoneNumbersValue == null) return [];
    if (phoneNumbersValue is List) {
      return phoneNumbersValue
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'image': image,
      'memberSince': memberSince,
      'chapter': chapter,
      'region': region,
      'name': name,
      'company': company,
      'about': about,
      'dob': dob,
      'industries': industries,
      'phoneNumbers': phoneNumbers,
      'googleMapLocation': googleMapLocation,
      'website': website,
      'nation': nation,
      'local': local,
    };
  }
}

class NextMeeting {
  final String id;
  final String place;
  final DateTime date;
  final String time;
  final String userId;
  final List<String> members;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  NextMeeting({
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

  factory NextMeeting.fromJson(Map<String, dynamic> json) {
    try {
      final meeting = NextMeeting(
        id: json['_id']?.toString() ?? '',
        place: json['place']?.toString() ?? '',
        date: _parseDateTime(json['date']),
        time: json['time']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        members: _parseMembers(json['members']),
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
        version: json['__v'] is int ? json['__v'] : 0,
      );

      return meeting;
    } catch (e) {
      rethrow;
    }
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      print(
          '⚠️  NextMeeting._parseDateTime: dateValue is null, using DateTime.now()');
      return DateTime.now().toUtc();
    }
    if (dateValue is DateTime) {
      print(
          '⚠️  NextMeeting._parseDateTime: dateValue is already DateTime: $dateValue');
      return dateValue.isUtc ? dateValue : dateValue.toUtc();
    }
    if (dateValue is String) {
      try {
        print('🕐 NextMeeting._parseDateTime: Parsing string "$dateValue"');

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
        '⚠️  NextMeeting._parseDateTime: Unexpected type ${dateValue.runtimeType}, using DateTime.now()');
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
