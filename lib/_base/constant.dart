import 'dart:io';
import 'package:flutter/material.dart';

class Constant {
  static const primaireColor = Color(0xFF355872);
  static const secondaryColor = Color(0xFF7AAACE);
  static const tertiaoreColor = Color(0xFF9CD5FF);
  static const quatroColor = Color(0xFFF7F8F0);

  static const backgroundColor = Color(0xFFF8F9FA);

  // IP du Mac sur le réseau local (obtenue via `ipconfig getifaddr en0`)
  static const _macIp = "192.168.1.52";

  static String get remoteUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8080/api";
    } else if (Platform.isIOS) {
      return "http://$_macIp:8080/api";
    } else {
      return "http://localhost:8080/api";
    }
  }
}
