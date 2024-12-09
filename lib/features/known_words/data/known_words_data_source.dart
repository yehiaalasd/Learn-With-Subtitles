// lib/features/known_words/data/known_words_data_source.dart

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KnownWordsDataSource {
  static const String _topWordsKey = 'top using words';
  static const String _knownWordsKey = 'knownWords';

  Future<List<String>> fetchKnownWords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_knownWordsKey) ?? [];
  }

  Future<List<String>> fetchTopUsingWords() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(_topWordsKey) == null) {
      final contents =
          await rootBundle.loadString('assets/1000-most-common-words.txt');
      List<String> topWords = contents.split(RegExp(r'\s+'));
      await prefs.setStringList(_topWordsKey, topWords);
      return topWords;
    }
    return prefs.getStringList(_topWordsKey)!;
  }
}
