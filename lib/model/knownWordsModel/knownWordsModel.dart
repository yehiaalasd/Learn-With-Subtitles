import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxplayer/model/knownWordsModel/topUsingWords.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class KnownWordsModel with ChangeNotifier {
  List<String> _knownWords = [];
  List<String> _filteredWords = [];
  List<String> _topUsingWords = [];
  List<String> _dictionary = [];

  String _searchQuery = '';
  bool _isSearching = false;

  KnownWordsModel() {
    loadKnownWords();
    _resetFilteredWords();
    loadWordsFromAsset();
    initializeDictionary();
  }

  List<String> get knownWords => _knownWords;
  List<String> get dictionary => _dictionary;
  List<String> get topUsingWords => _topUsingWords;
  List<String> get filteredWords => _isSearching ? _filteredWords : _knownWords;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  static const String _key = 'word_translation_list';

  Future<void> initializeDictionary() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(_key) == null) {
      List<String> wordsAndTranslations = await extractWordsAndTranslations();
      _dictionary = wordsAndTranslations;
      notifyListeners();
      await prefs.setStringList(_key, wordsAndTranslations);
    } else {
      _dictionary = await getWordsAndTranslations();
      notifyListeners();
    }
  }

  Future<List<String>> getWordsAndTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<List<String>> extractWordsAndTranslations() async {
    final sql = await rootBundle.loadString('assets/engAraDictionary.sql');
    List<String> lines = sql.split('\n');
    List<String> result = [];
    final RegExp regex = RegExp(r"\((\d+),\s*'([^']*)',\s*'([^']*)'\)");
    for (String line in lines) {
      final matches = regex.allMatches(line);
      for (final match in matches) {
        String englishWord = match.group(2) ?? '';
        String arabicTranslation = match.group(3) ?? '';
        result.add('$englishWord - $arabicTranslation');
      }
    }
    return result;
  }

  String removeNonLettersAndOptionalSuffixes(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  String searchInDictionary(String word) {
    var cleanedWord = removeNonLettersAndOptionalSuffixes(word);

    // Find exact matches first
    var exactMatches = _dictionary.where((entry) {
      var entryWord = entry.split('-').first.trim();
      return entryWord.toLowerCase() == cleanedWord.toLowerCase();
    }).toList();

    // Find partial matches
    var partialMatches = _dictionary.where((entry) {
      var entryWord = entry.split('-').first.trim();
      return entryWord.toLowerCase().contains(cleanedWord.toLowerCase()) &&
          entryWord.toLowerCase() != cleanedWord.toLowerCase();
    }).toList();

    // Combine exact matches and partial matches
    var results = [...exactMatches, ...partialMatches];

    if (results.isNotEmpty) {
      return results.map((trnslate) {
        var parts = trnslate.split('-');
        return '${parts.first.trim()} : ${parts.last.trim()}';
      }).join('\n');
    }

    return 'Not found';
  }

  List<String> toLowerCaseList(List<String> inputList) {
    return inputList.map((str) => str.toLowerCase()).toList();
  }

  Future<List<String>> loadKnownWords() async {
    print('i am in load known word');
    final prefs = await SharedPreferences.getInstance();
    _knownWords = [
      ...prefs.getStringList('knownWords') ?? [],
    ];
    notifyListeners();
    return _knownWords;
  }

  Future<List<String>> loadWordsFromAsset() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('top using words') == null) {
      final contents =
          await rootBundle.loadString('assets/1000-most-common-words.txt');

      _topUsingWords = toLowerCaseList(contents.split(RegExp(r'\s+')));
      await prefs.setStringList('top using words', _topUsingWords);
    } else {
      _topUsingWords = prefs.getStringList('top using words')!;
    }
    notifyListeners();
    return _topUsingWords;
  }

  Future<void> saveKnownWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('knownWords', toLowerCaseList(_knownWords));
  }

  void updateKnownWords(String word, bool isChecked) {
    print('iam in update known');
    if (isChecked) {
      if (!_knownWords.contains(word)) {
        _knownWords.add(word);
      }
    } else {
      _knownWords.remove(word);
    }
    notifyListeners();
    saveKnownWords();
    loadKnownWords();

    notifyListeners();
  }

  void filterWords(String query) {
    _searchQuery = query;
    _filteredWords = _knownWords
        .where((word) => word.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      _resetFilteredWords();
    }
    notifyListeners();
  }

  void _resetFilteredWords() {
    _filteredWords = [];
    _searchQuery = '';
  }

  String prepareWord(String word) {
    String formattedWord =
        word[0].toUpperCase() + word.substring(1).toLowerCase();
    return formattedWord.endsWith('.')
        ? formattedWord.substring(0, formattedWord.length - 1)
        : formattedWord;
  }

  Future<Object?> searchWordInDatabase(String word) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'dictionary.db');
    Database database = await openDatabase(path);
    try {
      final preparedWord = prepareWord(word);
      final results = await database.query(
        'engAraDictionary',
        where: 'eng LIKE ?',
        whereArgs: ['%$preparedWord%'],
        limit: 1,
      );
      if (results.isNotEmpty) {
        return results.first['ara']; // Return the Arabic translation
      } else {
        return 'Word not found';
      }
    } catch (e) {
      return 'Error occurred while searching: ${e.toString()}';
    } finally {
      await database.close();
    }
  }
}
