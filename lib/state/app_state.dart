import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quote_service.dart';
import '../models/quote.dart';

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

  bool get isInitialized => _isInitialized;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isPremium => _isPremium;
  Quote? get currentQuote => _currentQuote;
  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;

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
    
    _isInitialized = true;
    notifyListeners();
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

