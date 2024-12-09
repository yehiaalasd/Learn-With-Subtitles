import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/core.dart';
import 'package:mxplayer/features/videos/domain/video_list_model.dart';
import 'package:mxplayer/features/videos/presentation/widgets/video_app_bar.dart';
import 'package:mxplayer/features/videos/presentation/widgets/video_list.dart';
import 'package:provider/provider.dart';

class VideoListScreen extends StatefulWidget {
  final FolderWithVideos folder;

  const VideoListScreen({
    super.key,
    required this.folder,
  });
  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      lazy: true,
      create: (_) => VideoListModel(widget.folder),
      child: Consumer<VideoListModel>(builder: (context, model, child) {
        return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context);
              return true; // Allow pop
            },
            child: Scaffold(
              backgroundColor: backgroundColor,
              appBar: CustomAppBar(
                  model: model,
                  title: widget.folder.folderName.split('/').last,
                  onBackPressed: () {
                    Navigator.pop(context);
                  },
                  onSearchChanged: (s) {
                    model.updateSearchQuery(s);
                  }),
              body: SafeArea(
                child: Column(
                  children: [
                    if (model.isSelecting)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Checkbox(
                            value: model.selectedVideoIndices.length ==
                                model.videos.length,
                            onChanged: (value) {
                              setState(() {
                                model.toggleCheckbox(value);
                              });
                            },
                          ),
                          const Text('Select All'),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: model.deleteSelectedVideos,
                          ),
                        ],
                      ),
                    Expanded(
                        child: VideoList(
                      model: model,
                    )),
                  ],
                ),
              ),
            ));
      }),
    );
  }
}
