import 'dart:typed_data';

class VideoAndThumbnails {
  final String path;
  final Uint8List thumbnail;

  VideoAndThumbnails({required this.path, required this.thumbnail});
}
