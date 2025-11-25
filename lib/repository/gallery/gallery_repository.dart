import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:master_mind/models/gallery_model.dart';
import 'package:master_mind/utils/const.dart';

class GalleryRepository {
  final String baseUrl;

  GalleryRepository({String? apiUrl}) : baseUrl = apiUrl ?? baseurl;

  // Get authorization headers
  Map<String, String> _getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Fetch all media (images and videos) from events the user participated in
  Future<List<GalleryImage>> fetchGalleryImages(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/events/media'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          // Use the new EventMedia model to parse the response
          final eventMedia = EventMedia.fromJson(data['data']);
          return eventMedia.toGalleryImages();
        } else {
          throw Exception('Load failed: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Load failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading events media: $e');
    }
  }

  /// Upload image with file
  Future<GalleryImage> uploadImage({
    required String filePath,
    required String token,
    String? caption,
    String? location,
    List<String>? tags,
  }) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/v1/gallery/upload'));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add image file
      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      // Add optional fields
      if (caption != null) request.fields['caption'] = caption;
      if (location != null) request.fields['location'] = location;
      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = jsonEncode(tags);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return GalleryImage.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  /// Upload video with file
  Future<GalleryImage> uploadVideo({
    required String filePath,
    required String token,
    String? caption,
    String? location,
    List<String>? tags,
  }) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/v1/gallery/upload-video'));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add video file
      request.files.add(await http.MultipartFile.fromPath('video', filePath));

      // Add optional fields
      if (caption != null) request.fields['caption'] = caption;
      if (location != null) request.fields['location'] = location;
      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = jsonEncode(tags);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return GalleryImage.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to upload video: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading video: $e');
    }
  }

  /// Delete image
  Future<bool> deleteImage(String imageId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/v1/gallery/$imageId'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting image: $e');
    }
  }

  /// Toggle favorite status
  Future<GalleryImage> toggleFavorite(
      String imageId, String token, bool isFavorite) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/v1/gallery/$imageId/favorite'),
        headers: _getHeaders(token),
        body: jsonEncode({'isFavorite': isFavorite}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return GalleryImage.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to toggle favorite: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error toggling favorite: $e');
    }
  }

  /// Update image details (caption, location, tags)
  Future<GalleryImage> updateImage({
    required String imageId,
    required String token,
    String? caption,
    String? location,
    List<String>? tags,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      if (caption != null) requestBody['caption'] = caption;
      if (location != null) requestBody['location'] = location;
      if (tags != null) requestBody['tags'] = tags;

      final response = await http.patch(
        Uri.parse('$baseUrl/v1/gallery/$imageId'),
        headers: _getHeaders(token),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return GalleryImage.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to update image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating image: $e');
    }
  }

  /// Get favorite images
  Future<List<GalleryImage>> getFavoriteImages(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/gallery/favorites'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> imagesList = data['data'] ?? data['images'] ?? [];
        return imagesList.map((json) => GalleryImage.fromJson(json)).toList();
      } else {
        throw Exception('Load failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading favorite images: $e');
    }
  }

  /// Get images by location
  Future<List<GalleryImage>> getImagesByLocation(
      String token, String location) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/v1/gallery/location?location=${Uri.encodeComponent(location)}'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> imagesList = data['data'] ?? data['images'] ?? [];
        return imagesList.map((json) => GalleryImage.fromJson(json)).toList();
      } else {
        throw Exception('Load failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading location images: $e');
    }
  }

  /// Search images by tags or caption
  Future<List<GalleryImage>> searchImages(String token, String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/gallery/search?q=${Uri.encodeComponent(query)}'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> imagesList = data['data'] ?? data['images'] ?? [];
        return imagesList.map((json) => GalleryImage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search images: ${response.body}');
      }
    } catch (e) {
      print('Error searching images: $e');
      throw Exception('Error searching images: $e');
    }
  }
}
