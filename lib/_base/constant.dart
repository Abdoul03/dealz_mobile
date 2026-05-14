import 'dart:io';
import 'package:flutter/material.dart';

class Constant {
  static const primaireColor = Color(0xFF355872);
  static const secondaryColor = Color(0xFF7AAACE);
  static const tertiaoreColor = Color(0xFF9CD5FF);
  static const quatroColor = Color(0xFFF7F8F0);

  static const backgroundColor = Color(0xFFF8F9FA);

  static String get remoteUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:7070/api/v1";
    } else if (Platform.isIOS) {
      return "http://localhost:8080/api";
      // return "http://192.168.1.94:7070/api/v1";
    } else {
      // Pour d'autres plateformes (web, desktop, etc.)
      return "http://localhost:8080/api";
    }
  }
}
