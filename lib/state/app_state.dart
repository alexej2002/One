import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:home_widget/home_widget.dart';
import '../services/quote_service.dart';
import '../services/notification_service.dart';
import '../models/quote.dart';
import '../l10n/strings.dart';
import 'package:intl/intl.dart';
import '../main.dart';

// TODO: Replace with your actual RevenueCat API keys
const String appleApiKey = 'appl_YOUR_API_KEY_HERE';
const String googleApiKey = 'goog_mfTQvMcXrWDnuHOKDcFadyhiXot';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  static const List<String> supportedLocales = ['en', 'ru', 'de', 'es', 'fr', 'pt_BR', 'pt'];

  final QuoteService _quoteService = QuoteService();
  final NotificationService _notificationService = NotificationService();
  
  bool _isInitialized = false;
  bool _isOnboardingComplete = false;
  bool _isPremium = const bool.fromEnvironment('FORCE_PREMIUM', defaultValue: false);
  DateTime? _startDate;
  Quote? _currentQuote;
  
  String _themeName = 'paper';
  String _textSize = 'medium';
  String _locale = 'en';
  int _currentTabIndex = 0;
  
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  
  Offerings? _offerings;
  
  List<Quote> _favorites = [];

  bool get isInitialized => _isInitialized;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isPremium => _isPremium;
  Quote? get currentQuote => _currentQuote;
  String get themeName => _themeName;
  String get textSize => _textSize;
  String get locale => _locale;
  int get currentTabIndex => _currentTabIndex;
  Offerings? get offerings => _offerings;
  
  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get notificationTime => _notificationTime;
  List<Quote> get favorites => _favorites;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load onboarding status
    _isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    
    // Load theme, text size and locale
    _themeName = prefs.getString('theme_name') ?? 'paper';
    _textSize = prefs.getString('text_size') ?? 'medium';
    _locale = prefs.getString('locale') ?? _detectDeviceLocale();
    
    // Load notifications state
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    final hour = prefs.getInt('notification_hour') ?? 9;
    final minute = prefs.getInt('notification_minute') ?? 0;
    _notificationTime = TimeOfDay(hour: hour, minute: minute);
    
    // Load or set start date
    final startDateStr = prefs.getString('start_date');
    if (startDateStr != null) {
      _startDate = DateTime.parse(startDateStr);
    } else {
      _startDate = DateTime.now();
      await prefs.setString('start_date', _startDate!.toIso8601String());
    }

    // Load quotes
    await _quoteService.loadQuotes(_locale);
    _updateCurrentQuote();
    
    // Load favorites
    final favListString = prefs.getStringList('favorites');
    if (favListString != null) {
      _favorites = favListString.map((str) => Quote.fromJson(jsonDecode(str))).toList();
    }
    
    await _notificationService.init(
      onNotificationTapped: () {
        _currentTabIndex = 0; // Switch to TodayScreen
        rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
        notifyListeners();
      },
    );
    
    // Initialize RevenueCat
    await _initRevenueCat();

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
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initRevenueCat() async {
    if (kIsWeb) return; // RevenueCat does not support Web out-of-the-box

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(googleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(appleApiKey);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
      
      // Listen for subscription changes
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _checkPremiumStatus(customerInfo);
      });

      // Fetch initial status and offerings
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        _checkPremiumStatus(customerInfo);
        
        _offerings = await Purchases.getOfferings();
      } catch (e) {
        debugPrint("Error fetching RevenueCat data: $e");
      }
    }
  }

  VoidCallback? _pendingPremiumAction;

  void setPendingPremiumAction(VoidCallback? action) {
    _pendingPremiumAction = action;
  }

  void applyPendingPremiumAction() {
    if (_pendingPremiumAction != null) {
      final action = _pendingPremiumAction;
      _pendingPremiumAction = null;
      action?.call();
    }
  }

  void clearPendingPremiumAction() {
    _pendingPremiumAction = null;
  }

  void _checkPremiumStatus(CustomerInfo customerInfo) {
    // If built with FORCE_PREMIUM, keep premium enabled
    if (const bool.fromEnvironment('FORCE_PREMIUM', defaultValue: false)) {
      _isPremium = true;
      notifyListeners();
      return;
    }

    // Entitlement name must match what you set in RevenueCat dashboard (e.g., 'premium')
    const entitlementIdentifier = 'premium';
    final isPro = customerInfo.entitlements.all[entitlementIdentifier]?.isActive ?? false;
    
    if (_isPremium != isPro) {
      _isPremium = isPro;
      if (_isPremium) {
        applyPendingPremiumAction();
      }
      notifyListeners();
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      _checkPremiumStatus(purchaseResult.customerInfo);
      applyPendingPremiumAction();
      return true;
    } catch (e) {
      debugPrint("Purchase failed: $e");
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _checkPremiumStatus(customerInfo);
      if (_isPremium) {
        applyPendingPremiumAction();
      }
      return _isPremium;
    } catch (e) {
      debugPrint("Restore failed: $e");
      return false;
    }
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
    if (_startDate != null) {
      int dayIndex = _quoteService.calculateDayIndex(_startDate!, DateTime.now());
      _currentQuote = _quoteService.getQuoteForDay(dayIndex);
      
      if (_currentQuote != null) {
        final now = DateTime.now();
        final dateStr = DateFormat.MMMd(_locale).format(now).toUpperCase();
        HomeWidget.saveWidgetData<String>('quote_text', _currentQuote!.text);
        HomeWidget.saveWidgetData<String>('quote_author', '— ${_currentQuote!.author}');
        HomeWidget.saveWidgetData<String>('quote_date', '$dateStr · ONE');
        HomeWidget.updateWidget(name: 'QuoteWidgetProvider');
        _rescheduleNotificationIfEnabled();
      }
    }
  }

  List<Map<String, dynamic>> getArchiveQuotes() {
    if (_startDate == null) return [];
    int currentDayIndex = _quoteService.calculateDayIndex(_startDate!, DateTime.now());
    List<Map<String, dynamic>> archive = [];
    
    // For demo purposes, if it's the first day, let's pretend there are a few past days
    // so the archive isn't empty on first install during testing.
    int startIndex = 0;
    DateTime start = _startDate!;
    if (currentDayIndex == 0) {
      startIndex = -3; // show 3 days of fake history for demonstration
      start = _startDate!.subtract(const Duration(days: 3));
    }

    for (int i = startIndex; i < currentDayIndex; i++) {
      int idx = i;
      if (idx < 0) idx = 30 + idx; // wrap around for fake history
      DateTime d = start.add(Duration(days: i - startIndex));
      Quote q = _quoteService.getQuoteForDay(idx);
      archive.add({'date': d, 'quote': q});
    }
    
    return archive.reversed.toList();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    _isOnboardingComplete = true;
    notifyListeners();
  }

  void setPremium(bool status) {
    _isPremium = status;
    notifyListeners();
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
    _rescheduleNotificationIfEnabled();
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
      _rescheduleNotificationIfEnabled();
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
      );
    }
  }

  bool isFavorite(Quote quote) {
    return _favorites.any((q) => q.text == quote.text);
  }

  Future<void> toggleFavorite(Quote quote) async {
    if (isFavorite(quote)) {
      _favorites.removeWhere((q) => q.text == quote.text);
    } else {
      _favorites.add(quote);
    }
    
    final prefs = await SharedPreferences.getInstance();
    final favListString = _favorites.map((q) => jsonEncode(q.toJson())).toList();
    await prefs.setStringList('favorites', favListString);
    
    notifyListeners();
  }
}

