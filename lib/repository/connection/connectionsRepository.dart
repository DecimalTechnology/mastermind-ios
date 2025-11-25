import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:master_mind/models/Allconnection/allCollection_model.dart';
import 'package:master_mind/models/connection_model.dart';
import 'package:master_mind/models/profile_model.dart';
import 'package:master_mind/models/search_model.dart';
import 'package:master_mind/utils/const.dart';

class ConnectionRepository {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<String?> getAuthToken() async {
    return await storage.read(key: 'authToken');
  }

  Future<List<SearchResult>> getRequests() async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final url = Uri.parse('https://example.com/api/requests');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Load failed: ${response.body}');
    }
  }

  Future<ProfileModel?> getUserDetails(String userId) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw Exception('No authentication token found.');
      }

      final url = Uri.parse('$baseurl/v1/profile/$userId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);

        return ProfileModel.fromJson(decodedBody);
      } else {
        throw Exception('Load failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Load failed: $e');
    }
  }

  Future<String> sendConnectionRequest(String userId) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw Exception('No authentication token found.');
      }

      final response = await http.post(
        Uri.parse('$baseurl/v1/profile/connect?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );

      final decodedBody = json.decode(response.body);

      final connectionModel = ConnectionModel.fromJson(decodedBody);

      if (response.statusCode == 200 && connectionModel.success) {
        return connectionModel.connectionStatus.toString();
      } else {
        throw Exception(connectionModel.message);
      }
    } catch (e) {
      throw Exception('Failed to send connection request: ${e.toString()}');
    }
  }

  Future<List<SearchResult>> getSentRequests() async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final url = Uri.parse('https://example.com/api/requests');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Load failed: ${response.body}');
    }
  }

  Future<bool> acceptRequest(String userid) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    final url = Uri.parse('$baseurl/v1/profile/connect/accept');
    final response = await http.patch(url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': token,
        },
        body: json.encode({'userId': userid}));

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<List<SearchResult>> getMyConnections() async {
    return await _fetchData('https://example.com/api/my-connections');
  }

  Future<List<SearchResult>> _fetchData(String url) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Load failed: ${response.body}');
    }
  }

  Future<bool> rejectRequest(String requestId) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final url = Uri.parse('https://example.com/api/requests/$requestId/reject');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> disconnectUser(String userId) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw Exception('No authentication token found.');
      }

      final url = Uri.parse('$baseurl/v1/profile/connect/remove');

      final response = await http.patch(url,
          headers: {
            'Content-Type': 'application/json',
            'access-token': accessToken,
          },
          body: json.encode({'userId': userId}));

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        SearchResult.fromJson(decodedBody);

        return true;
      } else {
        throw Exception('Load failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Load failed: $e');
    }
  }

  Future<String> cancelRequest(String userId) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw Exception('No authentication token found.');
      }

      final url = Uri.parse('$baseurl/v1/profile/connect/cancel');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
        body: json.encode({'userId': userId}),
      );

      final decodedBody = json.decode(response.body);

      final connectionModel = ConnectionModel.fromJson(decodedBody);

      if (response.statusCode == 200 && connectionModel.success) {
        return connectionModel.connectionStatus.toString();
      } else {
        throw Exception(connectionModel.message);
      }
    } catch (e) {
      throw Exception('Failed to send connection request: ${e.toString()}');
    }
  }

  // get all connection count
//
//
//
//
  Future<ConnectionCountModel> getAllConnectionCount() async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final url = Uri.parse('$baseurl/v1/profile/connect/all');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final connectionModel = ConnectionCountModel.fromJson(data);

      return connectionModel;
    } else {
      throw Exception('Failed to fetch data: \${response.body}');
    }
  }

  //
  //
  //
  //

  // get all connections details provider
  Future<List<SearchResult>> getAllconnectionDetails() async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw Exception('No authentication token found.');
      }

      final url = Uri.parse('$baseurl/v1/profile/connect/connections');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        // Ensure 'data' exists and is a list
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> dataList = decodedBody['data'];

          // Convert List<dynamic> to List<SearchResult>
          final List<SearchResult> connectionDetails = dataList
              .map((jsonItem) => SearchResult.fromJson(jsonItem))
              .toList();

          return connectionDetails;
        } else {
          throw Exception(
              'Invalid response format: "data" key missing or not a list.');
        }
      } else {
        throw Exception(
            'Failed request with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch sent requests: ${e.toString()}');
    }
  }

  // get all recieved request details provider
  Future<List<SearchResult>> getAllReceivedRequestDetails() async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw Exception('No authentication token found.');
      }

      final url = Uri.parse('$baseurl/v1/profile/connect/received');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        // Ensure 'data' exists and is a list
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> dataList = decodedBody['data'];

          // Convert List<dynamic> to List<SearchResult>
          final List<SearchResult> recievedRequests = dataList
              .map((jsonItem) => SearchResult.fromJson(jsonItem))
              .toList();

          return recievedRequests;
        } else {
          throw Exception(
              'Invalid response format: "data" key missing or not a list.');
        }
      } else {
        throw Exception(
            'Failed request with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch sent requests: ${e.toString()}');
    }
  }

  // get all recieved request details provider
  Future<List<SearchResult>> getAllSentRequestDetails() async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw Exception('No authentication token found.');
      }

      final url = Uri.parse('$baseurl/v1/profile/connect/sent');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        // Ensure 'data' exists and is a list
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> dataList = decodedBody['data'];

          // Convert List<dynamic> to List<SearchResult>
          final List<SearchResult> sentRequests = dataList
              .map((jsonItem) => SearchResult.fromJson(jsonItem))
              .toList();

          return sentRequests;
        } else {
          throw Exception(
              'Invalid response format: "data" key missing or not a list.');
        }
      } else {
        throw Exception(
            'Failed request with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch sent requests: ${e.toString()}');
    }
  }
}
