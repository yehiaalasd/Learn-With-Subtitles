// lib/features/folders/data/folder_repository_impl.dart

import 'package:mxplayer/features/folders/data/folderRepository.dart';
import 'package:mxplayer/features/folders/data/folder_video_count.dart';

import 'folder_data_source.dart';

class FolderRepositoryImpl implements FolderRepository {
  final FolderDataSource dataSource;

  FolderRepositoryImpl(this.dataSource);

  @override
  Future<List<FolderWithVideos>> fetchFolders() {
    return dataSource.getFolders();
  }
}
