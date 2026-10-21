import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import 'feature_detail_screens.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final locale = state.locale;
    final ext = Theme.of(context).extension<OneThemeExtension>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.get(locale, 'premium_title')),
        centerTitle: true,
        toolbarHeight: 48,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hero section with readable typography
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    Text('✦', style: TextStyle(fontSize: 36, color: ext.gold, height: 1)),
                    const SizedBox(height: 8),
                    Text(
                      Strings.get(locale, 'premium_title'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        color: ext.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.isPremium
                          ? Strings.get(locale, 'premium_active_status')
                          : Strings.get(locale, 'premium_offer_text'),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: ext.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              // 4 Feature Rows with navigation to detail preview screens
              Column(
                children: [
                  _buildFeatureRow(
                    icon: '◷',
                    title: Strings.get(locale, 'premium_feat_1_title'),
                    sub: Strings.get(locale, 'premium_feat_1_sub'),
                    ext: ext,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReminderFeatureScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureRow(
                    icon: '◉',
                    title: Strings.get(locale, 'premium_feat_2_title'),
                    sub: Strings.get(locale, 'premium_feat_2_sub'),
                    ext: ext,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ThemesFeatureScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureRow(
                    icon: '▣',
                    title: Strings.get(locale, 'premium_feat_3_title'),
                    sub: Strings.get(locale, 'premium_feat_3_sub'),
                    ext: ext,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ArchiveFeatureScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureRow(
                    icon: '⌗',
                    title: Strings.get(locale, 'premium_feat_4_title'),
                    sub: Strings.get(locale, 'premium_feat_4_sub'),
                    ext: ext,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WidgetsFeatureScreen()),
                      );
                    },
                  ),
                ],
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                decoration: BoxDecoration(
                  color: ext.card.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: ext.gold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  Strings.get(locale, 'premium_free_label'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ext.ink),
                ),
              ),

              // Бесплатная активация
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: state.isPremium || state.isActivatingPremium
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final success = await state.activateFreePremium();
                            if (!mounted) return;
                            if (success) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(Strings.get(locale, 'premium_activated'))),
                              );
                            } else {
                              messenger.showSnackBar(
                                SnackBar(content: Text(Strings.get(locale, state.premiumStorageError ?? 'premium_write_failed'))),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      state.isPremium
                          ? Strings.get(locale, 'premium_active_status')
                          : Strings.get(locale, 'activate_free'),
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (state.premiumStorageError != null && !state.isPremium)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        Strings.get(locale, state.premiumStorageError!),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: ext.muted),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required String icon,
    required String title,
    required String sub,
    required OneThemeExtension ext,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: ext.card.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF352F28).withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C241B).withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(icon, style: TextStyle(fontSize: 19, color: ext.ink)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: ext.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: ext.muted,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('✓', style: TextStyle(fontSize: 13, color: ext.gold, fontWeight: FontWeight.bold)),
                const SizedBox(width: 3),
                Text('›', style: TextStyle(fontSize: 14, color: ext.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
