import 'package:mxplayer/core.dart';

class VideoWithSubtitle {
  final String video;
  final List<Subtitle> subtitles;
  int? countKnownWords;

  VideoWithSubtitle(
      {required this.video, required this.subtitles, this.countKnownWords});
}
