import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';

void showNavigationSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Consumer<AppState>(
        builder: (context, appState, _) {
          final ext = Theme.of(context).extension<OneThemeExtension>()!;
          final loc = appState.locale;
          return Container(
            decoration: BoxDecoration(
              color: ext.bg2,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 60,
                  offset: const Offset(0, -24),
                )
              ],
            ),
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 12,
              bottom: 22 + MediaQuery.of(context).padding.bottom,
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
                  margin: const EdgeInsets.only(bottom: 18),
                ),
                // Brand Header
                Text(
                  'ONE',
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    letterSpacing: 6,
                    color: ext.ink,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    _buildNavTile(
                      ext: ext,
                      icon: Icons.wb_sunny_outlined,
                      title: Strings.get(loc, 'today'),
                      subtitle: Strings.get(loc, 'today_sub'),
                      isActive: appState.currentTabIndex == 0,
                      onTap: () {
                        appState.setTabIndex(0);
                        Navigator.pop(ctx);
                      },
                    ),
                    Divider(height: 1, indent: 72, endIndent: 10, color: ext.line),
                    _buildNavTile(
                      ext: ext,
                      icon: Icons.auto_stories_outlined,
                      title: Strings.get(loc, 'archive'),
                      subtitle: Strings.get(loc, 'archive_sub'),
                      isActive: appState.currentTabIndex == 1,
                      onTap: () {
                        appState.setTabIndex(1);
                        Navigator.pop(ctx);
                      },
                    ),
                    Divider(height: 1, indent: 72, endIndent: 10, color: ext.line),
                    _buildNavTile(
                      ext: ext,
                      icon: Icons.favorite_border,
                      title: Strings.get(loc, 'favorites'),
                      subtitle: Strings.get(loc, 'favorites_sub'),
                      isActive: appState.currentTabIndex == 2,
                      onTap: () {
                        appState.setTabIndex(2);
                        Navigator.pop(ctx);
                      },
                    ),
                    Divider(height: 1, indent: 72, endIndent: 10, color: ext.line),
                    _buildNavTile(
                      ext: ext,
                      icon: Icons.settings_outlined,
                      title: Strings.get(loc, 'settings'),
                      subtitle: Strings.get(loc, 'settings_sub'),
                      isActive: appState.currentTabIndex == 3,
                      onTap: () {
                        appState.setTabIndex(3);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildNavTile({
  required OneThemeExtension ext,
  required IconData icon,
  required String title,
  required String subtitle,
  required bool isActive,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? ext.gold : ext.line),
            ),
            child: Icon(icon, size: 21, color: isActive ? ext.gold : ext.ink),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: ext.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: ext.muted),
                ),
              ],
            ),
          ),
          if (isActive)
            Icon(Icons.check, size: 17, color: ext.gold)
          else
            Icon(Icons.chevron_right, size: 19, color: ext.muted),
        ],
      ),
    ),
  );
}
