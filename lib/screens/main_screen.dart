import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'today_screen.dart';
import 'archive_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [
    TodayScreen(),
    ArchiveScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentTabIndex = context.watch<AppState>().currentTabIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentTabIndex,
        children: _screens,
      ),
    );
  }
}
