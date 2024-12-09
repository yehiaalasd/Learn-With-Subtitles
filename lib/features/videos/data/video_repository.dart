import 'video_data_source.dart';

class VideoRepository {
  final VideoDataSource _dataSource;

  VideoRepository(this._dataSource);

  Future<List<Map<String, dynamic>>> getVideosByDirectory(
      String directory) async {
    List<Map<String, dynamic>> allVideos = await _dataSource.getVideos();
    return allVideos.where((map) {
      var one = map['path'].toString().split('/');
      one.removeLast();
      return one.last == directory.split('/').last;
    }).toList();
  }
}
