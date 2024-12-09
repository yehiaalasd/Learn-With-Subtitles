import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mxplayer/core.dart';
import 'package:mxplayer/features/video_player/data/entities/subtitles.dart';
import 'package:mxplayer/features/video_player/data/model/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoWithSubtitlesModel {
  VideoWithSubtitlesModel(
      {required this.videoPath,
      required BuildContext context,
      required this.model}) {
    videoWithSubtitles = VideoWithSubtitles(video: videoPath);
    getEmbededSubtitle();
    getSubtitles();
  }

  final KnownWordsModel model;
  final String videoPath;
  late VideoWithSubtitles videoWithSubtitles;

  Future<List<String>?> getSubtitlePaths() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? subsPath = prefs.getStringList('${videoPath}srt list');
    return subsPath;
  }

  void getEmbededSubtitle() async {
    String embededSub =
        await SubtitleRepositoryImpl().subtitleExists(videoPath);
    print('${embededSub}embeded sub');
    addNewSubtitle(embededSub);
  }

  void getSubtitles() async {
    List<String> subtitlePaths = await getSubtitlePaths() ?? [];
    for (String path in subtitlePaths) {
      addNewSubtitle(path);
    }
  }

  void addNewSubtitle(String path) async {
    if (videoWithSubtitles.subtitles
        .where((sub) => sub.subtitlePath == path)
        .toList()
        .isEmpty) {
      List<Subtitle> subtitles =
          await SubtitleRepositoryImpl().fetchSubtitles(path, model);

      videoWithSubtitles.subtitles.add(Subtitles(subtitles, path, model));
      videoWithSubtitles.sortByArabic();
    }
  }

  bool isTranslating = false;

  String api1 = "AIzaSyCixWIj8CMcxM6K6iPAv4jTufdW2sqkmd8";
// String api2 = "AIzaSyCs14knJ8D6KEOSL-6dnvaY0S0I5HnUJco";
// String api3 = "AIzaSyDe81_deSVlt8EyeX8r9st8BZtOcxZcimo";

  Future<void> translateSrtByAI(Subtitles subtitle) async {
    isTranslating = true;
    String source = subtitle.isArabic ? 'arabic' : 'english';
    String dest = subtitle.isArabic ? 'english' : 'arabic';

    // String subtitleText =
    //     await SubtitleMethods().readSubtitleFile(subtitle.subtitlePath);
    List<String> subs = _createSubtitleBatches(subtitle.subtitle, dest, source);

    List<String> translatedSubs = await _translateSubtitles(subs, source, dest);
    List<Subtitle> translatedSubtitleObjects =
        _createTranslatedSubtitleObjects(translatedSubs, subtitle.subtitle);

    String srtContent = _convertToSrt(translatedSubtitleObjects);
    await _saveTranslatedSrt(subtitle.subtitlePath, srtContent);

    SubtitleRepositoryImpl().saveSubtitlePath(
        videoPath, subtitle.subtitlePath.replaceAll('.srt', '_translated.srt'));
    addNewSubtitle(subtitle.subtitlePath.replaceAll('.srt', '_translated.srt'));
    isTranslating = false;
  }

  List<String> _createSubtitleBatches(
      List<Subtitle> subtitles, String dest, String source) {
    List<String> batches = [];
    StringBuffer batch = StringBuffer();
    int index = 0;

    for (Subtitle sub in subtitles) {
      batch.writeln('${index}: ${sub.text}');
      index++;

      if (index % 10 == 0 || index == subtitles.length) {
        batches.add(batch.toString());
        batch.clear();
      }
    }

    return batches;
  }

  Future<List<String>> _translateSubtitles(
      List<String> subs, String source, String dest) async {
    List<String> translatedSubs = [];

    for (String text in subs) {
      print(text + ' this is the translate');
      String translation = await GeminiService.sendPrompt(
          " Translate this from $source to $dest and give me the translation just without any other word to tell me any thing just transltion:$text");
      print('${translation}this is trans');
      translatedSubs
          .addAll(translation.split('\n').map((line) => line.trim()).toList());
    }

    return translatedSubs;
  }

  List<Subtitle> _createTranslatedSubtitleObjects(
      List<String> translatedSubs, List<Subtitle> originalSubs) {
    List<Subtitle> translatedSubtitleObjects = [];

    for (int i = 0; i < originalSubs.length; i++) {
      String translatedText = translatedSubs[i].split(':').last.trim();
      translatedSubtitleObjects.add(Subtitle(
        text: translatedText,
        start: originalSubs[i].start,
        end: originalSubs[i].end,
      ));
    }

    return translatedSubtitleObjects;
  }

  String _convertToSrt(List<Subtitle> subtitles) {
    StringBuffer srtContent = StringBuffer();

    for (int i = 0; i < subtitles.length; i++) {
      final trans = subtitles[i];
      srtContent.writeln('${i + 1}');
      srtContent
          .writeln('${formatTime(trans.start)} --> ${formatTime(trans.end)}');
      srtContent.writeln(trans.text);
      srtContent.writeln(); // Blank line
    }

    return srtContent.toString();
  }

  Future<void> _saveTranslatedSrt(String path, String content) async {
    String translatedPath = path.replaceAll('.srt', '_translated.srt');
    File file = File(translatedPath);
    await file.writeAsString(content);
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds,000'; // SRT format requires milliseconds as well
  }
}
