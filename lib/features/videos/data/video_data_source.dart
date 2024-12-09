import 'package:mxplayer/features/folders/data/video_retriever_helper.dart';
import 'package:videoretriever/videoretriever.dart';

class VideoDataSource {
  Future<List<Map<String, dynamic>>> getVideos() async {
    return VideoRetrieverHelper.getAllVideos(); // Use the plugin to get videos
  }
}
