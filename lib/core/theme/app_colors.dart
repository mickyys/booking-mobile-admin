import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color background = Color(0xFF0D141C);
  static const Color surface = Color(0xFF0D141C);
  static const Color surfaceLow = Color(0xFF151C24);
  static const Color surfaceHigh = Color(0xFF242B33);
  static const Color surfaceHighest = Color(0xFF2E353E);
  static const Color surfaceBright = Color(0xFF333A43);

  // Brand Colors
  static const Color primary = Color(0xFF00FF85);
  static const Color primaryDim = Color(0xFF00E476);
  static const Color primaryContainer = Color(0xFF00FF85);

  // Text Colors
  static const Color onSurface = Color(0xFFDCE3EF);
  static const Color onSurfaceVariant = Color(0xFFB9CBB9);
  static const Color onPrimary = Color(0xFF003919);

  // Accent & Others
  static const Color outline = Color(0xFF849584);
  static const Color error = Color(0xFFFFB4AB);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDim, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );
}
