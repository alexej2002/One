import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OneThemeExtension extends ThemeExtension<OneThemeExtension> {
  final Color bg;
  final Color bg2;
  final Color card;
  final Color ink;
  final Color muted;
  final Color line;
  final Color gold;
  final Color gold2;

  const OneThemeExtension({
    required this.bg,
    required this.bg2,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.gold,
    required this.gold2,
  });

  @override
  OneThemeExtension copyWith({
    Color? bg,
    Color? bg2,
    Color? card,
    Color? ink,
    Color? muted,
    Color? line,
    Color? gold,
    Color? gold2,
  }) {
    return OneThemeExtension(
      bg: bg ?? this.bg,
      bg2: bg2 ?? this.bg2,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      gold: gold ?? this.gold,
      gold2: gold2 ?? this.gold2,
    );
  }

  @override
  OneThemeExtension lerp(ThemeExtension<OneThemeExtension>? other, double t) {
    if (other is! OneThemeExtension) {
      return this;
    }
    return OneThemeExtension(
      bg: Color.lerp(bg, other.bg, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      gold2: Color.lerp(gold2, other.gold2, t)!,
    );
  }
}

class AppTheme {
  static const Color goldAccent = Color(0xFFb88f4d);

  static ThemeData getTheme(String themeName) {
    switch (themeName) {
      case 'sepia':
        return _buildTheme(
          brightness: Brightness.light,
          bg: const Color(0xFFefe3cf),
          bg2: const Color(0xFFf5ead9),
          card: const Color(0xFFf8eddc),
          ink: const Color(0xFF2b251e),
          muted: const Color(0xFF776a59),
          line: const Color(0x1F4c3e2f),
          gold2: const Color(0xFFe0ca9d),
        );
      case 'dark':
        return _buildTheme(
          brightness: Brightness.dark,
          bg: const Color(0xFF191916),
          bg2: const Color(0xFF20201c),
          card: const Color(0xFF25241f),
          ink: const Color(0xFFf5efe7),
          muted: const Color(0xFFaaa39a),
          line: const Color(0x1CFFFFFF),
          gold2: const Color(0xFF3a3224),
        );
      case 'paper':
      default:
        return _buildTheme(
          brightness: Brightness.light,
          bg: const Color(0xFFf7f2ea),
          bg2: const Color(0xFFfbf8f3),
          card: const Color(0xFFfffaf3),
          ink: const Color(0xFF191816),
          muted: const Color(0xFF766f66),
          line: const Color(0x1E352f28), // rgba(53,47,40,.12) -> ~12% alpha
          gold2: const Color(0xFFeadcc1),
        );
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color bg2,
    required Color card,
    required Color ink,
    required Color muted,
    required Color line,
    required Color gold2,
  }) {
    final ext = OneThemeExtension(
      bg: bg,
      bg2: bg2,
      card: card,
      ink: ink,
      muted: muted,
      line: line,
      gold: goldAccent,
      gold2: gold2,
    );

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg2,
      primaryColor: goldAccent,
      fontFamily: GoogleFonts.inter().fontFamily,
      dividerColor: line,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        titleTextStyle: GoogleFonts.inter(
          color: ink, 
          fontSize: 18, 
          fontWeight: FontWeight.w600
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.inter(color: ink, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: muted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: bg2,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      extensions: [ext],
    );
  }
}
