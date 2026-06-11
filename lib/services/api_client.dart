import 'dart:convert';
import 'package:dealz/_base/constant.dart';
import 'package:dealz/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService().getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  static Future<http.Response> get(String path) async {
    return http.get(
      Uri.parse('${Constant.remoteUrl}$path'),
      headers: await _headers(),
    );
  }

  static Future<http.Response> post(String path,
      [Map<String, dynamic>? body]) async {
    return http.post(
      Uri.parse('${Constant.remoteUrl}$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> patch(String path) async {
    return http.patch(
      Uri.parse('${Constant.remoteUrl}$path'),
      headers: await _headers(),
    );
  }

  static String parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['message'] as String? ?? 'Erreur inconnue.';
    } catch (_) {
      return 'Erreur inconnue (${response.statusCode}).';
    }
  }
}
