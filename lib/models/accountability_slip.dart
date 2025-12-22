class MemberDetail {
  final String id;
  final String? name;
  final String? email;
  final String? image;

  MemberDetail({
    required this.id,
    required this.name,
    required this.email,
    this.image,
  });

  factory MemberDetail.fromJson(Map<String, dynamic> json) {
    return MemberDetail(
      id: json['userId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
    };
  }
}

class AccountabilitySlip {
  final String? id;
  final String place;
  final DateTime date;
  final String? userId;
  final List<MemberDetail> members;

  AccountabilitySlip({
    this.id,
    required this.place,
    required this.date,
    this.userId,
    required this.members,
  });

  factory AccountabilitySlip.fromJson(Map<String, dynamic> json) {
    // Parse date from string to DateTime
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) {
        print(
            '⚠️  AccountabilitySlip.parseDate: dateValue is null, using DateTime.now()');
        return DateTime.now();
      }
      if (dateValue is DateTime) {
        print(
            '⚠️  AccountabilitySlip.parseDate: dateValue is already DateTime: $dateValue');
        return dateValue;
      }
      if (dateValue is String) {
        try {
          print('🕐 AccountabilitySlip.parseDate: Parsing string "$dateValue"');

          String dateStr = dateValue.trim();

          // If the string doesn't have timezone info (no 'Z' or timezone offset),
          // treat it as UTC (servers typically store dates in UTC)
          // Check if it has timezone indicator
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
          print(
              '   → UTC: ${utcParsed.toUtc()}, Local: ${utcParsed.toLocal()}');
          return utcParsed;
        } catch (e) {
          print('❌ Error parsing date: $dateValue - $e');
          return DateTime.now().toUtc();
        }
      }
      print(
          '⚠️  AccountabilitySlip.parseDate: Unexpected type ${dateValue.runtimeType}, using DateTime.now()');
      return DateTime.now();
    }

    return AccountabilitySlip(
      id: json['_id'] ?? '',
      place: json['place'] ?? '',
      date: parseDate(json['date']),
      userId: json['userId'] ?? '',
      members: json['members'] != null
          ? List<MemberDetail>.from(
              json['members'].map((x) => MemberDetail.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final dateString = date.toIso8601String();

    return {
      'place': place,
      'date':
          dateString, // Send as ISO string but backend will parse as DateTime
      'members': members.map((member) => member.toJson()).toList(),
    };
  }
}
