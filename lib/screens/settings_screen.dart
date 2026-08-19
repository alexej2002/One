import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../l10n/strings.dart';
import '../widgets/nav_sheet.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final locale = state.locale;
    final ext = Theme.of(context).extension<OneThemeExtension>()!;

    final timeStr = MaterialLocalizations.of(context).formatTimeOfDay(state.notificationTime);

    final langDisplay = {
      'en': 'English',
      'ru': 'Русский',
      'de': 'Deutsch',
      'es': 'Español',
      'fr': 'Français',
      'pt_BR': 'Português (BR)',
      'pt': 'Português (PT)',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.get(locale, 'settings')),
        centerTitle: true,
        leading: const SizedBox(width: 40),
        actions: [
          IconButton(
            icon: const Text('•••', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            onPressed: () => showNavigationSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          _buildLabel(Strings.get(locale, 'section_daily'), ext),
          _buildCard(ext, [
            _buildRow(ext, Icons.access_time, Strings.get(locale, 'reminder_time'), Strings.get(locale, 'reminder_time_sub'), value: timeStr, onTap: () async {
              if (!state.isPremium) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
                return;
              }
              final newTime = await showTimePicker(context: context, initialTime: state.notificationTime);
              if (newTime != null) state.setNotificationTime(newTime);
            }),
            _buildRow(ext, Icons.notifications_none, Strings.get(locale, 'notifications'), Strings.get(locale, 'notifications_sub'), isSwitch: true, switchValue: state.notificationsEnabled, onTap: () {
              state.toggleNotifications();
            }),
          ]),
          
          const SizedBox(height: 26),
          _buildLabel(Strings.get(locale, 'section_appearance'), ext),
          _buildCard(ext, [
            _buildRow(ext, Icons.palette_outlined, Strings.get(locale, 'theme'), Strings.get(locale, 'theme_sub'), value: _getThemeTitle(locale, state.themeName), onTap: () {
              _showThemeSheet(context, state, ext, locale);
            }),
            _buildRow(ext, Icons.text_fields, Strings.get(locale, 'text_size'), Strings.get(locale, 'text_size_sub'), value: _getTextSizeTitle(locale, state.textSize), onTap: () {
              _showTextSizeSheet(context, state, ext, locale);
            }),
            _buildRow(ext, Icons.language, Strings.get(locale, 'language'), Strings.get(locale, 'language_sub'), value: langDisplay[state.locale] ?? state.locale.toUpperCase(), onTap: () {
              _showLanguageSheet(context, state, ext, locale);
            }),
          ]),

          const SizedBox(height: 26),
          _buildLabel(Strings.get(locale, 'section_premium'), ext),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
            child: Container(
              margin: const EdgeInsets.only(bottom: 26),
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('✦', style: TextStyle(fontSize: 22, color: ext.ink)),
                      const SizedBox(width: 6),
                      Text('ONE+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ext.ink)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(Strings.get(locale, 'one_plus_sub'), style: TextStyle(fontSize: 12, color: ext.muted, height: 1.45)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          _buildLabel(Strings.get(locale, 'section_about'), ext),
          _buildCard(ext, [
            _buildRow(ext, Icons.info_outline, Strings.get(locale, 'about_one'), Strings.get(locale, 'about_one_sub'), onTap: () {
              // about info
            }),
            _buildRow(ext, Icons.share_outlined, Strings.get(locale, 'share_one'), null, isLink: true, onTap: () {
              // share app
            }),
            _buildRow(ext, Icons.mail_outline, Strings.get(locale, 'send_feedback'), null, isLink: true, onTap: () {
              // mail feedback
            }),
          ]),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  String _getThemeTitle(String locale, String theme) {
    if (theme == 'sepia') return Strings.get(locale, 'theme_sepia');
    if (theme == 'dark') return Strings.get(locale, 'theme_dark');
    return Strings.get(locale, 'theme_paper');
  }

  String _getTextSizeTitle(String locale, String size) {
    if (size == 'small') return Strings.get(locale, 'size_small');
    if (size == 'large') return Strings.get(locale, 'size_large');
    return Strings.get(locale, 'size_medium');
  }

  Widget _buildLabel(String text, OneThemeExtension ext) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 9),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w700,
          color: ext.muted.withValues(alpha: 0.88),
        ),
      ),
    );
  }

  Widget _buildCard(OneThemeExtension ext, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: ext.card.withValues(alpha: 0.88),
        border: Border.all(color: const Color(0xFF352F28).withValues(alpha: 0.09)),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(color: const Color(0xFF30271D).withValues(alpha: 0.035), blurRadius: 22, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildRow(OneThemeExtension ext, IconData icon, String title, String? sub, {String? value, bool isSwitch = false, bool switchValue = false, bool isLink = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        constraints: const BoxConstraints(minHeight: 64),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: ext.line, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: ext.ink),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: ext.ink)),
                  if (sub != null) ...[
                    const SizedBox(height: 3),
                    Text(sub, style: TextStyle(fontSize: 10, color: ext.muted, height: 1.45)),
                  ],
                ],
              ),
            ),
            if (value != null)
              Row(
                children: [
                  Text(value, style: TextStyle(fontSize: 11.5, color: ext.muted)),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 16, color: ext.muted),
                ],
              )
            else if (isSwitch)
              Switch(
                value: switchValue,
                onChanged: (_) => onTap?.call(),
                activeThumbColor: ext.gold,
              )
            else if (isLink)
              Icon(Icons.north_east, size: 16, color: ext.muted)
            else
              Icon(Icons.chevron_right, size: 16, color: ext.muted),
          ],
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context, AppState state, OneThemeExtension ext, String locale) {
    if (!state.isPremium) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }
    _showSelectionSheet(context, ext, Strings.get(locale, 'theme'), [
      {'id': 'paper', 'title': Strings.get(locale, 'theme_paper'), 'sub': Strings.get(locale, 'theme_paper_sub')},
      {'id': 'sepia', 'title': Strings.get(locale, 'theme_sepia'), 'sub': Strings.get(locale, 'theme_sepia_sub')},
      {'id': 'dark', 'title': Strings.get(locale, 'theme_dark'), 'sub': Strings.get(locale, 'theme_dark_sub')},
    ], state.themeName, (id) => state.setTheme(id));
  }

  void _showTextSizeSheet(BuildContext context, AppState state, OneThemeExtension ext, String locale) {
    _showSelectionSheet(context, ext, Strings.get(locale, 'text_size'), [
      {'id': 'small', 'title': Strings.get(locale, 'size_small'), 'sub': Strings.get(locale, 'size_small_sub')},
      {'id': 'medium', 'title': Strings.get(locale, 'size_medium'), 'sub': Strings.get(locale, 'size_medium_sub')},
      {'id': 'large', 'title': Strings.get(locale, 'size_large'), 'sub': Strings.get(locale, 'size_large_sub')},
    ], state.textSize, (id) => state.setTextSize(id));
  }

  void _showLanguageSheet(BuildContext context, AppState state, OneThemeExtension ext, String locale) {
    _showSelectionSheet(context, ext, Strings.get(locale, 'language'), [
      {'id': 'en', 'title': 'English', 'sub': 'English'},
      {'id': 'ru', 'title': 'Русский', 'sub': 'Russian'},
      {'id': 'de', 'title': 'Deutsch', 'sub': 'German'},
      {'id': 'es', 'title': 'Español', 'sub': 'Spanish'},
      {'id': 'fr', 'title': 'Français', 'sub': 'French'},
      {'id': 'pt_BR', 'title': 'Português (Brasil)', 'sub': 'Brazilian Portuguese'},
      {'id': 'pt', 'title': 'Português (Portugal)', 'sub': 'European Portuguese'},
    ], state.locale, (id) => state.setLocale(id));
  }

  void _showSelectionSheet(BuildContext context, OneThemeExtension ext, String title, List<Map<String, String>> options, String currentValue, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(color: ext.bg2, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
          padding: EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 24 + MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ext.line, borderRadius: BorderRadius.circular(99)), margin: const EdgeInsets.only(bottom: 18))),
              Text(title, style: const TextStyle(fontSize: 24, fontFamily: 'Georgia')),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isActive = currentValue == opt['id'];
                return GestureDetector(
                  onTap: () {
                    onSelect(opt['id']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: ext.card,
                      border: Border.all(color: isActive ? ext.gold : ext.line),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opt['title']!, style: TextStyle(fontWeight: FontWeight.bold, color: ext.ink)),
                            if (opt['sub']!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(opt['sub']!, style: TextStyle(fontSize: 12, color: ext.muted)),
                            ],
                          ],
                        ),
                        if (isActive) Icon(Icons.check, color: ext.ink, size: 18),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
