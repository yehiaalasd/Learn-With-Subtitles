import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mxplayer/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class SubtitleViewModel {
  SubtitleViewModel(String videoPath, int index) {
    this.videoPath = videoPath; // Correctly set the videoPath
    indexOfVide = index;
  }
  int indexOfVide = 0;
  String videoPath = '';
  int knownWordsCount = 0;
  bool _isShowSubtitlePermenant = true;
  bool _isShowedOriginalSubtitle = true;
  List<Subtitle> _subtitleWithoutKnownWords = [];
  Offset _subtitleOffset = const Offset(0, 60);
  String _subtitlePath = '';
  String _subtitleText = '';
  List<Subtitle> _subtitles = [];
  bool _isSubtitleVisibleTemporary = true;
  bool get isShowSubtitlePermenant => _isShowSubtitlePermenant;
  String get subtitleText => _subtitleText;
  Offset get subtitleOffset => _subtitleOffset;
  String get subtitlePath => _subtitlePath;
  List<Subtitle> get subtitleWithoutKnownWords => _subtitleWithoutKnownWords;
  bool get isShowOriginalSubtitle => _isShowedOriginalSubtitle;
  List<Subtitle> get subtitles => _subtitles;
  bool get isSubtitleVisibleTemporary => _isSubtitleVisibleTemporary;
  final SubtitleRepositoryImpl subtitleRepositoryImpl =
      SubtitleRepositoryImpl();
  void loadIsVisibleSubtitle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isShowSubtitlePermenant =
        prefs.getBool('is visible subtitle :$videoPath') ?? true;
  }

  void setSubtitlePath(String subPath) {
    _subtitlePath = subPath;
  }

  void updateSubtitle(VideoPlayerController controller) async {
    if (_isShowSubtitlePermenant) {
      var pos = await controller.position;
      if (pos != null && _subtitles.isNotEmpty) {
        _subtitleText = _getCurrentSubtitle(pos);
      }
    }
  }

  void showOriginalSubtitle() {
    _isShowedOriginalSubtitle = !_isShowedOriginalSubtitle;
  }

  String filterString(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').toLowerCase();
  }

  void autoSearchAboutSrt() async {
    String srtPath = await SubtitleRepositoryImpl().getSubtitlePath(videoPath);

    if (await File(srtPath).exists()) {
      _subtitlePath = srtPath;
    } else if (await SubtitleRepositoryImpl().subtitleExists(videoPath)) {
      _subtitlePath = '${videoPath.substring(0, videoPath.length - 3)}srt';
      SubtitleRepositoryImpl().saveSubtitlePath(videoPath, _subtitlePath);
    }
  }

  Future<void> getSubtitles(KnownWordsModel model) async {
    loadIsVisibleSubtitle();
    if (_isShowSubtitlePermenant) {
      autoSearchAboutSrt();

      if (_subtitlePath.isNotEmpty) {
        _subtitles =
            await SubtitleRepositoryImpl().fetchSubtitles(_subtitlePath, model);
      }
    } else {
      _isShowSubtitlePermenant = false;
    }
  }

  void removeKnownWordsFromSubtitles(KnownWordsModel knownWordsModel) {
    knownWordsModel.loadKnownWords();
    knownWordsModel.loadWordsFromAsset();

    List<String> words = [
      ...knownWordsModel.knownWords,
      ...knownWordsModel.topUsingWords
    ];

    if (_subtitleWithoutKnownWords.isEmpty || knownWordsCount == 0) {
      _subtitleWithoutKnownWords = _censorSubtitles(words);
    } else if (words.length > knownWordsCount) {
      _subtitleWithoutKnownWords = _censorSubtitles(words);
    }

    knownWordsCount = words.length;
  }

  List<Subtitle> _censorSubtitles(List<String> words) {
    return _subtitles.map((subtitle) {
      String censoredText = filterString(subtitle.text).split(' ').map((word) {
        return words.contains(filterString(word)) ? '***' : word;
      }).join(' ');
      return Subtitle(
        start: subtitle.start,
        end: subtitle.end,
        text: censoredText,
      );
    }).toList();
  }

  void onSubtitleDragUpdate(DragUpdateDetails details) {
    _subtitleOffset += Offset(0, details.delta.dy);
  }

  String _getCurrentSubtitle(Duration currentTime) {
    List<Subtitle> activeSubtitles = _isShowedOriginalSubtitle
        ? _subtitles
        : _subtitleWithoutKnownWords.isNotEmpty
            ? _subtitleWithoutKnownWords
            : _subtitles;

    for (Subtitle subtitle in activeSubtitles) {
      if (currentTime >= subtitle.start && currentTime <= subtitle.end) {
        return subtitle.text;
      }
    }
    return '';
  }

  void showSubtitlePermanent() async {
    _isShowSubtitlePermenant = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is visible subtitle :$videoPath', true);
  }

  void hideSubtitlePermanent() async {
    _isShowSubtitlePermenant = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is visible subtitle :$videoPath', false);
  }

  void showSubtitleTemporary() {
    if (_isShowSubtitlePermenant) {
      _isSubtitleVisibleTemporary = true;
    }
  }

  void hideSubtitleTemporary() {
    _subtitleText = '';
    _isSubtitleVisibleTemporary = false;
  }
}
