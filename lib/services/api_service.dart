// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  static Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method to safely parse JSON data
  static dynamic safeJsonDecode(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (e) {
      print('Error parsing JSON: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getResidences() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residences'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List) {
          return List<Map<String, dynamic>>.from(
            (data['data'] as List).map(
              (item) => Map<String, dynamic>.from(item ?? {}),
            ),
          );
        }
      }
      print('Invalid response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    } catch (e, stackTrace) {
      print('Error fetching residences: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getActivities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/activities'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List) {
          return List<Map<String, dynamic>>.from(
            (data['data'] as List).map(
              (item) => Map<String, dynamic>.from(item ?? {}),
            ),
          );
        }
      }
      print('Invalid response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    } catch (e, stackTrace) {
      print('Error fetching activities: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getHomeData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching home data: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> getResidenceDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residences/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('Invalid response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return {};
    } catch (e, stackTrace) {
      print('Error fetching residence detail: $e');
      print('Stack trace: $stackTrace');
      return {};
    }
  }

  static Future<Map<String, dynamic>> getActivityDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/activities/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('Invalid response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return {};
    } catch (e, stackTrace) {
      print('Error fetching activity detail: $e');
      print('Stack trace: $stackTrace');
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/bookmarks'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data']?['bookmarks']?['data'] is List) {
          return List<Map<String, dynamic>>.from(
            (data['data']['bookmarks']['data'] as List).map(
              (item) => Map<String, dynamic>.from(item ?? {}),
            ),
          );
        }
      }
      print('Invalid response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    } catch (e, stackTrace) {
      print('Error fetching bookmarks: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<bool> addBookmark(String type, int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/bookmarks'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'type': type.toLowerCase(),
          'id': id,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      print('Invalid response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    } catch (e, stackTrace) {
      print('Error adding bookmark: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<bool> removeBookmark(String type, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/bookmarks'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'type': type.toLowerCase(),
          'id': id,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('Invalid response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    } catch (e, stackTrace) {
      print('Error removing bookmark: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }
}
