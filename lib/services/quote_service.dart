import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quote.dart';

class QuoteService {
  List<Quote> _allQuotes = [];
  String _currentLocale = 'en';

  Future<void> loadQuotes(String locale) async {
    _currentLocale = locale;
    if (_allQuotes.isEmpty) {
      final String response = await rootBundle.loadString('assets/one_quotes_365.json');
      final data = await json.decode(response) as List;
      _allQuotes = data
          .map((item) => Quote.fromJson(item as Map<String, dynamic>, _currentLocale))
          .toList();
    } else {
      // Re-map localized texts for the active locale without re-reading file
      _allQuotes = _allQuotes.map((q) => q.copyWithLocale(_currentLocale)).toList();
    }
  }

  Quote getQuoteForDay(int dayIndex) {
    if (_allQuotes.isEmpty) {
      return Quote(text: "Loading...", author: "");
    }
    // Loop back to the beginning if we run out of quotes
    return _allQuotes[dayIndex % _allQuotes.length];
  }

  int calculateDayIndex(DateTime startDate, DateTime currentDate) {
    // Normalizing to UTC midnight ensures no DST / daylight shift artifacts
    final startUtc = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final currentUtc = DateTime.utc(currentDate.year, currentDate.month, currentDate.day);
    final diff = currentUtc.difference(startUtc).inDays;
    return diff < 0 ? 0 : diff;
  }
}
