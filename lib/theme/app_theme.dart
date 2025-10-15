import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF00D4FF);
  static const Color accentColor = Color(0xFFFF6584);
  static const Color backgroundColor = Color(0xFF0A0E27);
  static const Color surfaceColor = Color(0xFF151A30);
  static const Color cardColor = Color(0xFF1E2541);

  static const List<Color> cardColors = [
    Color(0xFFFF6B9D),
    Color(0xFFC06C84),
    Color(0xFF6C5CE7),
    Color(0xFF00B894),
    Color(0xFFFD79A8),
    Color(0xFF74B9FF),
    Color(0xFFA29BFE),
    Color(0xFFFFA502),
    Color(0xFF26DE81),
    Color(0xFFFC5C65),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundColor, surfaceColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
