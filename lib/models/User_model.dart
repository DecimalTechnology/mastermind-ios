enum UserRole {
  MEMBER,
  ADMIN,
  SUPER_ADMIN,
  // Add other roles as needed
}

class User {
  final String id;
  final String name;
  final String email;
  final int phoneNumber;
  final String? password;
  final UserRole role;
  final String? chapterId;
  final String? nationId;
  final String? regionId;
  final String? localId;
  final Map<String, dynamic>? manage;
  final bool isVerified;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.password,
    required this.role,
    this.chapterId,
    this.nationId,
    this.regionId,
    this.localId,
    this.manage,
    required this.isVerified,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phonenumber'],
      password: json['password'],
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == json['role'],
        orElse: () => UserRole.MEMBER,
      ),
      chapterId: json['chapter'],
      nationId: json['nation'],
      regionId: json['region'],
      localId: json['local'],
      manage: json['manage'],
      isVerified: json['isVerified'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phonenumber': phoneNumber,
      'password': password,
      'role': role.toString().split('.').last,
      'chapter': chapterId,
      'nation': nationId,
      'region': regionId,
      'local': localId,
      'manage': manage,
      'isVerified': isVerified,
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? phoneNumber,
    String? password,
    UserRole? role,
    String? chapterId,
    String? nationId,
    String? regionId,
    String? localId,
    Map<String, dynamic>? manage,
    bool? isVerified,
    bool? isBlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      role: role ?? this.role,
      chapterId: chapterId ?? this.chapterId,
      nationId: nationId ?? this.nationId,
      regionId: regionId ?? this.regionId,
      localId: localId ?? this.localId,
      manage: manage ?? this.manage,
      isVerified: isVerified ?? this.isVerified,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
