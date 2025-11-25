class GalleryImage {
  final String id;
  final String url;
  final String month;
  final String? caption;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isVideo; // To distinguish between images and videos

  GalleryImage({
    required this.id,
    required this.url,
    required this.month,
    this.caption,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.isVideo = false,
  });

  // Factory constructor for creating from JSON
  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['_id'] ?? json['id'] ?? '',
      url: json['url'] ?? json['imageUrl'] ?? '',
      month: json['month'] ?? _formatMonth(json['createdAt']),
      caption: json['caption'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isFavorite: json['isFavorite'] ?? false,
      isVideo: json['isVideo'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'month': month,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isVideo': isVideo,
    };
  }

  // Helper method to format month from date string
  static String _formatMonth(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Create a copy with updated values
  GalleryImage copyWith({
    String? id,
    String? url,
    String? month,
    String? caption,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isVideo,
  }) {
    return GalleryImage(
      id: id ?? this.id,
      url: url ?? this.url,
      month: month ?? this.month,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isVideo: isVideo ?? this.isVideo,
    );
  }

  @override
  String toString() {
    return 'GalleryImage(id: $id, url: $url, month: $month, isFavorite: $isFavorite)';
  }
}

/// Model for event media response from API
class EventMedia {
  final List<String> images;
  final List<String> videos;

  EventMedia({
    required this.images,
    required this.videos,
  });

  factory EventMedia.fromJson(Map<String, dynamic> json) {
    return EventMedia(
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'images': images,
      'videos': videos,
    };
  }

  /// Convert event media to gallery images
  List<GalleryImage> toGalleryImages() {
    final List<GalleryImage> galleryImages = [];
    final now = DateTime.now();
    final month = '${_getMonthName(now.month)} ${now.year}';

    // Add images
    for (int i = 0; i < images.length; i++) {
      galleryImages.add(GalleryImage(
        id: 'img_$i',
        url: images[i],
        caption: 'Event Image ${i + 1}',
        createdAt: now,
        updatedAt: now,
        month: month,
        isFavorite: false,
        isVideo: false,
      ));
    }

    // Add videos
    for (int i = 0; i < videos.length; i++) {
      galleryImages.add(GalleryImage(
        id: 'vid_$i',
        url: videos[i],
        caption: 'Event Video ${i + 1}',
        createdAt: now,
        updatedAt: now,
        month: month,
        isFavorite: false,
        isVideo: true,
      ));
    }

    return galleryImages;
  }

  // Helper method to get month name
  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
