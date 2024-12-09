import 'package:mxplayer/features/folders/data/folder_video_count.dart';
import 'package:mxplayer/features/folders/data/video_retriever_helper.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class FolderDataSource {
  Future<List<Map<String, dynamic>>> getVideos() async {
    return await VideoRetrieverHelper.getAllVideos(); // Use the cached videos
  }

  Future<List<FolderWithVideos>> getFolders() async {
    final hasPermission = await requestFilePermissions();
    if (!hasPermission.first) {
      throw Exception("Storage permission not granted");
    }

    final videos = await getVideos();
    // Retrieve videos using the helper
    if (!hasPermission.last) {
      await Permission.mediaLibrary.request();
    }
    return getVideosByFolder(videos);
  }

  Future<List<bool>> requestFilePermissions() async {
    // Request storage permissions
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus.isDenied || storageStatus.isRestricted) {
      storageStatus = await Permission.storage.request();
      if (storageStatus.isDenied || storageStatus.isRestricted) {}
    }

    // Request manage external storage permissions
    PermissionStatus manageStorageStatus =
        await Permission.manageExternalStorage.status;
    if (manageStorageStatus.isDenied || manageStorageStatus.isRestricted) {
      manageStorageStatus = await Permission.manageExternalStorage.request();
      if (manageStorageStatus.isDenied || manageStorageStatus.isRestricted) {}
    }

    return [
      storageStatus.isGranted,
      manageStorageStatus.isGranted
    ]; // Both permissions granted
  }

  List<FolderWithVideos> getVideosByFolder(
      List<Map<String, dynamic>> videoPaths) {
    final Map<String, List<Map<String, dynamic>>> folderVideos = {};

    for (Map<String, dynamic> path in videoPaths) {
      if (path.containsKey('path') && path['path'] is String) {
        final directory = dirname(path['path']);
        folderVideos[directory] = (folderVideos[directory] ?? [])..add(path);
      }
    }

    return folderVideos.entries.map((entry) {
      final List<Map<String, dynamic>> x = entry.value;
      return FolderWithVideos(folderName: entry.key, videos: x);
    }).toList();
  }
}

List<FolderWithVideos> getVideosByFolder(List<Map<String, dynamic>> videos) {
  final Map<String, List<Map<String, dynamic>>> folderVideos = {};

  for (Map<String, dynamic> video in videos) {
    if (video.containsKey('path') && video['path'] is String) {
      final directory = dirname(video['path']);
      folderVideos[directory] = (folderVideos[directory] ?? [])..add(video);
    }
  }

  return folderVideos.entries.map((entry) {
    List<Map<String, dynamic>> xx = entry.value;

    return FolderWithVideos(folderName: entry.key, videos: xx);
  }).toList();
}
