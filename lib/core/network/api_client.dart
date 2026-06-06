import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';

class ApiClient {
  // Singleton pattern for global access
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Helper to attach authorization headers
  Map<String, String> _getHeaders() {
    final token =
        GetStorage().read('staff_token') ?? GetStorage().read('user_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper to standardize response handling
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'API Error ${response.statusCode}'
      };
    }
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.apiBaseUrl}$endpoint');
      final response = await http.get(url, headers: _getHeaders());
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred.'};
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${ApiConstants.apiBaseUrl}$endpoint');
      final response =
          await http.post(url, headers: _getHeaders(), body: jsonEncode(body));
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred.'};
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${ApiConstants.apiBaseUrl}$endpoint');
      final response =
          await http.put(url, headers: _getHeaders(), body: jsonEncode(body));
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred.'};
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.apiBaseUrl}$endpoint');
      final response = await http.delete(url, headers: _getHeaders());
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred.'};
    }
  }
}
