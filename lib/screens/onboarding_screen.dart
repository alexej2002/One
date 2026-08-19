import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppState>().locale;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34.0, vertical: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Brand
              Text(
                'ONE',
                style: GoogleFonts.lora(
                  fontSize: 22,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              // Title
              Text(
                Strings.get(locale, 'onboarding_title'),
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 42,
                  height: 1.1,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),
              // Hairline
              Container(
                width: 1,
                height: 48,
                color: Theme.of(context).dividerColor,
              ),
              const SizedBox(height: 30),
              // Copy
              Text(
                Strings.get(locale, 'onboarding_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const Spacer(),
              // Button
              ElevatedButton(
                onPressed: () {
                  context.read<AppState>().completeOnboarding();
                },
                child: Text(Strings.get(locale, 'get_started')),
              ),
              const SizedBox(height: 16),
              // Microcopy
              Text(
                Strings.get(locale, 'takes_minute'),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
