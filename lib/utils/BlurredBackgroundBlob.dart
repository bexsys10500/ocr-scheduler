import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredBackgroundBlob extends StatelessWidget {
  const BlurredBackgroundBlob({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main soft gradient background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF), // almost white
                  Color(0xFFFBE7F2), // soft pink
                  Color(0xFFEDE8FF), // soft purple
                ],
                stops: [0.1, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Right side hazy pink/purple blob
        Positioned(
          right: -100,
          top: 50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFDFC7FF).withOpacity(0.3), // light violet
                    Color(0x00FFFFFF), // transparent
                  ],
                  radius: 0.85,
                ),
              ),
            ),
          ),
        ),

        // Subtle pink glow on bottom-left
        Positioned(
          left: -150,
          bottom: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 150, sigmaY: 150),
            child: Container(
              width: 500,
              height: 500,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFFE4F2), // soft pink
                    Color(0x00FFFFFF),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
