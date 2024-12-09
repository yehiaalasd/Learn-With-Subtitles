import '../repositories/video_repository.dart';

class PlayVideo {
  final VideoRepository repository;

  PlayVideo(this.repository);

  Future<void> call() async {
    return await repository.playVideo();
  }
}
