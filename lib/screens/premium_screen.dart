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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Column(
                children: [
                  Text('✦', style: TextStyle(fontSize: 32, color: ext.gold)),
                  const SizedBox(height: 6),
                  Text(
                    Strings.get(locale, 'premium_heading'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 23,
                      fontWeight: FontWeight.w400,
                      color: ext.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      Strings.get(locale, 'premium_desc'),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: ext.muted,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),

              // 4 Features in a compact card
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
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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

              // Subscription plans (3 horizontal cards)
              Row(
                children: [
                  Expanded(
                    child: _buildPlanCard(
                      id: 'monthly',
                      label: Strings.get(locale, 'monthly'),
                      price: monthlyPrice,
                      period: Strings.get(locale, 'per_month'),
                      ext: ext,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPlanCard(
                      id: 'yearly',
                      label: Strings.get(locale, 'yearly'),
                      price: yearlyPrice,
                      period: Strings.get(locale, 'per_year'),
                      ext: ext,
                      isBestValue: true,
                      bestValueText: Strings.get(locale, 'best_value'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPlanCard(
                      id: 'lifetime',
                      label: Strings.get(locale, 'lifetime'),
                      price: lifetimePrice,
                      period: Strings.get(locale, 'one_time'),
                      ext: ext,
                    ),
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
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      Strings.get(locale, 'continue_btn'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
                      style: TextStyle(fontSize: 11.5, color: ext.muted),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: ext.line, width: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 17, color: ext.gold)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: ext.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: ext.muted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check, size: 16, color: ext.gold),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? ext.card : ext.card.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? ext.gold : const Color(0xFF352F28).withValues(alpha: 0.09),
                width: isActive ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2C241B).withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                )
              ],
              gradient: isActive
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ext.gold2.withValues(alpha: 0.52),
                        ext.card,
                      ],
                    )
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ext.ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ext.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  period,
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
              top: -8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ext.gold,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    bestValueText,
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
