import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:master_mind/models/event_model.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';

class EventRepository {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<String?> getAuthToken() async {
    return await storage.read(key: 'authToken');
  }

  Future<Map<String, dynamic>> getEvents({
    String? sort,
    String? filter,
    String? chapterId,
    String? regionId,
    String? localId,
    String? nationId,
    String? userId,
    String? date,
  }) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw Exception('No authentication token found.');
      }

      // Build query parameters
      final queryParams = <String, String>{};
      // Always provide sort and filter as they seem to be required
      queryParams['sort'] = sort ?? 'chapter';
      queryParams['filter'] = filter ?? 'all';
      if (chapterId != null) queryParams['chapterId'] = chapterId;
      if (regionId != null) queryParams['regionId'] = regionId;
      if (localId != null) queryParams['localId'] = localId;
      if (nationId != null) queryParams['nationId'] = nationId;
      if (userId != null) queryParams['userId'] = userId;
      if (date != null) queryParams['date'] = date;

      final uri =
          Uri.parse('$baseurl/v1/events').replace(queryParameters: queryParams);

      print("=== EVENT API CALL ===");
      print("URL: $uri");
      print("Query parameters: $queryParams");
      print("=====================");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Events API Response: $responseData");

        // Handle the new response structure: {success: true, data: {events: [], meetings: []}}
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;

          List<Event> events = [];
          List<Meeting> meetings = [];

          // Parse events
          if (data.containsKey('events') && data['events'] is List) {
            events = (data['events'] as List).map((json) {
              try {
                return Event.fromJson(json);
              } catch (e) {
                print("Error parsing event: $e");
                rethrow;
              }
            }).toList();
          }

          // Parse meetings
          if (data.containsKey('meetings') && data['meetings'] is List) {
            meetings = (data['meetings'] as List).map((json) {
              try {
                return Meeting.fromJson(json);
              } catch (e) {
                print("Error parsing meeting: $e");
                rethrow;
              }
            }).toList();
          }

          return {
            'events': events,
            'meetings': meetings,
          };
        } else {
          // Fallback to old structure for backward compatibility
          List<dynamic> eventsData;
          if (responseData is List) {
            eventsData = responseData;
          } else if (responseData is Map<String, dynamic>) {
            final data = responseData['data'];
            if (data is List) {
              eventsData = data;
            } else if (data is Map<String, dynamic>) {
              if (data['events'] is List) {
                eventsData = data['events'] as List;
              } else if (data['docs'] is List) {
                eventsData = data['docs'] as List;
              } else if (data['items'] is List) {
                eventsData = data['items'] as List;
              } else if (data['results'] is List) {
                eventsData = data['results'] as List;
              } else {
                throw Exception('Unexpected data shape: ${response.body}');
              }
            } else {
              throw Exception('Unexpected data type: ${response.body}');
            }
          } else {
            throw Exception('Unexpected response structure: ${response.body}');
          }

          final events = eventsData.map((json) {
            try {
              return Event.fromJson(json);
            } catch (e) {
              rethrow;
            }
          }).toList();

          return {
            'events': events,
            'meetings': [],
          };
        }
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to load events');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to load events: ${e.toString()}');
    }
  }

  Future<bool> registerForEvent(String eventId) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw AuthenticationException('No authentication token found.');
      }

      final response = await http.post(
        Uri.parse('$baseurl/v1/events/$eventId/register'),
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to register for event');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to register for event: ${e.toString()}');
    }
  }

  Future<bool> setReminder(String eventId, bool setReminder) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw AuthenticationException('No authentication token found.');
      }

      final response = await http.post(
        Uri.parse('$baseurl/v1/events/$eventId/reminder'),
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
        body: json.encode({'setReminder': setReminder}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to set reminder');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to set reminder: ${e.toString()}');
    }
  }

  Future<List<String>> getRegions() async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw AuthenticationException('No authentication token found.');
      }

      final response = await http.get(
        Uri.parse('$baseurl/v1/regions'),
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => json['name'] as String).toList();
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to load regions');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to load regions: ${e.toString()}');
    }
  }

  Future<List<String>> getChapters(String region) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw AuthenticationException('No authentication token found.');
      }

      final response = await http.get(
        Uri.parse('$baseurl/v1/regions/$region/chapters'),
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => json['name'] as String).toList();
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to load chapters');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to load chapters: ${e.toString()}');
    }
  }

  Future<bool> patchRegisterForEvent(String eventId) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw AuthenticationException('No authentication token found.');
      }
      final response = await http.patch(
        Uri.parse('$baseurl/v1/events/register/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to register for event');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to register for event: ${e.toString()}');
    }
  }

  Future<bool> cancelRegisterForEvent(String eventId) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw AuthenticationException('No authentication token found.');
      }
      final response = await http.delete(
        Uri.parse('$baseurl/v1/events/register/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to cancel registration');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to cancel registration: ${e.toString()}');
    }
  }

  Future<Event> getEventDetails(String eventId) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw AuthenticationException('No authentication token found.');
      }

      print("Fetching event details for ID: $eventId");
      final response = await http.get(
        Uri.parse('$baseurl/v1/events/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Event details parsed response: $responseData");

        // Handle different response structures
        Map<String, dynamic> eventData;
        if (responseData.containsKey('data')) {
          eventData = responseData['data'];
        } else if (responseData is Map<String, dynamic>) {
          eventData = responseData;
        } else {
          throw ValidationException(
              'Unexpected event details response structure: ${response.body}');
        }

        try {
          final event = Event.fromJson(eventData);
          return event;
        } catch (e) {
          throw ValidationException(
              'Invalid event data format: ${e.toString()}');
        }
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to load event details');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to load event details: ${e.toString()}');
    }
  }
}
