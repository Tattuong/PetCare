import 'package:flutter/material.dart';

/// Soft pastel palette inspired by modern PetCare mockups.
class AppColors {
  static const Color pastelLavender = Color(0xFFD4C4F5);
  static const Color pastelLavenderDark = Color(0xFF9B8FD9);
  static const Color pastelPurple = Color(0xFFB8A9E8);
  static const Color pastelGreen = Color(0xFFB8E6C8);
  static const Color pastelGreenDark = Color(0xFF6BCB8E);
  static const Color pastelOrange = Color(0xFFFFD4A8);
  static const Color pastelOrangeDark = Color(0xFFFFB86C);
  static const Color pastelPink = Color(0xFFFADADD);
  static const Color pastelPinkDark = Color(0xFFFFB3C6);
  static const Color pastelYellow = Color(0xFFFFEAA7);
  static const Color pastelYellowDark = Color(0xFFFFD93D);

  static const Color primary = pastelLavenderDark;
  static const Color primaryLight = pastelLavender;
  static const Color primaryDark = Color(0xFF7B6BC4);

  static const Color accent = pastelOrangeDark;
  static const Color accentAlt = pastelOrange;

  static const Color textPrimary = Color(0xFF2D2A3E);
  static const Color textSecondary = Color(0xFF6B6780);
  static const Color textMuted = Color(0xFF9E99B0);

  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F0FA);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF2D2A3E);
  static const Color onSurfaceVariant = Color(0xFF6B6780);

  static const Color success = Color(0xFF55C595);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF6B6B);
  static const Color coin = Color(0xFFFFD93D);

  static const Color trueBlack = Color(0xFF1E1A2E);
  static const Color darkBackground = Color(0xFF1E1A2E);
  static const Color darkSurface = Color(0xFF2A2540);
  static const Color darkCard = Color(0xFF342F4A);
  static const Color darkNavBar = Color(0xFF2A2540);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pastelLavender, pastelPurple],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pastelOrange, pastelOrangeDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pastelLavender, pastelOrange],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F0FF), Color(0xFFEDE6FA), Color(0xFFFFF5EB)],
  );

  static const LinearGradient reminderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF9B8FD9), Color(0xFFB8A9E8)],
  );

  static const List<Color> quickActionColors = [
    pastelPurple,
    pastelOrange,
    pastelPinkDark,
    pastelYellowDark,
  ];

  static const List<Color> categoryPalette = [
    pastelPurple,
    pastelOrangeDark,
    pastelPinkDark,
    pastelYellowDark,
    pastelGreenDark,
    Color(0xFF74B9FF),
    Color(0xFF636E72),
    Color(0xFFFF7675),
  ];

  static Color circleColor(bool isWarm) => isWarm ? pastelOrange : pastelLavender;
}
