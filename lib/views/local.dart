import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxplayer/Details/Details.dart';
import 'package:mxplayer/model/localeModel/localeModel.dart';
import 'package:mxplayer/widgets/localeScreenWidget/buildTopMoviesSection.dart';
import 'package:mxplayer/widgets/localeScreenWidget/folderTile.dart';
import 'package:provider/provider.dart';
import 'package:mxplayer/views/videoListScreen.dart';

class Local extends StatefulWidget {
  @override
  _LocalState createState() => _LocalState();
}

class _LocalState extends State<Local> {
  Future<void>? _loadVideosFuture;

  @override
  void initState() {
    super.initState();
    final model = Provider.of<LocaleModel>(context, listen: false);
    _loadVideosFuture = model.loadVideos();
    model.generateThumbnails(model.videosPaths);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LocaleModel>(context);
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadVideosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error loading videos: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: model.folders.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return buildTopMoviesSection(movieslist(), context);
                } else {
                  return FolderTile(
                    folder: model.folders[index - 1],
                    onTap: () => navigateToVideoListScreen(index - 1, model),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  void navigateToVideoListScreen(int folderIndex, LocaleModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoListScreen(
          directory: model.folders[folderIndex].folderPath,
          filesList: model.videos,
        ),
      ),
    ).then((_) {
      // Lock the orientation again when returning to Local
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });
  }
}
