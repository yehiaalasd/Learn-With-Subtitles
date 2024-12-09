class FolderWithVideos {
  final String folderName;
  final List<Map<String, dynamic>> videos;

  FolderWithVideos({required this.folderName, required this.videos});

  int get videoCount => videos.length;
}
