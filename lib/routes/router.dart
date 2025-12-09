import 'package:flutter/material.dart';
import 'package:ocr_task_scheduler/pages/home_screen.dart';
import 'package:ocr_task_scheduler/pages/signin_screen.dart';
import 'package:ocr_task_scheduler/pages/splash_screen.dart';
import 'package:ocr_task_scheduler/pages/welcome_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String signin = '/signin';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case signin:
        return MaterialPageRoute(builder: (_) => const SigninScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('404 - Page not found'))),
        );
    }
  }
}
