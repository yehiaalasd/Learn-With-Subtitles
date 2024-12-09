import '../repositories/video_repository.dart';

class LoadVideo {
  final VideoRepository repository;

  LoadVideo(this.repository);

  Future<void> call(String path) async {
    return await repository.loadVideo(path);
  }
}
