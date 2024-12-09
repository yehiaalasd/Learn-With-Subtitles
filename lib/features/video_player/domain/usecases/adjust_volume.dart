import '../repositories/video_repository.dart';

class AdjustVolume {
  final VideoRepository repository;

  AdjustVolume(this.repository);

  Future<void> call(double volume) async {
    return await repository.adjustVolume(volume);
  }
}
