import 'dart:io';
import 'package:flutter/material.dart';

class Constant {
  static const primaireColor = Color(0xFF174E43);
  static const secondaryColor = Color(0xFFE27B5B);
  static const tertiaoreColor = Color(0xFFDFEAE4);
  static const quatroColor = Color(0xFFF7F5EF);

  static const backgroundColor = Color(0xFFF7F5EF);

  // Peut être remplacée pour un appareil physique avec --dart-define=API_BASE_URL=...
  static const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get remoteUrl {
    if (_configuredApiBaseUrl.isNotEmpty) return _configuredApiBaseUrl;

    if (Platform.isAndroid) {
      return "http://10.0.2.2:8080/api";
    } else if (Platform.isIOS) {
      // Le simulateur iOS partage le réseau de l'hôte Mac.
      return "http://127.0.0.1:8080/api";
    } else {
      return "http://localhost:8080/api";
    }
  }
}
