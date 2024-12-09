// lib/features/folders/data/folder_repository_impl.dart

import 'package:mxplayer/features/folders/data/folderRepository.dart';
import 'package:mxplayer/features/folders/data/entities/folder_video_count.dart';

import '../data/folder_data_source.dart';

class FolderRepositoryImpl implements FolderRepository {
  final FolderDataSource dataSource;

  FolderRepositoryImpl(this.dataSource);

  @override
  Future<List<FolderWithVideos>> fetchFolders() {
    return dataSource.getFolders();
  }

  @override
  Future<void> generateThumbnails(List<FolderWithVideos> videos) async{
    dataSource.generateThumbnails(videos);
  } 
}
