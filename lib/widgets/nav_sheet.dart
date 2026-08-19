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
                const SizedBox(height: 20),
                // 2x2 Grid of Navigation Tiles
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.18,
                  children: [
                    _buildNavTile(
                      context: context,
                      ext: ext,
                      icon: '☼',
                      title: Strings.get(loc, 'today'),
                      subtitle: Strings.get(loc, 'today_sub'),
                      isActive: appState.currentTabIndex == 0,
                      onTap: () {
                        appState.setTabIndex(0);
                        Navigator.pop(ctx);
                      },
                    ),
                    _buildNavTile(
                      context: context,
                      ext: ext,
                      icon: '▤',
                      title: Strings.get(loc, 'archive'),
                      subtitle: Strings.get(loc, 'archive_sub'),
                      isActive: appState.currentTabIndex == 1,
                      onTap: () {
                        appState.setTabIndex(1);
                        Navigator.pop(ctx);
                      },
                    ),
                    _buildNavTile(
                      context: context,
                      ext: ext,
                      icon: '♡',
                      title: Strings.get(loc, 'favorites'),
                      subtitle: Strings.get(loc, 'favorites_sub'),
                      isActive: appState.currentTabIndex == 2,
                      onTap: () {
                        appState.setTabIndex(2);
                        Navigator.pop(ctx);
                      },
                    ),
                    _buildNavTile(
                      context: context,
                      ext: ext,
                      icon: '⚙',
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
  required BuildContext context,
  required OneThemeExtension ext,
  required String icon,
  required String title,
  required String subtitle,
  required bool isActive,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isActive ? null : ext.card.withValues(alpha: 0.92),
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(ext.gold2, ext.card, 0.48)!,
                  ext.card,
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive ? ext.gold : const Color(0xFF352F28).withValues(alpha: 0.09),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D251C).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            icon,
            style: TextStyle(
              fontSize: 23,
              color: ext.ink,
            ),
          ),
          Column(
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
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: ext.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
