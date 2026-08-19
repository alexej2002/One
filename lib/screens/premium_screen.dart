import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';

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
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header with larger typography
              Column(
                children: [
                  Text('✦', style: TextStyle(fontSize: 32, color: ext.gold)),
                  const SizedBox(height: 6),
                  Text(
                    Strings.get(locale, 'premium_heading'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: ext.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
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
                  ),
                ],
              ),

              // 4 Features in a compact card with larger fonts
              Container(
                decoration: BoxDecoration(
                  color: ext.card.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF352F28).withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2C241B).withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      icon: '◷',
                      title: Strings.get(locale, 'premium_feat_1_title'),
                      subtitle: Strings.get(locale, 'premium_feat_1_sub'),
                      ext: ext,
                      showDivider: true,
                    ),
                    _buildFeatureItem(
                      icon: '◉',
                      title: Strings.get(locale, 'premium_feat_2_title'),
                      subtitle: Strings.get(locale, 'premium_feat_2_sub'),
                      ext: ext,
                      showDivider: true,
                    ),
                    _buildFeatureItem(
                      icon: '▣',
                      title: Strings.get(locale, 'premium_feat_3_title'),
                      subtitle: Strings.get(locale, 'premium_feat_3_sub'),
                      ext: ext,
                      showDivider: true,
                    ),
                    _buildFeatureItem(
                      icon: '⌗',
                      title: Strings.get(locale, 'premium_feat_4_title'),
                      subtitle: Strings.get(locale, 'premium_feat_4_sub'),
                      ext: ext,
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              // Full-width spacious Subscription Plan Rows (never squished, balanced & centered)
              Column(
                children: [
                  _buildPlanRow(
                    id: 'yearly',
                    label: Strings.get(locale, 'yearly'),
                    price: yearlyPrice,
                    period: Strings.get(locale, 'per_year'),
                    ext: ext,
                    isBestValue: true,
                    bestValueText: Strings.get(locale, 'best_value'),
                  ),
                  const SizedBox(height: 8),
                  _buildPlanRow(
                    id: 'monthly',
                    label: Strings.get(locale, 'monthly'),
                    price: monthlyPrice,
                    period: Strings.get(locale, 'per_month'),
                    ext: ext,
                  ),
                  const SizedBox(height: 8),
                  _buildPlanRow(
                    id: 'lifetime',
                    label: Strings.get(locale, 'lifetime'),
                    price: lifetimePrice,
                    period: Strings.get(locale, 'one_time'),
                    ext: ext,
                  ),
                ],
              ),

              // Action buttons
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
                  const SizedBox(height: 2),
                  TextButton(
                    onPressed: () async {
                      final success = await state.restorePurchases();
                      if (success && mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      Strings.get(locale, 'restore'),
                      style: TextStyle(fontSize: 13, color: ext.muted),
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

  Widget _buildFeatureItem({
    required String icon,
    required String title,
    required String subtitle,
    required OneThemeExtension ext,
    required bool showDivider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: ext.line, width: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 18, color: ext.gold)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: ext.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: ext.muted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check, size: 18, color: ext.gold),
        ],
      ),
    );
  }

  Widget _buildPlanRow({
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
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? ext.card : ext.card.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? ext.gold : const Color(0xFF352F28).withValues(alpha: 0.09),
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C241B).withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    ext.gold2.withValues(alpha: 0.45),
                    ext.card,
                  ],
                )
              : null,
        ),
        child: Row(
          children: [
            // Custom radio circle
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? ext.gold : ext.muted,
                  width: 1.5,
                ),
              ),
              child: isActive
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ext.gold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Plan Title
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: ext.ink,
              ),
            ),

            // Best value badge if present
            if (isBestValue && bestValueText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: ext.gold,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  bestValueText,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Price and Period
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ext.ink,
                    ),
                  ),
                  TextSpan(
                    text: ' / $period',
                    style: TextStyle(
                      fontSize: 12,
                      color: ext.muted,
                      fontWeight: FontWeight.normal,
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
}
