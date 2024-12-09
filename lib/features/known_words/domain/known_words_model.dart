import 'package:flutter/material.dart';
import '../data/known_words_repository.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KnownWordsModel with ChangeNotifier {
  List<String> _knownWords = [];
  Map<String, String> _contractions = {};
  List<String> _filteredWords = [];
  List<String> _topUsingWords = [];
  List<String> _dictionary = [];
  String _searchQuery = '';
  bool _isSearching = false;

  static const String _key = 'word_translation_list';
  static const String contractionKey = 'contractions';

  KnownWordsModel(KnownWordsRepository knownWordsRepository) {
    loadKnownWords();
    _resetFilteredWords();
    loadWordsFromAsset();
    initializeDictionary();
    initializeContractions();
  }

  List<String> get knownWords => _knownWords;
  Map<String, String> get contractions => _contractions;
  List<String> get dictionary => _dictionary;
  List<String> get topUsingWords => _topUsingWords;
  List<String> get filteredWords => _isSearching ? _filteredWords : _knownWords;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  Future<void> initializeDictionary() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(_key) == null) {
      List<String> wordsAndTranslations = await extractWordsAndTranslations();
      _dictionary = wordsAndTranslations;
      await prefs.setStringList(_key, wordsAndTranslations);
    } else {
      _dictionary = await getWordsAndTranslations();
    }
    notifyListeners();
  }

  Future<void> initializeContractions() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(contractionKey) == null) {
      _contractions = await extractContraction();
      await prefs.setStringList(contractionKey, _contractions.keys.toList());
    } else {
      _contractions = await getContractionFromDevice();
    }
    notifyListeners();
  }

  Future<Map<String, String>> getContractionFromDevice() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? contracts = prefs.getStringList(contractionKey);
    if (contracts == null) return {};

    return Map.fromIterable(contracts,
        key: (v) => v, value: (v) => _contractions[v] ?? '');
  }

  Future<Map<String, String>> extractContraction() async {
    final text = await rootBundle.loadString('assets/contraction.txt');
    List<String> lines = text.split('\n');
    Map<String, String> result = {};

    for (String line in lines) {
      if (line.isNotEmpty) {
        var parts = line.split(':');
        if (parts.length == 2) {
          String contraction = parts[0].trim().toLowerCase();
          String expansions = parts[1].trim().toLowerCase();
          result[contraction] =
              expansions.split('|').first.trim().toLowerCase();
        }
      }
    }
    return result;
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

  String replaceContractions(String text) {
    _contractions.forEach((key, value) {
      // Use regex to replace contractions, ensuring case insensitivity
      final pattern =
          RegExp(r'\b${RegExp.escape(key)}\b', caseSensitive: false);
      text = text.replaceAll(pattern, value);
    });
    return text;
  }

  String searchInDictionary(String word) {
    var cleanedWord = removeNonLettersAndOptionalSuffixes(word);
    var exactMatches = _dictionary.where((entry) {
      var entryWord = entry.split('-').first.trim();
      return entryWord.toLowerCase() == cleanedWord.toLowerCase();
    }).toList();

    var partialMatches = _dictionary.where((entry) {
      var entryWord = entry.split('-').first.trim();
      return entryWord.toLowerCase().contains(cleanedWord.toLowerCase()) &&
          entryWord.toLowerCase() != cleanedWord.toLowerCase();
    }).toList();

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

  Future<void> loadKnownWords() async {
    final prefs = await SharedPreferences.getInstance();
    _knownWords = prefs.getStringList('knownWords') ?? [];
    notifyListeners();
  }

  Future<void> loadWordsFromAsset() async {
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
  }

  Future<void> saveKnownWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('knownWords', toLowerCaseList(_knownWords));
  }

  Future<void> updateKnownWords(String word, bool isChecked) async {
    if (isChecked) {
      if (!_knownWords.contains(word)) {
        _knownWords.add(word);
      }
    } else {
      _knownWords.remove(word);
    }
    notifyListeners();
    await saveKnownWords();
    await loadKnownWords();
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
}
