import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import 'premium_screen.dart';
import 'favorites_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _formatTime(TimeOfDay time, BuildContext context) {
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isPremium = state.isPremium;
    final locale = state.locale;
    final theme = state.themeMode == ThemeMode.dark
        ? Strings.get(locale, 'theme_dark')
        : Strings.get(locale, 'theme_light');
    final langMap = {
      'en': 'English',
      'ru': 'Русский',
      'de': 'Deutsch',
      'es': 'Español',
      'fr': 'Français',
      'pt': 'Português',
    };
    final lang = langMap[locale] ?? 'English';
    final timeStr = _formatTime(state.notificationTime, context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Topbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        Strings.get(locale, 'settings'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for centering
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  _buildSectionLabel(Strings.get(locale, 'daily_quote') ?? 'Daily Quote', context),
                  _buildSettingsCard(
                    context,
                    children: [
                      _buildSettingRow(
                        Icons.favorite_border,
                        Strings.get(locale, 'saved_quotes') ?? 'Saved Quotes',
                        context: context,
                        locale: locale,
                      ),
                      _buildSettingRow(
                        Icons.notifications_none,
                        Strings.get(locale, 'notifications'),
                        isSwitch: true,
                        switchValue: state.notificationsEnabled,
                        context: context,
                        locale: locale,
                      ),
                      _buildSettingRow(
                        Icons.access_time,
                        Strings.get(locale, 'reminder_time') ?? 'Reminder Time',
                        trailing: timeStr,
                        context: context,
                        locale: locale,
                      ),
                      _buildSettingRow(Icons.palette_outlined, Strings.get(locale, 'theme'), trailing: theme, context: context, locale: locale),
                      _buildSettingRow(Icons.language, Strings.get(locale, 'language'), trailing: lang, context: context, locale: locale),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionLabel(Strings.get(locale, 'one_premium') ?? 'ONE Premium', context),
                  if (!isPremium)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PremiumScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor.withValues(alpha: 0.2),
                              Theme.of(context).primaryColor.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 28),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Strings.get(locale, 'not_premium'),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Strings.get(locale, 'unlock_features'),
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodyMedium?.color),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 16),
                          Text(Strings.get(locale, 'premium_active') ?? 'Premium Active', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),
                  _buildSectionLabel(Strings.get(locale, 'about') ?? 'About', context),
                  _buildSettingsCard(
                    context,
                    children: [
                      _buildSettingRow(Icons.privacy_tip_outlined, Strings.get(locale, 'privacy_policy'), context: context, locale: locale),
                      _buildSettingRow(Icons.description_outlined, Strings.get(locale, 'terms'), context: context, locale: locale),
                      _buildSettingRow(Icons.mail_outline, Strings.get(locale, 'contact') ?? 'Contact us', context: context, locale: locale),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.03) ?? Colors.black12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingRow(
    IconData icon,
    String title, {
    String? trailing,
    bool isSwitch = false,
    bool switchValue = false,
    required BuildContext context,
    String locale = 'en',
  }) {
    return InkWell(
      onTap: () async {
        final state = context.read<AppState>();
        
        if (title == (Strings.get(locale, 'saved_quotes') ?? 'Saved Quotes')) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
          return;
        } else if (isSwitch && title == Strings.get(locale, 'notifications')) {
          await state.toggleNotifications();
        } else if (title == (Strings.get(locale, 'reminder_time') ?? 'Reminder Time')) {
          if (!state.isPremium) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen()));
            return;
          }
          final newTime = await showTimePicker(
            context: context,
            initialTime: state.notificationTime,
          );
          if (newTime != null) {
            state.setNotificationTime(newTime);
          }
        } else if (title == Strings.get(locale, 'theme')) {
          if (!state.isPremium) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen()));
          } else {
            state.toggleTheme();
          }
        } else if (title == Strings.get(locale, 'language')) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: const Text('Select Language'),
                children: <Widget>[
                  SimpleDialogOption(onPressed: () { Navigator.pop(context, 'en'); }, child: const Text('English')),
                  SimpleDialogOption(onPressed: () { Navigator.pop(context, 'ru'); }, child: const Text('Русский')),
                  SimpleDialogOption(onPressed: () { Navigator.pop(context, 'de'); }, child: const Text('Deutsch')),
                  SimpleDialogOption(onPressed: () { Navigator.pop(context, 'es'); }, child: const Text('Español')),
                  SimpleDialogOption(onPressed: () { Navigator.pop(context, 'fr'); }, child: const Text('Français')),
                  SimpleDialogOption(onPressed: () { Navigator.pop(context, 'pt'); }, child: const Text('Português')),
                ],
              );
            }
          ).then((selectedLocale) {
            if (selectedLocale != null) {
              state.setLocale(selectedLocale);
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing,
                style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
            ] else if (isSwitch) ...[
              Switch(
                value: switchValue,
                onChanged: (val) {
                  final state = context.read<AppState>();
                  if (title == Strings.get(locale, 'notifications')) {
                    state.toggleNotifications();
                  }
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ] else ...[
              Icon(Icons.chevron_right, size: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
            ],
          ],
        ),
      ),
    );
  }
}
