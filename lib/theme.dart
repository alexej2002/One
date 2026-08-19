import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Common Colors
  static const Color accent = Color(0xFFD8A94D); // Gold

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color paperDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color lineDark = Color(0xFF333333);

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFE9E4DC);
  static const Color paperLight = Color(0xFFF6F1E9);
  static const Color paperLight2 = Color(0xFFFBF8F3);
  static const Color textPrimaryLight = Color(0xFF1F1F1D);
  static const Color textSecondaryLight = Color(0xFF7D786F);
  static const Color lineLight = Color(0x1F2F2C27); // rgba(47, 44, 39, .12)

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: accent,
      fontFamily: GoogleFonts.inter().fontFamily,
      dividerColor: lineDark,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lora(color: textPrimaryDark, fontSize: 42, fontWeight: FontWeight.w400, height: 1.1),
        bodyLarge: GoogleFonts.inter(color: textPrimaryDark, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textSecondaryDark, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textPrimaryDark,
          foregroundColor: backgroundDark,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: paperLight,
      primaryColor: accent,
      fontFamily: GoogleFonts.inter().fontFamily,
      dividerColor: lineLight,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lora(color: textPrimaryLight, fontSize: 42, fontWeight: FontWeight.w400, height: 1.1),
        bodyLarge: GoogleFonts.inter(color: textPrimaryLight, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textSecondaryLight, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF222220), // Dark button
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

