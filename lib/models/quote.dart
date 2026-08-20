class Quote {
  final int? day;
  final String text;
  final String author;
  final String? theme;
  final Map<String, String>? rawQuotes;
  final Map<String, String>? rawAuthors;
  final Map<String, dynamic>? rawJson;

  Quote({
    this.day,
    required this.text,
    required this.author,
    this.theme,
    this.rawQuotes,
    this.rawAuthors,
    this.rawJson,
  });

  factory Quote.fromJson(Map<String, dynamic> json, [String locale = 'en']) {
    final rawQ = <String, String>{};
    final rawA = <String, String>{};

    // Extract quotes
    if (json['quote'] is Map) {
      final qMap = Map<String, dynamic>.from(json['quote'] as Map);
      qMap.forEach((k, v) => rawQ[k.toString()] = v.toString());
    } else {
      for (final entry in json.entries) {
        if (entry.key.startsWith('quote_')) {
          final lang = entry.key.substring(6);
          rawQ[lang] = entry.value.toString();
        }
      }
      if (json['quote'] is String) {
        rawQ['default'] = json['quote'] as String;
      }
      if (json['text'] is String) {
        rawQ['default'] = json['text'] as String;
      }
    }

    // Extract authors
    if (json['author'] is Map) {
      final aMap = Map<String, dynamic>.from(json['author'] as Map);
      aMap.forEach((k, v) => rawA[k.toString()] = v.toString());
    } else {
      for (final entry in json.entries) {
        if (entry.key.startsWith('author_')) {
          final lang = entry.key.substring(7);
          rawA[lang] = entry.value.toString();
        }
      }
      if (json['author'] is String) {
        rawA['default'] = json['author'] as String;
      }
    }

    final resolvedText = resolveValueForLocale(rawQ, locale);
    final resolvedAuthor = resolveValueForLocale(rawA, locale);

    return Quote(
      day: json['day'] as int?,
      text: resolvedText.isNotEmpty
          ? resolvedText
          : (json['text'] as String? ?? json['quote'] as String? ?? ''),
      author: resolvedAuthor.isNotEmpty
          ? resolvedAuthor
          : (json['author'] as String? ?? ''),
      theme: json['theme'] as String?,
      rawQuotes: rawQ.isNotEmpty ? rawQ : null,
      rawAuthors: rawA.isNotEmpty ? rawA : null,
      rawJson: json,
    );
  }

  static String resolveValueForLocale(Map<String, String> values, String locale) {
    if (values.isEmpty) return '';

    // Direct match (e.g. 'ru', 'de', 'es', 'fr', 'en', 'pt_BR', 'pt-BR')
    if (values.containsKey(locale)) return values[locale]!;

    final normalized = locale.replaceAll('-', '_');
    if (values.containsKey(normalized)) return values[normalized]!;

    final hyphenated = locale.replaceAll('_', '-');
    if (values.containsKey(hyphenated)) return values[hyphenated]!;

    if (locale == 'pt_BR') {
      return values['pt_BR'] ??
          values['pt-BR'] ??
          values['pt_PT'] ??
          values['pt-PT'] ??
          values['pt'] ??
          values['en'] ??
          values['default'] ??
          values.values.first;
    }

    if (locale == 'pt') {
      return values['pt_PT'] ??
          values['pt-PT'] ??
          values['pt_BR'] ??
          values['pt-BR'] ??
          values['pt'] ??
          values['en'] ??
          values['default'] ??
          values.values.first;
    }

    if (values.containsKey('en')) return values['en']!;
    if (values.containsKey('default')) return values['default']!;

    return values.values.first;
  }

  Quote copyWithLocale(String locale) {
    return Quote(
      day: day,
      text: rawQuotes != null ? resolveValueForLocale(rawQuotes!, locale) : text,
      author: rawAuthors != null ? resolveValueForLocale(rawAuthors!, locale) : author,
      theme: theme,
      rawQuotes: rawQuotes,
      rawAuthors: rawAuthors,
      rawJson: rawJson,
    );
  }

  Map<String, dynamic> toJson() {
    if (rawJson != null) return rawJson!;
    return {
      if (day != null) 'day': day,
      'text': text,
      'author': author,
      if (theme != null) 'theme': theme,
      if (rawQuotes != null) 'quotes': rawQuotes,
      if (rawAuthors != null) 'authors': rawAuthors,
    };
  }
}
