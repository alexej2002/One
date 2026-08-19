import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../screens/premium_screen.dart';

class ContextualPaywallSheet extends StatelessWidget {
  final String title;
  final String description;
  final String? choiceBadge;
  final String unlockLabel;
  final String cancelLabel;
  final VoidCallback? onUnlocked;

  const ContextualPaywallSheet({
    super.key,
    required this.title,
    required this.description,
    this.choiceBadge,
    this.unlockLabel = 'Unlock ONE+',
    this.cancelLabel = 'Not now',
    this.onUnlocked,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    String? choiceBadge,
    String unlockLabel = 'Unlock ONE+',
    String cancelLabel = 'Not now',
    VoidCallback? onUnlocked,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ContextualPaywallSheet(
        title: title,
        description: description,
        choiceBadge: choiceBadge,
        unlockLabel: unlockLabel,
        cancelLabel: cancelLabel,
        onUnlocked: onUnlocked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<OneThemeExtension>()!;

    return Container(
      decoration: BoxDecoration(
        color: ext.bg2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, -10),
          )
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: ext.line,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 22),

          // Gold star
          Text('✦', style: TextStyle(fontSize: 32, color: ext.gold, height: 1)),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: ext.ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: ext.muted,
              height: 1.45,
            ),
          ),

          // Optional choice badge (e.g. "Your choice: 20:00")
          if (choiceBadge != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ext.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ext.gold.withValues(alpha: 0.3)),
              ),
              child: Text(
                choiceBadge!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ext.ink,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Unlock CTA button
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close sheet
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
              onUnlocked?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ext.gold,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              unlockLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(height: 8),

          // Cancel / dismiss button
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              cancelLabel,
              style: TextStyle(
                fontSize: 14,
                color: ext.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
