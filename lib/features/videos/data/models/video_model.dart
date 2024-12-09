import 'package:mxplayer/features/videos/data/entities/video_entity.dart';


class VideoModel {
  static Video fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'] ,
      displayName: map['name'] ,
      duration: map['duration'] ,
      size: map['size'] ,
      path: map['path'] ,
      dateAdded: map['dateAdded']
    );
  }

  static List<Video> fromMapList(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) => fromMap(map)).toList();
  }
    static Map<String, dynamic> toMap(Video video) {
    return {
      'id': video.id,
      'name': video.displayName,
      'duration': video.duration,
      'size': video.size,
      'path': video.path,
      'dateAdded': video.dateAdded,
    };
  }
}