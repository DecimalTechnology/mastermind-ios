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
      if (dateValue == null) return DateTime.now();
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return DateTime.now();
        }
      }
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
