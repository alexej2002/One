import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quote.dart';

class QuoteService {
  List<Quote> _quotes = [];

  Future<void> loadQuotes(String locale) async {
    String filename = 'assets/quotes.json'; // fallback
    if (['ru', 'de', 'es', 'fr', 'pt'].contains(locale)) {
      filename = 'assets/quotes_$locale.json';
    }
    
    final String response = await rootBundle.loadString(filename);
    final data = await json.decode(response) as List;
    _quotes = data.map((json) => Quote.fromJson(json)).toList();
  }

  Quote getQuoteForDay(int dayIndex) {
    if (_quotes.isEmpty) {
      return Quote(text: "Loading...", author: "");
    }
    // Loop back to the beginning if we run out of quotes
    return _quotes[dayIndex % _quotes.length];
  }

  int calculateDayIndex(DateTime startDate, DateTime currentDate) {
    // Calculate how many days have passed since the start date
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final current = DateTime(currentDate.year, currentDate.month, currentDate.day);
    return current.difference(start).inDays;
  }
}
