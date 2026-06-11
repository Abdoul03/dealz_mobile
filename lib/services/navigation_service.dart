import 'package:flutter/material.dart';

// Clé globale permettant de naviguer sans BuildContext
// Utilisée par ApiClient pour rediriger vers Login quand le refresh échoue
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
