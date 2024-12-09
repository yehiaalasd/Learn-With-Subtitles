import 'package:flutter/foundation.dart';
import 'package:mxplayer/features/known_words/presentation/model/known_words_model.dart';
import 'package:mxplayer/features/video_player/data/entities/subtitle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Subtitles {
  final List<Subtitle> subtitle;
  List<Subtitle> subtitleWithoutKnownWords = [];
  String subtitlePath = '';
  bool isEnabled = true;
  bool isArabic = false;
  late KnownWordsModel knownWordsModel;

  Subtitles(this.subtitle, this.subtitlePath, this.knownWordsModel) {
    isEnabledSub();
    isArabic = subtitle[0].isArabic!;
    if (!isArabic && subtitle.isNotEmpty) {
      removeKnownWordsFromSubtitles(); // This will run in the background
    }
  }

  // Subtitle currentSubtitle =
  //     Subtitle(text: '', start: const Duration(), end: const Duration());

  bool isLearningMode = false;

  void toggleLearningMode() {
    isLearningMode = !isLearningMode;
    if (isArabic) {
      isLearningMode = false;
    }
  }

  void enableSubtitle() async {
    isEnabled = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(subtitlePath, true);
  }

  void disableSubtitle() async {
    isEnabled = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(subtitlePath, false);
  }

  Future<bool?> isEnabledSub() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isEnable = prefs.getBool(subtitlePath) ?? false;
    isEnabled = isEnable;
    return isEnable;
  }

  int knownWordsCount = 0;

  bool get isEmpty => subtitle.isEmpty;

  bool get isNotEmpty => !isEmpty;

  void removeKnownWordsFromSubtitles() async {
    knownWordsModel.knownWordsRepository.loadKnownWords();
    knownWordsModel.knownWordsRepository. loadTopUsingWords();

    List<String> words = [
      ...knownWordsModel.knownWordsRepository. knownWords,
      ...knownWordsModel.knownWordsRepository. topUsingWords
    ];

    subtitleWithoutKnownWords =
        await compute(_processSubtitles, [subtitle, words]);

    knownWordsCount = words.length;
  }

  static Future<List<Subtitle>> _processSubtitles(List<Object> params) async {
    List<Subtitle> subtitles = params[0] as List<Subtitle>;
    List<String> words = params[1] as List<String>;

    return subtitles.map((subtitle) {
      String censoredText = subtitle.text.toLowerCase().split(' ').map((word) {
        return words.contains(word) ? '***' : word;
      }).join(' ');
      return Subtitle(
        start: subtitle.start,
        end: subtitle.end,
        text: censoredText,
      );
    }).toList();
  }

  String currnetSubtitleText = '';
void getByPosition(Duration position) {
  if (!isLearningMode) {
    if (subtitle.isEmpty) {
      currnetSubtitleText = 'No subtitles available';
      return;
    }
    currnetSubtitleText = subtitle.firstWhere(
      (item) => position >= item.start && position <= item.end,
      orElse: () => Subtitle(text: '',start: Duration(),end: Duration()),
    ).text;
  } else {
    if (subtitleWithoutKnownWords.isEmpty) {
      currnetSubtitleText = 'No subtitles available';
      return;
    }
    currnetSubtitleText = subtitleWithoutKnownWords.firstWhere(
      (item) => position >= item.start && position <= item.end,
      orElse: () => Subtitle(text: '',start: Duration(),end: Duration()),
    ).text;
  }
}
}
