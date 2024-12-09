// lib/features/folders/data/video_retriever_helper.dart

import 'package:videoretriever/videoretriever.dart';

class VideoRetrieverDataSource {
  static List<Map<String, dynamic>>? _cachedVideos; // Cache for videos
  static Future<List<Map<String, dynamic>>> getAllVideos() async {
    if (_cachedVideos != null) {
      return _cachedVideos!;
    }
    _cachedVideos = await VideoRetriever.getAllVideos();
    return _cachedVideos!;
  }

  static void clearCache() {
    _cachedVideos = null;
  }
}
