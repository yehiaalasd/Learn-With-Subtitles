abstract class VideoRepository {
  Future<void> loadVideo(String path);
  Future<void> playVideo();
  Future<void> adjustVolume(double volume);
}
