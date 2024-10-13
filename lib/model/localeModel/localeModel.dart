import 'dart:io';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:mxplayer/utils/folder_info.dart';
import 'package:mxplayer/utils/getVideo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videoretriever/videoretriever.dart';

class LocaleModel with ChangeNotifier {
  List<FolderVideoCount> _folders = [];
  List<Map<String, dynamic>> _videos = [];
  List<String> _videosPaths = [];

  List<FolderVideoCount> get folders => _folders;
  List<String> get videosPaths => _videosPaths;

  List<Map<String, dynamic>> get videos => _videos;

  Future<void> loadVideos() async {
    bool x = false;
    x = await requestFilePermissions();
    List<Map<String, dynamic>> videos = await VideoRetriever.getAllVideos();
    List<String> paths = videos.map((map) => map['path'] as String).toList();
    _videosPaths = paths;
    _folders = countVideosByFolder(videos);
    _videos = videos;
    notifyListeners();
  }

  Future<bool> requestFilePermissions() async {
    PermissionStatus status = await Permission.storage.status;

    if (status.isDenied || status.isRestricted) {
      // Request permissions
      status = await Permission.storage.request();

      if (status.isDenied || status.isRestricted) {
        // Handle the case where the user denied or restricted permissions
        return false; // Permissions not granted
      }
    }
// Permissions granted
    return true;
  }

  Future<void> generateThumbnails(List<String> videoPaths) async {
    final plugin = FcNativeVideoThumbnail();
    final directory = await getApplicationDocumentsDirectory();
    final thumbnailFolder = Directory('${directory.path}/.thumbnails');

// Create the hidden thumbnail folder if it doesn't exist
    if (!await thumbnailFolder.exists()) {
      await thumbnailFolder.create(recursive: true);
    }

    for (String videoPath in videoPaths) {
      try {
        final videoFileName = videoPath.split('/').last;
        final thumbnailPath = '${thumbnailFolder.path}/$videoFileName.jpg';

        // Check if the thumbnail already exists
        if (await File(thumbnailPath).exists()) {
          print('Thumbnail already exists for $videoFileName');
          continue;
        }

        final thumbnailGenerated = await plugin.getVideoThumbnail(
          srcFile: videoPath,
          destFile: thumbnailPath,
          width: 300,
          height: 300,
          format: 'jpeg',
          quality: 90,
        );

        if (thumbnailGenerated) {
          print('Thumbnail generated for $videoFileName');
        } else {
          print('Failed to generate thumbnail for $videoFileName');
        }
      } catch (err) {
        print('Error generating thumbnail for $videoPath: $err');
      }
    }
  }
}
