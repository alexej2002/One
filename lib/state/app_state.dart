import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import '../services/quote_service.dart';
import '../services/notification_service.dart';
import '../models/quote.dart';
import '../l10n/strings.dart';
import 'package:intl/intl.dart';
import '../main.dart';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  static const List<String> supportedLocales = ['en', 'ru', 'de', 'es', 'fr', 'pt_BR', 'pt'];

  final QuoteService _quoteService = QuoteService();
  final NotificationService _notificationService = NotificationService();
  
  bool _isInitialized = false;
  bool _isOnboardingComplete = false;
  bool _isPremium = false;
  bool _isActivatingPremium = false;
  String? _premiumStorageError;
  DateTime? _startDate;
  Quote? _currentQuote;
  
  String _themeName = 'paper';
  String _textSize = 'medium';
  String _locale = 'en';
  int _currentTabIndex = 0;
  
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  
  List<Quote> _favorites = [];

  bool get isInitialized => _isInitialized;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isPremium => _isPremium;
  bool get isActivatingPremium => _isActivatingPremium;
  String? get premiumStorageError => _premiumStorageError;
  Quote? get currentQuote => _currentQuote;
  String get themeName => _themeName;
  String get textSize => _textSize;
  String get locale => _locale;
  int get currentTabIndex => _currentTabIndex;
  
  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get notificationTime => _notificationTime;
  List<Quote> get favorites => _favorites;

  Future<void> init() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      _premiumStorageError = 'premium_read_failed';
      debugPrint('Local preferences could not be opened: $e');
    }

    // Premium is a local launch offer. Missing data means Free; a read error
    // must never overwrite a previously saved value.
    try {
      _isPremium = prefs?.getString('premium_access_level') == 'premium';
      if (prefs != null) _premiumStorageError = null;
    } catch (e) {
      _premiumStorageError = 'premium_read_failed';
      debugPrint('Premium status could not be read: $e');
    }
    
    // Load onboarding status
    _isOnboardingComplete = prefs?.getBool('onboarding_complete') ?? false;
    
    // Load theme, text size and locale
    _themeName = prefs?.getString('theme_name') ?? 'paper';
    _textSize = prefs?.getString('text_size') ?? 'medium';
    _locale = prefs?.getString('locale') ?? _detectDeviceLocale();
    
    // Load notifications state
    _notificationsEnabled = prefs?.getBool('notifications_enabled') ?? false;
    final hour = prefs?.getInt('notification_hour') ?? 9;
    final minute = prefs?.getInt('notification_minute') ?? 0;
    _notificationTime = TimeOfDay(hour: hour, minute: minute);
    
    // Load or set start date
    final startDateStr = prefs?.getString('start_date');
    if (startDateStr != null) {
      _startDate = DateTime.parse(startDateStr);
    } else {
      _startDate = DateTime.now();
      await prefs?.setString('start_date', _startDate!.toIso8601String());
    }

    // Load quotes
    await _quoteService.loadQuotes(_locale);
    _updateCurrentQuote();
    
    // Load favorites
    final favListString = prefs?.getStringList('favorites');
    if (favListString != null) {
      _favorites = favListString
          .map((str) => Quote.fromJson(jsonDecode(str) as Map<String, dynamic>, _locale))
          .toList();
    }
    
    await _notificationService.init(
      onNotificationTapped: () {
        _currentTabIndex = 0; // Switch to TodayScreen
        rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
        notifyListeners();
      },
    );
    try {
      await _rescheduleNotificationIfEnabled();
    } catch (e) {
      debugPrint('Daily reminder could not be scheduled on startup: $e');
    }
    
    // Register lifecycle observer to automatically refresh quotes upon app resume / midnight passing
    WidgetsBinding.instance.addObserver(this);

    _isInitialized = true;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDayChange();
    }
  }

  void _checkDayChange() {
    final oldText = _currentQuote?.text;
    _updateCurrentQuote();
    if (oldText != _currentQuote?.text) {
      debugPrint("Day transition detected on resume: updated quote to today");
      _rescheduleNotificationIfEnabled();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  VoidCallback? _pendingPremiumAction;

  void setPendingPremiumAction(VoidCallback? action) {
    _pendingPremiumAction = action;
  }

  void applyPendingPremiumAction() {
    if (!_isPremium) return;
    if (_pendingPremiumAction != null) {
      final action = _pendingPremiumAction;
      _pendingPremiumAction = null;
      action?.call();
    }
  }

  void clearPendingPremiumAction() {
    _pendingPremiumAction = null;
  }

  Future<bool> activateFreePremium() async {
    if (_isPremium) {
      applyPendingPremiumAction();
      notifyListeners();
      return true;
    }
    if (_isActivatingPremium) return false;

    _isActivatingPremium = true;
    _premiumStorageError = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final activatedAt = prefs.getString('premium_activated_at');
      await prefs.setString('premium_access_level', 'premium');
      await prefs.setString('premium_grant_source', 'launch_offer');
      if (activatedAt == null) {
        await prefs.setString('premium_activated_at', DateTime.now().toUtc().toIso8601String());
      }
      await prefs.setInt('premium_schema_version', 1);
      _isPremium = true;
      applyPendingPremiumAction();
      await _updateWidgetPremiumStatus();
      return true;
    } catch (e) {
      _premiumStorageError = 'premium_write_failed';
      debugPrint('Premium activation could not be saved: $e');
      return false;
    } finally {
      _isActivatingPremium = false;
      notifyListeners();
    }
  }

  Future<void> _updateWidgetPremiumStatus() async {
    await HomeWidget.saveWidgetData<bool>('premium_active', _isPremium);
    await HomeWidget.updateWidget(name: 'QuoteWidgetProvider');
  }

  String _detectDeviceLocale() {
    final locales = WidgetsBinding.instance.platformDispatcher.locales;
    if (locales.isEmpty) return 'en';
    final primary = locales.first;
    if (primary.languageCode == 'pt' && primary.countryCode == 'BR') {
      return 'pt_BR';
    }
    final langCode = primary.languageCode;
    return supportedLocales.contains(langCode) ? langCode : 'en';
  }

  void _updateCurrentQuote() {
    _currentQuote = _quoteService.getQuoteForDate(DateTime.now());
    
    if (_currentQuote != null) {
      HomeWidget.saveWidgetData<bool>('premium_active', _isPremium);
      final now = DateTime.now();
      final dateStr = DateFormat.MMMd(_locale).format(now).toUpperCase();
      HomeWidget.saveWidgetData<String>('quote_text', _currentQuote!.text);
      HomeWidget.saveWidgetData<String>('quote_author', '— ${_currentQuote!.author}');
      HomeWidget.saveWidgetData<String>('quote_date', '$dateStr · ONE');
      HomeWidget.updateWidget(name: 'QuoteWidgetProvider');
    }
  }

  List<Map<String, dynamic>> getArchiveQuotes() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<Map<String, dynamic>> archive = [];
    
    // Provide past calendar days of quotes
    for (int i = 1; i <= 365; i++) {
      final pastDate = today.subtract(Duration(days: i));
      final q = _quoteService.getQuoteForDate(pastDate);
      archive.add({'date': pastDate, 'quote': q});
    }
    
    return archive;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    _isOnboardingComplete = true;
    notifyListeners();
  }

  void setPremium(bool status) {
    if (status) {
      activateFreePremium();
    }
  }
  
  Future<void> setTheme(String themeName) async {
    _themeName = themeName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_name', themeName);
    notifyListeners();
  }

  Future<void> setTextSize(String size) async {
    _textSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('text_size', size);
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
  
  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    _locale = languageCode;
    await prefs.setString('locale', languageCode);
    await _quoteService.loadQuotes(_locale);
    _updateCurrentQuote();
    _favorites = _favorites.map((fav) => fav.copyWithLocale(_locale)).toList();
    await prefs.setStringList(
      'favorites',
      _favorites.map((q) => jsonEncode(q.toJson())).toList(),
    );
    await _rescheduleNotificationIfEnabled();
    notifyListeners();
  }
  
  Future<void> toggleNotifications() async {
    if (!_notificationsEnabled) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) return;
    }

    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    
    if (_notificationsEnabled) {
      await _rescheduleNotificationIfEnabled();
    } else {
      await _notificationService.cancelAll();
    }
    notifyListeners();
  }
  
  Future<void> setNotificationTime(TimeOfDay time) async {
    _notificationTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', time.hour);
    await prefs.setInt('notification_minute', time.minute);
    
    // Auto-enable notifications when user explicitly sets a reminder time
    if (!_notificationsEnabled) {
      final granted = await _notificationService.requestPermissions();
      if (granted) {
        _notificationsEnabled = true;
        await prefs.setBool('notifications_enabled', true);
      }
    }
    
    if (_notificationsEnabled) {
      await _rescheduleNotificationIfEnabled();
    }
    notifyListeners();
  }
  
  Future<void> _rescheduleNotificationIfEnabled() async {
    if (_notificationsEnabled) {
      final now = DateTime.now();
      // Expanded date with full month name: e.g. "19 августа" / "August 19"
      final dateStr = DateFormat.MMMMd(_locale).format(now);
      final body = _currentQuote != null
          ? '“${_currentQuote!.text}”\n— ${_currentQuote!.author}'
          : Strings.get(_locale, 'notification_body');

      await _notificationService.scheduleDailyReminder(
        time: _notificationTime,
        body: body,
        subText: dateStr,
        title: Strings.get(_locale, 'notification_title'),
      );
    }
  }

  bool isFavorite(Quote quote) {
    return _favorites.any((q) => (quote.day != null && q.day == quote.day) || q.text == quote.text);
  }

  Future<void> toggleFavorite(Quote quote) async {
    if (isFavorite(quote)) {
      _favorites.removeWhere((q) => (quote.day != null && q.day == quote.day) || q.text == quote.text);
    } else {
      _favorites.add(quote);
    }
    
    final prefs = await SharedPreferences.getInstance();
    final favListString = _favorites.map((q) => jsonEncode(q.toJson())).toList();
    await prefs.setStringList('favorites', favListString);
    
    notifyListeners();
  }
}

