import 'package:mxplayer/features/folders/data/folder_video_count.dart';

abstract class FolderRepository {
  Future<List<FolderWithVideos>> fetchFolders();
}
