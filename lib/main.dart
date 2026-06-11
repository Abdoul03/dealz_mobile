import 'package:dealz/screens/home_screen.dart';
import 'package:dealz/screens/login_screen.dart';
import 'package:dealz/screens/onboarding_screen.dart';
import 'package:dealz/services/auth_service.dart';
import 'package:dealz/services/navigation_service.dart';
import 'package:flutter/material.dart';

// Observateur global de navigation — permet à HomeScreen de détecter
// quand il redevient actif après un retour de navigation (ex: ajout d'annonce)
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dealz',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      home: const _SplashRouter(),
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final auth = AuthService();
    final isLogged = await auth.isLoggedIn();
    if (!mounted) return;

    if (isLogged) {
      _go(const HomeScreen());
      return;
    }

    final onboardingSeen = await auth.isOnboardingSeen();
    if (!mounted) return;
    _go(onboardingSeen ? const LoginScreen() : const OnboardingScreen());
  }

  void _go(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
