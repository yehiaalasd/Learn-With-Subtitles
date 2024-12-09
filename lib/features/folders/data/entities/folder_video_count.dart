import 'package:mxplayer/core.dart';

class FolderWithVideos {
  final String folderName;
  final List<Video> videos;

  FolderWithVideos({required this.folderName, required this.videos});

  int get videoCount => videos.length;
}
