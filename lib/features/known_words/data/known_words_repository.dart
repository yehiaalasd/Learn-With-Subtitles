// lib/features/known_words/data/known_words_repository.dart

import 'known_words_data_source.dart';

class KnownWordsRepository {
  final KnownWordsDataSource _dataSource;

  KnownWordsRepository(this._dataSource);

  Future<List<String>> loadKnownWords() async {
    return await _dataSource.fetchKnownWords();
  }

  Future<List<String>> loadTopUsingWords() async {
    return await _dataSource.fetchTopUsingWords();
  }
}
