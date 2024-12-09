// lib/features/known_words/data/known_words_repository.dart

import '../data/known_words_data_source.dart';

class KnownWordsRepository {
  final KnownWordsDataSource _dataSource;
  List<String> knownWords = [];
  List<String> topUsingWords = [];

  KnownWordsRepository(this._dataSource) {
    loadKnownWords();
    loadTopUsingWords();
  }

 Future< void> loadKnownWords() async {
    knownWords = await _dataSource.fetchKnownWords();
  }

   Future< void>  loadTopUsingWords() async {
    topUsingWords = await _dataSource.fetchTopUsingWords();
  }

  Future<void> updateKnownWords(bool isChecked, String word) async {
    _dataSource.updateKnownWords(knownWords, word, isChecked);
  }

  Future<void> saveKnownWords() async {
    _dataSource.saveKnownWords(knownWords);
  }
}
