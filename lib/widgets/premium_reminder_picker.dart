import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../l10n/strings.dart';
import 'contextual_paywall.dart';

class PremiumReminderTimePicker extends StatefulWidget {
  final VoidCallback? onSaved;
  final bool isModal;

  const PremiumReminderTimePicker({
    super.key,
    this.onSaved,
    this.isModal = false,
  });

  @override
  State<PremiumReminderTimePicker> createState() => _PremiumReminderTimePickerState();
}

class _PremiumReminderTimePickerState extends State<PremiumReminderTimePicker> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _hour = appState.notificationTime.hour;
    _minute = appState.notificationTime.minute;
  }

  void _setMoment(int h, int m) {
    setState(() {
      _hour = h;
      _minute = m;
    });
  }

  void _stepHour(int delta) {
    setState(() {
      _hour = (_hour + delta + 24) % 24;
    });
  }

  void _stepMinute(int delta) {
    setState(() {
      _minute = (_minute + delta + 60) % 60;
    });
  }

  String _getPeriodCaption(String locale) {
    if (_hour < 11) return Strings.get(locale, 'period_morning');
    if (_hour < 17) return Strings.get(locale, 'period_daytime');
    return Strings.get(locale, 'period_evening');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final locale = appState.locale;
    final ext = Theme.of(context).extension<OneThemeExtension>()!;
    final hourStr = _hour.toString().padLeft(2, '0');
    final minuteStr = _minute.toString().padLeft(2, '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Column(
          children: [
            Text('◷', style: TextStyle(fontSize: 38, color: ext.gold, height: 1)),
            const SizedBox(height: 10),
            Text(
              Strings.get(locale, 'reminder_picker_title'),
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 27,
                height: 1.15,
                fontWeight: FontWeight.w400,
                color: ext.ink,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                Strings.get(locale, 'reminder_picker_sub'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: ext.muted,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Glowing Clock Circle
        Container(
          height: 180,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Halo background
              Container(
                width: 164,
                height: 164,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ext.gold.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  gradient: RadialGradient(
                    colors: [
                      ext.gold2.withValues(alpha: 0.55),
                      ext.card.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ext.gold.withValues(alpha: 0.08),
                      blurRadius: 24,
                      spreadRadius: 4,
                    )
                  ],
                ),
              ),

              // Tick marks
              Positioned(
                top: 16,
                child: Container(
                  width: 1.5,
                  height: 8,
                  color: ext.gold.withValues(alpha: 0.55),
                ),
              ),
              Positioned(
                right: 16,
                child: Container(
                  width: 8,
                  height: 1.5,
                  color: ext.gold.withValues(alpha: 0.55),
                ),
              ),
              Positioned(
                bottom: 16,
                child: Container(
                  width: 1.5,
                  height: 8,
                  color: ext.gold.withValues(alpha: 0.55),
                ),
              ),
              Positioned(
                left: 16,
                child: Container(
                  width: 8,
                  height: 1.5,
                  color: ext.gold.withValues(alpha: 0.55),
                ),
              ),

              // Time & Caption
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        hourStr,
                        style: GoogleFonts.lora(
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          color: ext.ink,
                          letterSpacing: -1.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          ':',
                          style: GoogleFonts.lora(
                            fontSize: 44,
                            fontWeight: FontWeight.w300,
                            color: ext.gold,
                          ),
                        ),
                      ),
                      Text(
                        minuteStr,
                        style: GoogleFonts.lora(
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          color: ext.ink,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getPeriodCaption(locale),
                    style: TextStyle(
                      fontSize: 8.5,
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w700,
                      color: ext.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Quick Moments (3 cards)
        Row(
          children: [
            Expanded(
              child: _buildMomentCard(
                ext,
                icon: '☼',
                title: Strings.get(locale, 'moment_morning'),
                timeStr: '08:00',
                isActive: _hour == 8 && _minute == 0,
                onTap: () => _setMoment(8, 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMomentCard(
                ext,
                icon: '◐',
                title: Strings.get(locale, 'moment_lunch'),
                timeStr: '13:00',
                isActive: _hour == 13 && _minute == 0,
                onTap: () => _setMoment(13, 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMomentCard(
                ext,
                icon: '☾',
                title: Strings.get(locale, 'moment_evening'),
                timeStr: '20:00',
                isActive: _hour == 20 && _minute == 0,
                onTap: () => _setMoment(20, 0),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Fine Tune Steppers (Hour & Minute)
        Container(
          padding: const EdgeInsets.only(top: 14),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: ext.line, width: 0.8),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      Strings.get(locale, 'stepper_hour'),
                      style: TextStyle(
                        fontSize: 8.5,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w700,
                        color: ext.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStepper(
                      ext,
                      value: hourStr,
                      onMinus: () => _stepHour(-1),
                      onPlus: () => _stepHour(1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      Strings.get(locale, 'stepper_minute'),
                      style: TextStyle(
                        fontSize: 8.5,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w700,
                        color: ext.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStepper(
                      ext,
                      value: minuteStr,
                      onMinus: () => _stepMinute(-5),
                      onPlus: () => _stepMinute(5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Save Button
        ElevatedButton(
          onPressed: () {
            final chosenTime = TimeOfDay(hour: _hour, minute: _minute);

            if (appState.isPremium) {
              appState.setNotificationTime(chosenTime);
              if (widget.onSaved != null) {
                widget.onSaved!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${Strings.get(locale, 'reminder_saved')} $hourStr:$minuteStr')),
                );
              }
            } else {
              // Store pending action to auto-apply upon purchase
              appState.setPendingPremiumAction(() {
                appState.setNotificationTime(chosenTime);
              });

              // Show contextual paywall sheet
              ContextualPaywallSheet.show(
                context,
                title: 'ONE+',
                description: Strings.get(locale, 'reminder_paywall_desc'),
                choiceBadge: '${Strings.get(locale, 'your_choice')} $hourStr:$minuteStr',
                unlockLabel: Strings.get(locale, 'unlock_one_plus'),
                cancelLabel: Strings.get(locale, 'not_now'),
                onUnlocked: () {
                  if (appState.isPremium && widget.onSaved != null) {
                    widget.onSaved!();
                  }
                },
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
            Strings.get(locale, 'set_reminder_btn'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildMomentCard(
    OneThemeExtension ext, {
    required String icon,
    required String title,
    required String timeStr,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isActive ? null : ext.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isActive ? ext.gold : const Color(0xFF352F28).withValues(alpha: 0.09),
            width: isActive ? 1.5 : 1,
          ),
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ext.gold2.withValues(alpha: 0.9),
                    ext.card,
                  ],
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A231A).withValues(alpha: isActive ? 0.12 : 0.035),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: 14, color: isActive ? ext.ink : ext.muted)),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: ext.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ext.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(
    OneThemeExtension ext, {
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF352F28).withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            color: ext.ink,
            onPressed: onMinus,
            splashRadius: 18,
            padding: EdgeInsets.zero,
          ),
          Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: ext.ink,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            color: ext.ink,
            onPressed: onPlus,
            splashRadius: 18,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
