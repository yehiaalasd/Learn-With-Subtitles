import 'package:flutter/material.dart';
import 'package:mxplayer/core.dart';

class FolderViewModel extends ChangeNotifier {
  final FolderRepositoryImpl repository;

  FolderViewModel(this.repository);

  List<FolderWithVideos> _folderWithVideo = [];
  List<FolderWithVideos> get folderWithVideo => _folderWithVideo;
  Future<List<FolderWithVideos>> execute() async {
    _folderWithVideo = await repository.fetchFolders();
    return _folderWithVideo;
  }
  Future<void> generateThumbnails() async {
    repository.generateThumbnails(_folderWithVideo);
  }
  void navigateToVideoListScreen(int folderIndex, FolderViewModel model) {
    Get.to(
      VideoListScreen(
        model: model,
        indexOfFolder: folderIndex,
      ),
    );
  }
}
