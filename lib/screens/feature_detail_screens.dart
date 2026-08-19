import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/quote.dart';
import '../theme.dart';
import '../l10n/strings.dart';
import '../widgets/premium_reminder_picker.dart';
import '../widgets/contextual_paywall.dart';

// ==========================================
// 1. REMINDER TIME FEATURE SCREEN
// ==========================================
class ReminderFeatureScreen extends StatelessWidget {
  const ReminderFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final locale = state.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.get(locale, 'reminder_time')),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            PremiumReminderTimePicker(
              onSaved: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Daily ritual reminder saved!')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. THEMES FEATURE SCREEN
// ==========================================
class ThemesFeatureScreen extends StatelessWidget {
  const ThemesFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ext = Theme.of(context).extension<OneThemeExtension>()!;
    final locale = state.locale;

    void selectTheme(String themeId, String themeName) {
      if (themeId == 'paper' || state.isPremium) {
        state.setTheme(themeId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Theme changed to $themeName')),
        );
      } else {
        // Pending action on purchase
        state.setPendingPremiumAction(() {
          state.setTheme(themeId);
        });

        // Soft contextual paywall
        ContextualPaywallSheet.show(
          context,
          title: '$themeName is part of ONE+',
          description: 'Typography and backgrounds change the mood while the product stays quiet.',
          unlockLabel: 'Unlock ONE+',
          cancelLabel: 'Keep Paper',
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.get(locale, 'theme')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Column(
            children: [
              Text('◉', style: TextStyle(fontSize: 42, color: ext.gold)),
              const SizedBox(height: 10),
              Text(
                Strings.get(locale, 'premium_feat_2_title'),
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: ext.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Typography and backgrounds change the mood while the product stays quiet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: ext.muted, height: 1.6),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildThemeCard(
            context,
            ext,
            themeId: 'paper',
            themeName: 'Paper',
            note: 'Warm & minimal (Included free)',
            previewBg: const Color(0xFFF2ECE2),
            textColor: const Color(0xFF222222),
            isActive: state.themeName == 'paper',
            onTap: () => selectTheme('paper', 'Paper'),
          ),
          const SizedBox(height: 16),

          _buildThemeCard(
            context,
            ext,
            themeId: 'sepia',
            themeName: 'Sepia',
            note: 'Editorial warmth · ONE+',
            previewBg: const Color(0xFFE8D5B7),
            textColor: const Color(0xFF2B251E),
            isActive: state.themeName == 'sepia',
            isPremiumLocked: !state.isPremium,
            onTap: () => selectTheme('sepia', 'Sepia'),
          ),
          const SizedBox(height: 16),

          _buildThemeCard(
            context,
            ext,
            themeId: 'dark',
            themeName: 'Midnight',
            note: 'Dark evening theme · ONE+',
            previewBg: const Color(0xFF20201D),
            textColor: const Color(0xFFF3EEE7),
            isActive: state.themeName == 'dark',
            isPremiumLocked: !state.isPremium,
            onTap: () => selectTheme('dark', 'Midnight'),
          ),
          const SizedBox(height: 16),

          _buildThemeCard(
            context,
            ext,
            themeId: 'aurora',
            themeName: 'Aurora',
            note: 'Premium gradient backdrop · ONE+',
            previewGradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7793A8), Color(0xFFD4B98C), Color(0xFF37443D)],
            ),
            textColor: Colors.white,
            isActive: state.themeName == 'aurora',
            isPremiumLocked: !state.isPremium,
            onTap: () => selectTheme('aurora', 'Aurora'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    OneThemeExtension ext, {
    required String themeId,
    required String themeName,
    required String note,
    Color? previewBg,
    Gradient? previewGradient,
    required Color textColor,
    required bool isActive,
    bool isPremiumLocked = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: ext.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? ext.gold : const Color(0xFF352F28).withValues(alpha: 0.09),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A231A).withValues(alpha: 0.07),
              blurRadius: 26,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: previewBg,
                gradient: previewGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              padding: const EdgeInsets.all(22),
              alignment: Alignment.bottomLeft,
              child: Text(
                'One thought.\nEvery day.',
                style: GoogleFonts.lora(
                  fontSize: 26,
                  height: 1.25,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            themeName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: ext.ink,
                            ),
                          ),
                          if (isPremiumLocked) ...[
                            const SizedBox(width: 6),
                            const Text('🔒', style: TextStyle(fontSize: 11)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(note, style: TextStyle(fontSize: 11.5, color: ext.muted)),
                    ],
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ext.gold,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Text(
                      'Use theme ›',
                      style: TextStyle(fontSize: 12.5, color: ext.gold, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. ARCHIVE FEATURE SCREEN
// ==========================================
class ArchiveFeatureScreen extends StatelessWidget {
  const ArchiveFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ext = Theme.of(context).extension<OneThemeExtension>()!;
    final locale = state.locale;
    final archive = state.getArchiveQuotes();

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.get(locale, 'archive')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Column(
            children: [
              Text('▣', style: TextStyle(fontSize: 42, color: ext.gold)),
              const SizedBox(height: 10),
              Text(
                Strings.get(locale, 'premium_feat_3_title'),
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: ext.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Return to thoughts you\'ve already received. No endless feed, only the days that already happened.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: ext.muted, height: 1.6),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Intro banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [ext.gold2, ext.card],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${archive.length} thoughts received',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ext.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  '7 days included on Free · Complete history with ONE+.',
                  style: TextStyle(fontSize: 12, color: ext.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ...archive.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final DateTime date = item['date'];
            final Quote quote = item['quote'];
            final isFav = state.isFavorite(quote);
            final isLocked = !state.isPremium && index >= 7;

            final cardContent = Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ext.line, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat.MMMMd(locale).format(date).toUpperCase(),
                        style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: ext.muted, fontWeight: FontWeight.w600),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 6),
                        const Text('🔒', style: TextStyle(fontSize: 10)),
                      ],
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),
                    child: Text(
                      '“${quote.text}”',
                      style: GoogleFonts.lora(fontSize: 22, height: 1.35, color: ext.ink),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(quote.author, style: TextStyle(fontSize: 12, color: ext.muted)),
                      if (!isLocked)
                        GestureDetector(
                          onTap: () => state.toggleFavorite(quote),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? ext.gold : ext.muted,
                            size: 18,
                          ),
                        )
                      else
                        Text(
                          'ONE+',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: ext.gold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );

            if (isLocked) {
              return GestureDetector(
                onTap: () {
                  ContextualPaywallSheet.show(
                    context,
                    title: 'Keep your full history',
                    description: 'ONE+ keeps every thought you’ve received since the day you started.',
                    unlockLabel: 'Unlock ONE+',
                    cancelLabel: 'Not now',
                  );
                },
                child: Opacity(
                  opacity: 0.52,
                  child: cardContent,
                ),
              );
            }

            return cardContent;
          }),
        ],
      ),
    );
  }
}

// ==========================================
// 4. WIDGETS FEATURE SCREEN
// ==========================================
class WidgetsFeatureScreen extends StatelessWidget {
  const WidgetsFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ext = Theme.of(context).extension<OneThemeExtension>()!;

    void onAddWidget(String widgetName) {
      if (state.isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Widget "$widgetName" added to home screen!')),
        );
      } else {
        ContextualPaywallSheet.show(
          context,
          title: 'Home Screen Widgets · ONE+',
          description: 'Keep today’s thought on your home screen without opening the app.',
          unlockLabel: 'Unlock ONE+',
          cancelLabel: 'Not now',
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widgets'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Column(
            children: [
              Text('⌗', style: TextStyle(fontSize: 42, color: ext.gold)),
              const SizedBox(height: 10),
              Text(
                'Home Screen Widgets',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: ext.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preview how ONE can live quietly on your home screen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: ext.muted, height: 1.6),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildWidgetPreview(
            ext,
            title: 'Small Paper',
            sub: 'Quote + author',
            bgColor: const Color(0xFFEEE8DD),
            textColor: const Color(0xFF1D1C19),
            headerText: 'ONE · TODAY',
            quoteText: 'The secret of getting ahead is getting started.',
            authorText: 'Mark Twain',
            onAdd: () => onAddWidget('Small Paper'),
          ),
          const SizedBox(height: 18),

          _buildWidgetPreview(
            ext,
            title: 'Midnight',
            sub: 'Minimal lock/home screen style',
            bgColor: const Color(0xFF20201D),
            textColor: const Color(0xFFF5EFE6),
            headerText: 'ONE · AUG 19',
            quoteText: 'One thought.\nEvery day.',
            authorText: 'ONE',
            onAdd: () => onAddWidget('Midnight'),
          ),
          const SizedBox(height: 18),

          _buildWidgetPreview(
            ext,
            title: 'Gold',
            sub: 'Premium accent',
            bgColor: const Color(0xFFD5AB5B),
            textColor: const Color(0xFF1C1812),
            headerText: 'ONE',
            quoteText: 'Today\'s thought is waiting.',
            authorText: 'Tap to open',
            onAdd: () => onAddWidget('Gold'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWidgetPreview(
    OneThemeExtension ext, {
    required String title,
    required String sub,
    required Color bgColor,
    required Color textColor,
    required String headerText,
    required String quoteText,
    required String authorText,
    required VoidCallback onAdd,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF352F28).withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262018).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 145,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  headerText,
                  style: TextStyle(
                    fontSize: 9.5,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  quoteText,
                  style: GoogleFonts.lora(
                    fontSize: 19,
                    height: 1.25,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                  ),
                ),
                Text(
                  authorText,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: ext.ink)),
                  const SizedBox(height: 2),
                  Text(sub, style: TextStyle(fontSize: 11, color: ext.muted)),
                ],
              ),
              ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(96, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add widget', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
