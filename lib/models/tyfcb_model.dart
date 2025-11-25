class TYFCBModel {
  final String id;
  final String message;
  final int amount;
  final DateTime createdAt;
  final String image;
  final String name;
  final String email;
  final String businessType;

  TYFCBModel({
    required this.id,
    required this.message,
    required this.amount,
    required this.createdAt,
    required this.image,
    required this.name,
    required this.email,
    required this.businessType,
  });

  factory TYFCBModel.fromJson(Map<String, dynamic> json) {
    return TYFCBModel(
      id: json['_id'] ?? '',
      message: json['message'] ?? '',
      amount: json['amount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      businessType: json['businessType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'message': message,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'image': image,
      'name': name,
      'email': email,
      'businessType': businessType,
    };
  }
}
