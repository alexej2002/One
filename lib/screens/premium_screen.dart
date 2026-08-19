import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 26.0),
            child: Column(
              children: [
                Text('✦', style: TextStyle(fontSize: 45, color: ext.gold)),
                const SizedBox(height: 14),
                Text(
                  Strings.get(locale, 'premium_heading'),
                  style: const TextStyle(fontFamily: 'Georgia', fontSize: 31, letterSpacing: 0.12),
                ),
                const SizedBox(height: 22),
                Text(
                  Strings.get(locale, 'premium_desc'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: ext.muted, height: 1.7),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: RadialGradient(
                center: const Alignment(0.76, -0.8),
                radius: 1.2,
                colors: [ext.gold.withValues(alpha: 0.1), Colors.transparent],
                stops: const [0.0, 0.24],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ext.gold2, ext.card],
                ),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF372B1B).withValues(alpha: 0.06), blurRadius: 26, offset: const Offset(0, 12))
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Strings.get(locale, 'premium_exp'), style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: ext.muted)),
                  const SizedBox(height: 10),
                  Text(Strings.get(locale, 'premium_banner_title'), style: TextStyle(fontFamily: 'Georgia', fontSize: 28, height: 1.2, color: ext.ink)),
                  const SizedBox(height: 10),
                  Text(Strings.get(locale, 'premium_banner_desc'), style: TextStyle(fontSize: 12, color: ext.muted, height: 1.45)),
                ],
              ),
            ),
          ),

          _buildFeaturesCard(ext, locale),

          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(child: _buildPlan('monthly', Strings.get(locale, 'monthly'), monthlyPrice, Strings.get(locale, 'per_month'), ext)),
              const SizedBox(width: 10),
              Expanded(child: _buildPlan('yearly', Strings.get(locale, 'yearly'), yearlyPrice, Strings.get(locale, 'per_year'), ext)),
              const SizedBox(width: 10),
              Expanded(child: _buildPlan('lifetime', Strings.get(locale, 'lifetime'), lifetimePrice, Strings.get(locale, 'one_time'), ext)),
            ],
          ),

          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () async {
              final offerings = state.offerings;
              if (offerings != null && offerings.current != null) {
                Package? packageToBuy;
                if (selectedPlan == 'monthly') packageToBuy = offerings.current!.monthly;
                else if (selectedPlan == 'yearly') packageToBuy = offerings.current!.annual;
                else if (selectedPlan == 'lifetime') packageToBuy = offerings.current!.lifetime;
                
                if (packageToBuy != null) {
                  final success = await state.purchasePackage(packageToBuy);
                  if (success && mounted) Navigator.pop(context);
                }
              } else {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RevenueCat is not configured or no packages available.')));
              }
            },
            child: Text(Strings.get(locale, 'continue_btn')),
          ),

          TextButton(
            onPressed: () async {
              final success = await state.restorePurchases();
              if (success && mounted) Navigator.pop(context);
            },
            child: Text(Strings.get(locale, 'restore'), style: TextStyle(fontSize: 12, color: ext.muted)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(OneThemeExtension ext, String locale) {
    return Column(
      children: [
        _buildFeatureRow('◷', Strings.get(locale, 'premium_feat_1_title'), Strings.get(locale, 'premium_feat_1_sub'), ext),
        _buildFeatureRow('◉', Strings.get(locale, 'premium_feat_2_title'), Strings.get(locale, 'premium_feat_2_sub'), ext),
        _buildFeatureRow('▣', Strings.get(locale, 'premium_feat_3_title'), Strings.get(locale, 'premium_feat_3_sub'), ext),
        _buildFeatureRow('⌗', Strings.get(locale, 'premium_feat_4_title'), Strings.get(locale, 'premium_feat_4_sub'), ext),
      ],
    );
  }

  Widget _buildFeatureRow(String icon, String title, String sub, OneThemeExtension ext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: ext.card.withValues(alpha: 0.9),
        border: Border.all(color: const Color(0xFF352F28).withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2C241B).withValues(alpha: 0.035), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 22, color: ext.ink)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: ext.ink)),
                const SizedBox(height: 3),
                Text(sub, style: TextStyle(fontSize: 12, color: ext.muted, height: 1.45)),
              ],
            ),
          ),
          Icon(Icons.check, size: 18, color: ext.ink),
        ],
      ),
    );
  }

  Widget _buildPlan(String id, String label, String price, String note, OneThemeExtension ext) {
    final isActive = selectedPlan == id;
    return GestureDetector(
      onTap: () => setState(() => selectedPlan = id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? ext.card : ext.card.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? ext.gold : const Color(0xFF352F28).withValues(alpha: 0.09)),
          boxShadow: [
            BoxShadow(color: const Color(0xFF2C241B).withValues(alpha: 0.03), blurRadius: 18, offset: const Offset(0, 8))
          ],
          gradient: isActive ? LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ext.gold2.withValues(alpha: 0.52), ext.card]) : null,
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: ext.ink)),
            const SizedBox(height: 8),
            Text(price, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ext.ink)),
            const SizedBox(height: 4),
            Text(note, style: TextStyle(fontSize: 10, color: ext.muted)),
          ],
        ),
      ),
    );
  }
}
