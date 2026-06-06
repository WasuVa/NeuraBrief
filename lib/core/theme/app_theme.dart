import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../constants/app_constants.dart";

class AppTheme {
  static const Color primary = AppConstants.primary;

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppConstants.backgroundStart,
      colorScheme: base.colorScheme.copyWith(
        primary: AppConstants.primary,
        secondary: AppConstants.secondary,
        surface: const Color(0x1AFFFFFF),
      ),
      textTheme: TextTheme(
        displaySmall: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white60,
        ),
      ),
    );
  }
}
