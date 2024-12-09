import 'package:flutter/services.dart';
import 'package:mxplayer/services/get_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DictionaryDataSource {
  Future<String> searchInDB(String word, bool isEnglish) async {
    var cleanedWord = cleanText(word);

    String translation =
        await DatabaseAccess().searchWords(cleanedWord, isEnglish);
    return translation;
  }

  String cleanText(String input) {
    return input.replaceAll(RegExp(r'[?!,.]'), '');
  }

  // String _removeNonLettersAndOptionalSuffixes(String input) {
  //   return input.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  // }
}
