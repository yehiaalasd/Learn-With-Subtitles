import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/features/folders/data/folder_video_count.dart';
import 'package:mxplayer/features/folders/domain/get_folder_videos.dart';
import 'package:mxplayer/features/folders/presentation/widgets/tile.dart';
import 'package:mxplayer/features/videos/presentation/video_list_screen.dart';
import 'package:provider/provider.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  Future<List<FolderWithVideos>>? _loadFoldersFuture;

  @override
  void initState() {
    super.initState();
    final model = Provider.of<GetFolderVideos>(context, listen: false);
    _loadFoldersFuture = model.execute(); // Fetch folders
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder<List<FolderWithVideos>>(
        future: _loadFoldersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error loading folders: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No folders found.'));
          } else {
            final folders = snapshot.data!;
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                Color color = colorPalette[index % colorPalette.length];
                return SizedBox(
                  child: Tile(
                    name: folders[index].folderName.split('/').last,
                    videos: folders[index].videoCount.toString(),
                    onTap: () {
                      navigateToVideoListScreen(index, folders);
                    },
                    folderColor: color,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void navigateToVideoListScreen(
      int folderIndex, List<FolderWithVideos> folders) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoListScreen(
          folder: folders[folderIndex],
        ),
      ),
    ).then((_) {
      // Lock the orientation again when returning to FolderScreen
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });
  }
}
