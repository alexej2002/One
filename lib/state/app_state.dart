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

// TODO: Replace with your actual RevenueCat API keys
const String appleApiKey = 'appl_YOUR_API_KEY_HERE';
const String googleApiKey = 'goog_mfTQvMcXrWDnuHOKDcFadyhiXot';

class AppState extends ChangeNotifier {
  static const List<String> supportedLocales = ['en', 'ru', 'de', 'es', 'fr', 'pt'];

  final QuoteService _quoteService = QuoteService();
  final NotificationService _notificationService = NotificationService();
  
  bool _isInitialized = false;
  bool _isOnboardingComplete = false;
  bool _isPremium = false;
  DateTime? _startDate;
  Quote? _currentQuote;
  
  ThemeMode _themeMode = ThemeMode.dark;
  String _locale = 'en';
  
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  
  Offerings? _offerings;
  
  List<Quote> _favorites = [];

  bool get isInitialized => _isInitialized;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isPremium => _isPremium;
  Quote? get currentQuote => _currentQuote;
  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;
  Offerings? get offerings => _offerings;
  
  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get notificationTime => _notificationTime;
  List<Quote> get favorites => _favorites;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load onboarding status
    _isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    
    // Load theme and locale
    final isDark = prefs.getBool('is_dark_theme') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
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
    
    await _notificationService.init();
    
    // Initialize RevenueCat
    await _initRevenueCat();

    _isInitialized = true;
    notifyListeners();
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

  void _checkPremiumStatus(CustomerInfo customerInfo) {
    // Entitlement name must match what you set in RevenueCat dashboard (e.g., 'premium')
    const entitlementIdentifier = 'premium';
    final isPro = customerInfo.entitlements.all[entitlementIdentifier]?.isActive ?? false;
    
    if (_isPremium != isPro) {
      _isPremium = isPro;
      notifyListeners();
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      _checkPremiumStatus(purchaseResult.customerInfo);
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
      return _isPremium;
    } catch (e) {
      debugPrint("Restore failed: $e");
      return false;
    }
  }

  String _detectDeviceLocale() {
    final locales = WidgetsBinding.instance.platformDispatcher.locales;
    if (locales.isEmpty) return 'en';
    final langCode = locales.first.languageCode;
    return supportedLocales.contains(langCode) ? langCode : 'en';
  }

  void _updateCurrentQuote() {
    if (_startDate != null) {
      int dayIndex = _quoteService.calculateDayIndex(_startDate!, DateTime.now());
      _currentQuote = _quoteService.getQuoteForDay(dayIndex);
      
      if (_currentQuote != null) {
        HomeWidget.saveWidgetData<String>('quote_text', _currentQuote!.text);
        HomeWidget.saveWidgetData<String>('quote_author', '— ${_currentQuote!.author}');
        HomeWidget.updateWidget(name: 'QuoteWidgetProvider');
      }
    }
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
  
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await prefs.setBool('is_dark_theme', false);
    } else {
      _themeMode = ThemeMode.dark;
      await prefs.setBool('is_dark_theme', true);
    }
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
    
    if (_notificationsEnabled) {
      _rescheduleNotificationIfEnabled();
    }
    notifyListeners();
  }
  
  Future<void> _rescheduleNotificationIfEnabled() async {
    if (_notificationsEnabled) {
      await _notificationService.scheduleDailyReminder(
        _notificationTime,
        Strings.get(_locale, 'notification_title') ?? 'ONE',
        Strings.get(_locale, 'notification_body') ?? 'Your daily quote is ready.',
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

