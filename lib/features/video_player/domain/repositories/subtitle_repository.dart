import 'package:mxplayer/core.dart';

abstract class SubtitleRepository {
  Future<String> getSubtitlePath(String videoPath);
  Future<void> saveSubtitlePath(String videoPath, String subtitlePath);
  Future<List<Subtitle>> fetchSubtitles(
      String subtitlePath, KnownWordsModel model);
  Future<bool> subtitleExists(String path);
}
