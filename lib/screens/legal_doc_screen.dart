import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class LegalDocScreen extends StatelessWidget {
  final Map<String, dynamic> docData;

  const LegalDocScreen({super.key, required this.docData});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<OneThemeExtension>()!;
    final title = docData['title'] as String? ?? '';
    final effectiveDate = docData['effective_date'] as String? ?? '';
    final intro = docData['intro'] as String? ?? '';
    final summaryTitle = docData['summary_title'] as String? ?? '';
    final summaryBody = docData['summary_body'] as String? ?? '';
    final sections = (docData['sections'] as List<dynamic>?) ?? [];

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
              if (effectiveDate.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  effectiveDate,
                  style: TextStyle(fontSize: 13, color: ext.muted),
                ),
              ],
              const SizedBox(height: 20),
              if (intro.isNotEmpty) ...[
                Text(
                  intro,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.65,
                    color: ext.ink.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              if (summaryBody.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: ext.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ext.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (summaryTitle.isNotEmpty) ...[
                        Text(
                          summaryTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ext.gold,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        summaryBody,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: ext.ink.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
              ],
              ...sections.map((sec) {
                final secMap = sec as Map<String, dynamic>;
                final secTitle = secMap['title'] as String? ?? '';
                final secBody = secMap['body'] as String? ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        secTitle,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ext.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        secBody,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.65,
                          color: ext.ink.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
