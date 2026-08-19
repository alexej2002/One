import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../l10n/strings.dart';
import 'settings_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final quote = state.currentQuote;
    final locale = state.locale;
    final today = DateTime.now();
    final dateString = DateFormat.MMMMEEEEd(locale).format(today);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient (Dark version of the prototype's hero-bg)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? const [Color(0xFF1E2124), Color(0xFF121212)]
                      : const [Color(0xFFE9E4DC), Color(0xFFF6F1E9)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Topbar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                      Text(
                        'ONE',
                        style: GoogleFonts.lora(
                          fontSize: 20,
                          letterSpacing: 6,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          quote != null && state.isFavorite(quote) ? Icons.favorite : Icons.favorite_border,
                          color: quote != null && state.isFavorite(quote) ? Colors.redAccent : null,
                        ),
                        onPressed: () {
                          if (quote != null) {
                            state.toggleFavorite(quote);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dateString,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 24,
                          height: 1,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          '“',
                          style: GoogleFonts.lora(
                            fontSize: 64,
                            height: 0.5,
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (quote != null) ...[
                          Text(
                            quote.text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lora(
                              fontSize: 32,
                              height: 1.3,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            width: 24,
                            height: 1,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            quote.author,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ] else ...[
                          const CircularProgressIndicator(),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Bottom Actions
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, left: 24.0, right: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context, 
                        quote != null && state.isFavorite(quote) ? Icons.favorite : Icons.favorite_border, 
                        Strings.get(locale, 'save'), 
                        () {
                          if (quote != null) {
                            state.toggleFavorite(quote);
                          }
                        },
                        iconColor: quote != null && state.isFavorite(quote) ? Colors.redAccent : null,
                      ),
                      _buildActionButton(context, Icons.ios_share, Strings.get(locale, 'share'), () {
                        if (quote != null) {
                          final textToShare = '“${quote.text}”\n\n— ${quote.author}\n\nVia ONE app';
                          Share.share(textToShare);
                        }
                      }),
                      _buildActionButton(context, Icons.more_horiz, Strings.get(locale, 'more'), () {
                        // TODO: More
                      }),
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

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? iconColor}) {
    final color = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.05),
              border: Border.all(
                color: color.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(icon, color: iconColor ?? color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
