import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../l10n/legal_content.dart';

class AboutScreen extends StatelessWidget {
  final String locale;

  const AboutScreen({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<OneThemeExtension>()!;
    final data = LegalContent.getAboutOne(locale);

    final title = data['title'] as String? ?? 'About ONE';
    final subtitle = data['subtitle'] as String? ?? '';
    final p1 = data['p1'] as String? ?? '';
    final p2 = data['p2'] as String? ?? '';
    final footer = data['footer'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ONE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.5,
                  color: ext.gold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                  color: ext.ink,
                ),
              ),
              const SizedBox(height: 20),

              // Intro paragraph with first-line indent (красная строка)
              if (p1.isNotEmpty) ...[
                Text(
                  '\u2003\u2003$p1',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.65,
                    color: ext.ink.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Card (same style as in Terms of Use)
              if (p2.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: ext.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ext.line),
                  ),
                  child: Text(
                    p2,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.65,
                      color: ext.ink.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // Footer
              if (footer.isNotEmpty) ...[
                Text(
                  footer,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: ext.ink.withValues(alpha: 0.85),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}