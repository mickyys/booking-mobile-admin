import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color background = Color(0xFF2C3345);
  static const Color surface = Color(0xFF2C3345);
  static const Color surfaceLow = Color(0xFF343B4F);
  static const Color surfaceHigh = Color(0xFF3E465A);
  static const Color surfaceHighest = Color(0xFF485166);
  static const Color surfaceBright = Color(0xFF525C73);

  // Brand Colors
  static const Color primary = Color(0xFF47D592);
  static const Color primaryDim = Color(0xFF3EB97E);
  static const Color primaryContainer = Color(0xFF47D592);

  // Text Colors
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFB0B8C1);
  static const Color onPrimary = Color(0xFF003919);

  // Accent & Others
  static const Color outline = Color(0xFF5E6977);
  static const Color error = Color(0xFFFFB4AB);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDim, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );
}
