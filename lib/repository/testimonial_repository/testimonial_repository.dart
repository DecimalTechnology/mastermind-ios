import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:master_mind/models/testimonial_model.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/core/error_handling/exceptions/custom_exceptions.dart';
import 'package:master_mind/repository/Auth_repository.dart';
import 'package:master_mind/services/http_service.dart';

// Model for the /v1/testimonial/given API
class GivenTestimonial {
  final String id;
  final String message;
  final String name;
  final String email;
  final String image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GivenTestimonial({
    required this.id,
    required this.message,
    required this.name,
    required this.email,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory GivenTestimonial.fromJson(Map<String, dynamic> json) {
    // Parse date fields from various possible keys
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    DateTime? createdAt = parseDate(json['created_at']) ??
        parseDate(json['createdAt']) ??
        parseDate(json['created_at_date']) ??
        parseDate(json['date']) ??
        parseDate(json['timestamp']) ??
        parseDate(json['created_at_timestamp']);

    DateTime? updatedAt = parseDate(json['updated_at']) ??
        parseDate(json['updatedAt']) ??
        parseDate(json['updated_at_date']) ??
        parseDate(json['modified_at']) ??
        parseDate(json['modifiedAt']);

    return GivenTestimonial(
      id: json['_id'] ?? '',
      message: json['message'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class TestimonialRepository {
  final String baseUrl = baseurl;
  final AuthRepository _authRepository = AuthRepository();
  final HttpService _httpService = HttpService();

  Future<Testimonial> giveTestimonial(String userId, String message) async {
    const endpoint = '/v1/testimonial/give';

    try {
      final url = Uri.parse('$baseUrl$endpoint/$userId');
      final requestBody = {'message': message};

      final response = await _httpService.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          return Testimonial.fromJson(data);
        } catch (e) {
          _httpService.trackParsingError(endpoint, 'POST',
              'Failed to parse testimonial response: $e', response.body);
          throw ServerException('Failed to parse testimonial response');
        }
      } else {
        throw ServerException(
            'Failed to give testimonial: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }

  Future<List<Testimonial>> getUserTestimonials(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/v1/testimonial/user/$userId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => Testimonial.fromJson(json)).toList();
        }
        return [];
      } else {
        throw ServerException(
            'Failed to fetch testimonials: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }

  Future<List<GivenTestimonial>> getReceivedTestimonials() async {
    try {
      final url = Uri.parse('$baseUrl/v1/testimonial/received');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List?;
        if (list != null) {
          return list.map((json) => GivenTestimonial.fromJson(json)).toList();
        }
        return [];
      } else {
        throw ServerException(
            'Failed to fetch received testimonials: \\${response.statusCode}');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }

  Future<bool> requestTestimonial(
      String targetUserId, String requestMessage) async {
    try {
      final url = Uri.parse('$baseUrl/v1/testimonial/ask/$targetUserId');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'message': requestMessage,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw ServerException(
            'Failed to request testimonial: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }

  Future<String?> _getAuthToken() async {
    return await _authRepository.getAuthToken();
  }

  // Fetch testimonial counts for the current user using token
  Future<Map<String, int>> getTestimonialCountsWithToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/testimonial/count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final counts = data['data'] ?? {};
        return {
          'received': counts['receivedCount'] ?? 0,
          'given': counts['givenCount'] ?? 0,
          'asked': counts['requestCount'] ?? 0,
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw AppException(
            errorData['message'] ?? 'Failed to fetch testimonial counts');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Network error: $e');
    }
  }

  // Fetch testimonials given by the current user
  Future<List<GivenTestimonial>> getGivenTestimonials() async {
    try {
      final url = Uri.parse('$baseUrl/v1/testimonial/given');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List?;
        if (list != null) {
          return list.map((json) => GivenTestimonial.fromJson(json)).toList();
        }
        return [];
      } else {
        throw ServerException(
            'Failed to fetch given testimonials: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }

  // Fetch testimonials requested by the current user
  Future<List<GivenTestimonial>> getRequestedTestimonials() async {
    try {
      final url = Uri.parse('$baseUrl/v1/testimonial/requests');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List?;
        if (list != null) {
          return list.map((json) => GivenTestimonial.fromJson(json)).toList();
        }
        return [];
      } else {
        throw ServerException(
            'Failed to fetch requested testimonials: \\${response.statusCode}');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }
}
