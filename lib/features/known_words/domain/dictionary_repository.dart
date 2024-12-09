import 'package:mxplayer/features/known_words/data/dictionary_data_source.dart';

class DictionaryRepository {
  final DictionaryDataSource _dataSource;
  DictionaryRepository(this._dataSource);

  Future<String> searchInDB(String word, bool isEn) async {
    String translate = await _dataSource.searchInDB(word, isEn);
    return translate;
  }
}
