import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../l10n/strings.dart';
import '../widgets/nav_sheet.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  String _getBackgroundImage(String themeName) {
    switch (themeName) {
      case 'sepia':
        return 'assets/backgrounds/sepia.png';
      case 'dark':
      case 'midnight':
        return 'assets/backgrounds/midnight.png';
      case 'aurora':
        return 'assets/backgrounds/aurora.png';
      case 'paper':
      default:
        return 'assets/backgrounds/paper.png';
    }
  }

  bool _isDarkTheme(String themeName) {
    return themeName == 'dark' || themeName == 'midnight' || themeName == 'aurora';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final quote = state.currentQuote;
    final locale = state.locale;
    final ext = Theme.of(context).extension<OneThemeExtension>()!;
    final isFav = quote != null && state.isFavorite(quote);
    final isDark = _isDarkTheme(state.themeName);
    
    final today = DateTime.now();
    final dateString = DateFormat.MMMMd(locale).format(today).toUpperCase();

    // Scale text
    double baseSize = 34;
    if (state.textSize == 'small') baseSize = 30;
    if (state.textSize == 'large') baseSize = 40;

    // Theme adaptive colors for typography on the image
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1A1815);
    final secondaryTextColor = isDark ? Colors.white.withValues(alpha: 0.75) : const Color(0xFF6B6256);
    final hairlineColor = isDark ? Colors.white.withValues(alpha: 0.28) : const Color(0xFF1A1815).withValues(alpha: 0.22);
    final quoteMarkColor = isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF4A4033).withValues(alpha: 0.35);
    final authorBgColor = isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF1A1815).withValues(alpha: 0.07);

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: ext.bg,
        body: Stack(
        children: [
          // Theme background image
          Positioned.fill(
            child: Image.asset(
              _getBackgroundImage(state.themeName),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Subtle protective gradient overlay for perfect readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isDark ? Colors.black : Colors.white).withValues(alpha: 0.08),
                    Colors.transparent,
                    (isDark ? Colors.black : Colors.white).withValues(alpha: 0.12),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Topbar with centered ONE and right navigation button
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 15.0, bottom: 10.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          'ONE',
                          style: GoogleFonts.lora(
                            fontSize: 23,
                            letterSpacing: 8,
                            color: primaryTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => showNavigationSheet(context),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0x14141414)
                                  : Colors.white.withValues(alpha: 0.45),
                              border: Border.all(
                                color: hairlineColor,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Center(
                                  child: Text(
                                    '•••',
                                    style: TextStyle(
                                      color: primaryTextColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 34.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dateString,
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 28,
                          height: 1,
                          color: hairlineColor,
                        ),
                        const SizedBox(height: 34),
                        Text(
                          '“',
                          style: GoogleFonts.lora(
                            fontSize: 44,
                            height: 0.7,
                            color: quoteMarkColor,
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (quote != null) ...[
                          Text(
                            quote.text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lora(
                              fontSize: baseSize,
                              height: 1.2,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.5,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Container(
                            width: 28,
                            height: 1,
                            color: hairlineColor,
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: authorBgColor,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: hairlineColor,
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              quote.author,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: primaryTextColor.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ] else ...[
                          const CircularProgressIndicator(),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Bottom Actions: Favorite and Share
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, left: 48.0, right: 48.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: isFav ? Icons.favorite : Icons.favorite_border,
                        label: Strings.get(locale, 'save'),
                        onTap: () {
                          if (quote != null) {
                            state.toggleFavorite(quote);
                          }
                        },
                        iconColor: isFav ? ext.gold : primaryTextColor,
                        textColor: primaryTextColor,
                        hairlineColor: hairlineColor,
                        isDark: isDark,
                      ),
                      _buildActionButton(
                        icon: Icons.ios_share,
                        label: Strings.get(locale, 'share'),
                        onTap: () {
                          if (quote != null) {
                            final textToShare = '“${quote.text}”\n\n— ${quote.author}\n\nVia ONE app';
                            Share.share(textToShare);
                          }
                        },
                        iconColor: primaryTextColor,
                        textColor: primaryTextColor,
                        hairlineColor: hairlineColor,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    required Color textColor,
    required Color hairlineColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.black.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.55),
              border: Border.all(
                color: hairlineColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Center(
                  child: Icon(
                    icon,
                    size: 24,
                    color: iconColor ?? textColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
