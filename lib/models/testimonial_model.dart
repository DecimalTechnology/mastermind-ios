class Testimonial {
  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final String? userCompany;
  final String message;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Testimonial({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    this.userCompany,
    required this.message,
    required this.createdAt,
    this.updatedAt,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? '',
      userImage: json['user_image'] ?? json['userImage'],
      userCompany: json['user_company'] ?? json['userCompany'],
      message: json['message'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'user_company': userCompany,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Testimonial(id: $id, userId: $userId, userName: $userName, message: $message)';
  }
}
