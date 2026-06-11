import 'dart:convert';
import 'package:dealz/_base/constant.dart';
import 'package:dealz/screens/login_screen.dart';
import 'package:dealz/services/auth_service.dart';
import 'package:dealz/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  // Empêche plusieurs redirections vers Login simultanées
  static bool _redirectingToLogin = false;

  // ── Headers ────────────────────────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService().getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // ── Méthodes publiques ─────────────────────────────────────────────

  static Future<http.Response> get(String path) {
    return _execute((h) => http.get(
          Uri.parse('${Constant.remoteUrl}$path'),
          headers: h,
        ));
  }

  static Future<http.Response> post(String path,
      [Map<String, dynamic>? body]) {
    return _execute((h) => http.post(
          Uri.parse('${Constant.remoteUrl}$path'),
          headers: h,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  static Future<http.Response> patch(String path) {
    return _execute((h) => http.patch(
          Uri.parse('${Constant.remoteUrl}$path'),
          headers: h,
        ));
  }

  // ── Cœur : intercepteur 401 → refresh → retry ─────────────────────

  static Future<http.Response> _execute(
    Future<http.Response> Function(Map<String, String> headers) makeRequest, {
    bool isRetry = false,
  }) async {
    final headers = await _headers();
    final response = await makeRequest(headers);

    // Réponse valide ou erreur non-liée au token
    if (response.statusCode != 401) return response;

    // Déjà un retry → le refresh a échoué → déconnecter
    if (isRetry) {
      await _forceLogout();
      return response;
    }

    // Tentative de refresh du token
    final refreshed = await AuthService().refreshTokens();
    if (!refreshed) {
      await _forceLogout();
      return response;
    }

    // Retry avec le nouveau token (une seule fois)
    return _execute(makeRequest, isRetry: true);
  }

  // ── Déconnexion forcée si refresh impossible ───────────────────────

  static Future<void> _forceLogout() async {
    if (_redirectingToLogin) return;
    _redirectingToLogin = true;

    await AuthService().logout();

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );

    // Réinitialiser après navigation
    Future.delayed(const Duration(seconds: 3),
        () => _redirectingToLogin = false);
  }

  // ── Utilitaire ─────────────────────────────────────────────────────

  static String parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['message'] as String? ?? 'Erreur inconnue.';
    } catch (_) {
      return 'Erreur inconnue (${response.statusCode}).';
    }
  }
}
