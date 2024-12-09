import 'package:flutter/material.dart';
import 'package:mxplayer/core.dart';
import 'package:mxplayer/features/known_words/domain/dictionary_repository.dart';

class KnownWordsModel with ChangeNotifier {
  String _searchQuery = '';
  bool _isSearching = false;
  List<String> _filteredWords = [];
  KnownWordsRepository knownWordsRepository;
  DictionaryRepository dictionaryRepository;
  KnownWordsModel(this.dictionaryRepository, this.knownWordsRepository) {
    getKnownAndTopUsingWord();
    notifyListeners();
  }

  getKnownAndTopUsingWord() async {
    await knownWordsRepository.loadKnownWords();
    await knownWordsRepository.loadTopUsingWords();
    notifyListeners();
  }

  List<String> get filteredWords => _filteredWords;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;


  void filterWords(String query) {
    _searchQuery = query;
    _filteredWords = knownWordsRepository.knownWords
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
    notifyListeners();
  }

  String prepareWord(String word) {
    String formattedWord =
        word[0].toUpperCase() + word.substring(1).toLowerCase();
    return formattedWord.endsWith('.')
        ? formattedWord.substring(0, formattedWord.length - 1)
        : formattedWord;
  }
}
