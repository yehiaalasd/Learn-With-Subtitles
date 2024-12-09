import 'package:mxplayer/features/video_player/data/entities/subtitles.dart';

class VideoWithSubtitles {
  final String video;
  final List<Subtitles> subtitles=[];

  VideoWithSubtitles(
      {required this.video, });
      void sortByArabic() {
  subtitles.sort((a, b) => (b.isArabic ? 1 : 0).compareTo(a.isArabic ? 1 : 0));

}

}
