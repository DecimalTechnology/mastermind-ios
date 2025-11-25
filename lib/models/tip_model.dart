class Tip {
  final String id;
  final String title;
  final String userId;
  final String description;
  final List<String> images;
  final List<String> videos;
  final bool isActive;
  final List<String> likes;
  final List<String> dislikes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tip({
    required this.id,
    required this.title,
    required this.userId,
    required this.description,
    required this.images,
    required this.videos,
    required this.isActive,
    required this.likes,
    required this.dislikes,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    List<String> _sanitizeList(dynamic list) {
      if (list is List) {
        return list
            .map((e) => (e ?? '').toString())
            .where(
                (s) => s.trim().isNotEmpty && s.trim().toLowerCase() != 'null')
            .toList();
      }
      return const [];
    }

    return Tip(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      userId: json['userId']?.toString() ?? '',
      description: json['description'] ?? '',
      images: _sanitizeList(json['images']),
      videos: _sanitizeList(json['videos']),
      isActive: json['isActive'] ?? true,
      likes: _sanitizeList(json['likes']),
      dislikes: _sanitizeList(json['dislikes']),
      tags: _sanitizeList(json['tags']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'userId': userId,
      'description': description,
      'images': images,
      'videos': videos,
      'isActive': isActive,
      'likes': likes,
      'dislikes': dislikes,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TipsResponse {
  final bool success;
  final String message;
  final List<Tip> data;

  TipsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TipsResponse.fromJson(Map<String, dynamic> json) {
    return TipsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => Tip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class TipResponse {
  final bool success;
  final String message;
  final Tip data;

  TipResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TipResponse.fromJson(Map<String, dynamic> json) {
    return TipResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: Tip.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class LikeDislikeResponse {
  final bool success;
  final String message;
  final Map<String, dynamic> data;

  LikeDislikeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LikeDislikeResponse.fromJson(Map<String, dynamic> json) {
    return LikeDislikeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] as Map<String, dynamic>,
    );
  }
}
