// lib/features/folders/domain/get_folder_videos.dart

import 'dart:io';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:mxplayer/features/folders/data/folderRepository.dart';
import 'package:mxplayer/features/folders/data/folder_video_count.dart';
import 'package:path_provider/path_provider.dart';

class GetFolderVideos {
  final FolderRepository repository;

  GetFolderVideos(this.repository);

  Future<List<FolderWithVideos>> execute() {
    return repository.fetchFolders();
  }

  Future<void> generateThumbnails(List<String> videoPaths) async {
    final plugin = FcNativeVideoThumbnail();
    final directory = await getApplicationDocumentsDirectory();
    final thumbnailFolder = Directory('${directory.path}/.thumbnails');
    if (!await thumbnailFolder.exists()) {
      await thumbnailFolder.create(recursive: true);
    }
    for (String videoPath in videoPaths) {
      try {
        final videoFileName = videoPath.split('/').last;
        final thumbnailPath = '${thumbnailFolder.path}/$videoFileName.jpg';

        if (await File(thumbnailPath).exists()) {
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
        } else {}
      } catch (err) {}
    }
  }
}
