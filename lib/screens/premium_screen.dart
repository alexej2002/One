import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
  String selectedPlan = 'yearly';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final locale = state.locale;
    final ext = Theme.of(context).extension<OneThemeExtension>()!;

    // Fallback prices
    String monthlyPrice = '\$2.99';
    String yearlyPrice = '\$14.99';
    String lifetimePrice = '\$24.99';

    if (state.offerings != null && state.offerings!.current != null) {
      if (state.offerings!.current!.monthly != null) {
        monthlyPrice = state.offerings!.current!.monthly!.storeProduct.priceString;
      }
      if (state.offerings!.current!.annual != null) {
        yearlyPrice = state.offerings!.current!.annual!.storeProduct.priceString;
      }
      if (state.offerings!.current!.lifetime != null) {
        lifetimePrice = state.offerings!.current!.lifetime!.storeProduct.priceString;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ONE+'),
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
                      Strings.get(locale, 'premium_heading'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        color: ext.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Strings.get(locale, 'premium_desc'),
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

              // 3 Subscription Plans with equal width
              Row(
                children: [
                  Expanded(
                    child: _buildPlanTile(
                      id: 'monthly',
                      label: Strings.get(locale, 'monthly'),
                      price: monthlyPrice,
                      period: Strings.get(locale, 'per_month'),
                      ext: ext,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPlanTile(
                      id: 'yearly',
                      label: Strings.get(locale, 'yearly'),
                      price: yearlyPrice,
                      period: Strings.get(locale, 'per_year'),
                      ext: ext,
                      isBestValue: true,
                      bestValueText: Strings.get(locale, 'best_value'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPlanTile(
                      id: 'lifetime',
                      label: Strings.get(locale, 'lifetime'),
                      price: lifetimePrice,
                      period: Strings.get(locale, 'one_time'),
                      ext: ext,
                    ),
                  ),
                ],
              ),

              // CTA Button & Restore Link
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final offerings = state.offerings;
                      if (offerings != null && offerings.current != null) {
                        Package? packageToBuy;
                        if (selectedPlan == 'monthly') {
                          packageToBuy = offerings.current!.monthly;
                        } else if (selectedPlan == 'yearly') {
                          packageToBuy = offerings.current!.annual;
                        } else if (selectedPlan == 'lifetime') {
                          packageToBuy = offerings.current!.lifetime;
                        }

                        if (packageToBuy != null) {
                          final success = await state.purchasePackage(packageToBuy);
                          if (success && mounted) {
                            Navigator.pop(context);
                          }
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('RevenueCat is not configured or no packages available.'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      Strings.get(locale, 'continue_btn'),
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () async {
                      final success = await state.restorePurchases();
                      if (success && mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 26),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      Strings.get(locale, 'restore'),
                      style: TextStyle(fontSize: 12.5, color: ext.muted),
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

  Widget _buildPlanTile({
    required String id,
    required String label,
    required String price,
    required String period,
    required OneThemeExtension ext,
    bool isBestValue = false,
    String? bestValueText,
  }) {
    final isActive = selectedPlan == id;

    return GestureDetector(
      onTap: () => setState(() => selectedPlan = id),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 74),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              color: isActive ? null : ext.card.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isActive ? ext.gold : const Color(0xFF352F28).withValues(alpha: 0.09),
                width: isActive ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2C241B).withValues(alpha: isActive ? 0.06 : 0.025),
                  blurRadius: isActive ? 12 : 6,
                  offset: const Offset(0, 3),
                )
              ],
              gradient: isActive
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.lerp(ext.gold2, ext.card, 0.48)!,
                        ext.card,
                      ],
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ext.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  price,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ext.ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  period,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: ext.muted,
                  ),
                ),
              ],
            ),
          ),
          if (isBestValue && bestValueText != null)
            Positioned(
              top: -9,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ext.gold,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Text(
                    bestValueText,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
