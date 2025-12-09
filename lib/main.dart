import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocr_task_scheduler/routes/router.dart';
import 'package:ocr_task_scheduler/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_size/window_size.dart' as window_size;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://qtbgfwkzmwdxdeggtstn.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0Ymdmd2t6bXdkeGRlZ2d0c3RuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NDIwNjYsImV4cCI6MjA3ODMxODA2Nn0.y934P-nczOB3k_63lIugSLlf8_sWBFZ0kClTaEab5IA",
  );
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    window_size.setWindowMinSize(const Size(800, 600)); // MIN SIZE
    window_size.setWindowMaxSize(Size.infinite); // Optional
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Scheduler',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
