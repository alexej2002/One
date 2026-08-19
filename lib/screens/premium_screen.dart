import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String selectedPlan = 'yearly';

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppState>().locale;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Topbar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28.0, 0, 28.0, 16.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: constraints.maxWidth - 56,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title
                            Text(
                              Strings.get(locale, 'premium_title'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                fontSize: 32,
                                height: 1.1,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Subtitle
                            Text(
                              Strings.get(locale, 'premium_subtitle'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Features
                            Divider(color: Theme.of(context).dividerColor),
                            _buildFeature(
                              Icons.access_time,
                              Strings.get(locale, 'feature_1_title'),
                              Strings.get(locale, 'feature_1_desc'),
                              context,
                            ),
                            _buildFeature(
                              Icons.palette_outlined,
                              Strings.get(locale, 'feature_2_title'),
                              Strings.get(locale, 'feature_2_desc'),
                              context,
                            ),
                            _buildFeature(
                              Icons.inventory_2_outlined,
                              Strings.get(locale, 'feature_3_title'),
                              Strings.get(locale, 'feature_3_desc'),
                              context,
                            ),
                            _buildFeature(
                              Icons.widgets_outlined,
                              Strings.get(locale, 'feature_4_title'),
                              Strings.get(locale, 'feature_4_desc'),
                              context,
                            ),

                            const SizedBox(height: 18),

                            // Plans
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPlan(
                                    'monthly',
                                    Strings.get(locale, 'monthly'),
                                    '\$2.99',
                                    Strings.get(locale, 'per_month'),
                                    context,
                                    locale,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildPlan(
                                    'yearly',
                                    Strings.get(locale, 'yearly'),
                                    '\$14.99',
                                    Strings.get(locale, 'per_year'),
                                    context,
                                    locale,
                                    isBestValue: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildPlan(
                                    'lifetime',
                                    Strings.get(locale, 'lifetime'),
                                    '\$24.99',
                                    Strings.get(locale, 'one_time'),
                                    context,
                                    locale,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Continue Button
                            ElevatedButton(
                              onPressed: () async {
                                final state = context.read<AppState>();
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
                                }
                              },
                              child: Text(Strings.get(locale, 'continue_btn')),
                            ),

                            // Restore
                            TextButton(
                              onPressed: () async {
                                final state = context.read<AppState>();
                                final success = await state.restorePurchases();
                                if (success && mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                Strings.get(locale, 'restore'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(
    IconData icon,
    String title,
    String subtitle,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlan(
    String id,
    String label,
    String price,
    String note,
    BuildContext context,
    String locale, {
    bool isBestValue = false,
  }) {
    final isActive = selectedPlan == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = id;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(fontSize: 10, letterSpacing: 0.6),
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                if (isBestValue)
                  const SizedBox(height: 10), // spacing for badge
              ],
            ),
          ),
          if (isBestValue)
            Positioned(
              bottom: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    Strings.get(locale, 'best_value'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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
