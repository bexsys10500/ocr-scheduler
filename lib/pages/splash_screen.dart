import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

final supabase = Supabase.instance.client;

class _SplashScreenState extends State<SplashScreen> {
  final User? user = supabase.auth.currentUser;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final prefs = await SharedPreferences.getInstance();

      final bool welcomeSeen = prefs.getBool("welcome_seen") ?? false;

      if (!welcomeSeen) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/welcome");
        }
        return;
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        await supabase.auth.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/signin");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
