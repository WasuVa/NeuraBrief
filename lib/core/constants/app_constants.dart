import "package:flutter/material.dart";

class AppConstants {
  static const Color backgroundStart = Color(0xFF0F172A);
  static const Color backgroundMid = Color(0xFF111827);
  static const Color backgroundEnd = Color(0xFF1E1B4B);
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF4DA8FF);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
  );
  static const Duration defaultAnimationDuration = Duration(milliseconds: 500);
}
