import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/quote_service.dart';
import '../models/quote.dart';

// TODO: Replace with your actual RevenueCat API keys
const String appleApiKey = 'appl_YOUR_API_KEY_HERE';
const String googleApiKey = 'goog_mfTQvMcXrWDnuHOKDcFadyhiXot';

class AppState extends ChangeNotifier {
  static const List<String> supportedLocales = ['en', 'ru', 'de', 'es', 'fr', 'pt'];

  final QuoteService _quoteService = QuoteService();
  
  bool _isInitialized = false;
  bool _isOnboardingComplete = false;
  bool _isPremium = false;
  DateTime? _startDate;
  Quote? _currentQuote;
  
  ThemeMode _themeMode = ThemeMode.dark;
  String _locale = 'en';
  
  Offerings? _offerings;

  bool get isInitialized => _isInitialized;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isPremium => _isPremium;
  Quote? get currentQuote => _currentQuote;
  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;
  Offerings? get offerings => _offerings;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load onboarding status
    _isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    
    // Load theme and locale
    final isDark = prefs.getBool('is_dark_theme') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _locale = prefs.getString('locale') ?? _detectDeviceLocale();
    
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
      final customerInfo = await Purchases.purchasePackage(package);
      _checkPremiumStatus(customerInfo);
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
    notifyListeners();
  }
}

