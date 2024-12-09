// lib/features/folders/data/video_retriever_helper.dart

import 'package:videoretriever/videoretriever.dart';

class VideoRetrieverHelper {
  static List<Map<String, dynamic>>? _cachedVideos; // Cache for videos

  static Future<List<Map<String, dynamic>>> getAllVideos() async {
    // Check if videos are already cached
    if (_cachedVideos != null) {
      return _cachedVideos!;
    }

    // If not cached, retrieve videos
    _cachedVideos = await VideoRetriever.getAllVideos(); // Call the plugin
    return _cachedVideos!;
  }

  static void clearCache() {
    _cachedVideos = null; // Method to clear the cache if needed
  }
}
