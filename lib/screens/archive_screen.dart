import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../models/quote.dart';
import '../widgets/nav_sheet.dart';
import '../widgets/contextual_paywall.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

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
        leading: const SizedBox(width: 40),
        actions: [
          IconButton(
            icon: const Text('•••', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            onPressed: () => showNavigationSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: archive.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  Strings.get(locale, 'archive_empty'),
                  style: TextStyle(color: ext.muted, height: 1.7),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: archive.length,
              itemBuilder: (context, index) {
                final item = archive[index];
                final DateTime date = item['date'];
                final Quote quote = item['quote'];
                final isFav = state.isFavorite(quote);
                final isLocked = !state.isPremium && index >= 7;

                final cardContent = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: ext.line, width: 1),
                      top: index == 0 ? BorderSide(color: ext.line, width: 1) : BorderSide.none,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat.MMMMd(locale).format(date).toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              color: ext.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isLocked) ...[
                            const SizedBox(width: 6),
                            const Text('🔒', style: TextStyle(fontSize: 10)),
                          ],
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13, bottom: 12),
                        child: Text(
                          '“${quote.text}”',
                          style: GoogleFonts.lora(
                            fontSize: 24,
                            height: 1.4,
                            color: ext.ink,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            quote.author,
                            style: TextStyle(fontSize: 12, color: ext.muted),
                          ),
                          if (!isLocked)
                            GestureDetector(
                              onTap: () => state.toggleFavorite(quote),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? ext.gold : ext.muted,
                                  size: 20,
                                ),
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
              },
            ),
    );
  }
}
