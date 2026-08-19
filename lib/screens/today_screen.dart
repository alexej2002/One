import 'dart:ui';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final quote = state.currentQuote;
    final locale = state.locale;
    final ext = Theme.of(context).extension<OneThemeExtension>()!;
    final isFav = quote != null && state.isFavorite(quote);
    
    final today = DateTime.now();
    final dateString = DateFormat.MMMMd(locale).format(today).toUpperCase();

    // Scale text
    double baseSize = 34;
    if (state.textSize == 'small') baseSize = 30;
    if (state.textSize == 'large') baseSize = 40;

    return Scaffold(
      backgroundColor: ext.bg,
      body: Stack(
        children: [
          // Dynamic themed background
          ..._buildThemedBackground(state.themeName),

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
                            color: Colors.white,
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
                              color: const Color(0x14141414), // rgba(20,20,20,.08)
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: const Center(
                                  child: Text(
                                    '•••',
                                    style: TextStyle(
                                      color: Colors.white,
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
                            color: state.themeName == 'sepia'
                                ? const Color(0xFF776A59)
                                : const Color(0xFF625B53).withValues(alpha: 0.9),
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 28,
                          height: 1,
                          color: state.themeName == 'dark' || state.themeName == 'aurora'
                              ? Colors.white.withValues(alpha: 0.3)
                              : const Color(0xFF1B1916).withValues(alpha: 0.46),
                        ),
                        const SizedBox(height: 34),
                        Text(
                          '“',
                          style: GoogleFonts.lora(
                            fontSize: 44,
                            height: 0.7,
                            color: state.themeName == 'dark' || state.themeName == 'aurora'
                                ? Colors.white.withValues(alpha: 0.6)
                                : const Color(0xFF2C2823).withValues(alpha: 0.42),
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
                              color: state.themeName == 'sepia'
                                  ? const Color(0xFF2B251E)
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Container(
                            width: 28,
                            height: 1,
                            color: state.themeName == 'dark' || state.themeName == 'aurora'
                                ? Colors.white.withValues(alpha: 0.3)
                                : const Color(0xFF1B1916).withValues(alpha: 0.42),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: state.themeName == 'sepia'
                                  ? const Color(0xFF5A432F).withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              quote.author,
                              style: TextStyle(
                                fontSize: 14,
                                color: state.themeName == 'sepia'
                                    ? const Color(0xFF4A3B2C)
                                    : Colors.white,
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
                        iconColor: isFav ? ext.gold : Colors.white,
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildThemedBackground(String themeName) {
    if (themeName == 'dark') {
      return [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF262622),
                  Color(0xFF1B1B18),
                  Color(0xFF12120F),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.44, 0.24),
                radius: 0.6,
                colors: [
                  Color(0x28EADCC1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ];
    }

    if (themeName == 'sepia') {
      return [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5EAD9),
                  Color(0xFFE8D5B7),
                  Color(0xFFDCC4A0),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.44, 0.24),
                radius: 0.5,
                colors: [
                  Color(0x55FFCA7B),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ];
    }

    if (themeName == 'aurora') {
      return [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4B6373),
                  Color(0xFF7D6B4E),
                  Color(0xFF2B3830),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.44, 0.24),
                radius: 0.55,
                colors: [
                  Color(0x66D4B98C),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ];
    }

    // Default Paper theme
    return [
      Positioned.fill(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x738096a6),
                Color(0x2Eeedfc4),
                Color(0xD1151919),
              ],
              stops: [0.0, 0.48, 1.0],
            ),
          ),
        ),
      ),
      Positioned.fill(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.44, 0.24),
              radius: 0.5,
              colors: [
                Color(0x8Fffc067),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
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
              color: const Color(0x14141414), // rgba(20,20,20,.08)
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.36),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                    color: iconColor ?? Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
