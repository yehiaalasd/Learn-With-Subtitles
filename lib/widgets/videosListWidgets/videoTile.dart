// lib/widgets/video_tile.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mxplayer/views/videoplayerscreen.dart';
import 'dart:io';

class VideoTile extends StatefulWidget {
  const VideoTile({
    Key? key,
    required this.initialIndex,
    required this.videos,
  }) : super(key: key);

  final List<Map<String, dynamic>> videos;
  final int initialIndex;

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  Future<Uint8List?> getThumbnailAsUint8List(String videoFileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final thumbnailPath = '${directory.path}/.thumbnails/$videoFileName.jpg';

    if (await File(thumbnailPath).exists()) {
      return await File(thumbnailPath).readAsBytes();
    } else {
      return null;
    }
  }

  Future<bool> isThereSrt(String videoFileName) async {
    final srtFile =
        '${videoFileName.substring(0, videoFileName.length - 3)}srt';
    return await File(srtFile).exists();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final videoPath =
        widget.videos[widget.initialIndex]['path'].toString().split('/').last;

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        getThumbnailAsUint8List(videoPath),
        isThereSrt(widget.videos[widget.initialIndex]['path']),
      ]),
      builder: (context, snapshot) {
        Widget leading;

        if (snapshot.connectionState == ConnectionState.waiting) {
          leading = Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8.0),
            ),
          );
        } else if (snapshot.hasError) {
          leading = const Icon(Icons.error);
        } else {
          final Uint8List? thumbnailData = snapshot.data![0];
          final bool hasSrt = snapshot.data![1];

          leading = thumbnailData != null
              ? Container(
                  height: 80,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Image.memory(
                    thumbnailData,
                    fit: BoxFit.fill,
                  ),
                )
              : const Icon(Icons.video_call);
        }

        String text =
            widget.videos[widget.initialIndex]['path'].split('/').last;
        int sizeInBytes = int.parse(widget.videos[widget.initialIndex]['size']);
        double sizeInMB = sizeInBytes / (1024 * 1024);

        return ListTile(
          title: Text(text.substring(0, text.length > 50 ? 50 : text.length)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${sizeInMB.toStringAsFixed(2)} MB'),
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data![1])
                Row(
                  children: [
                    Image.asset(
                      "assets/srt.png",
                      height: 20,
                      width: 30,
                    ),
                    const SizedBox(width: 4),
                    const Text('SRT available', style: TextStyle(fontSize: 12)),
                  ],
                ),
            ],
          ),
          leading: leading,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoPaths: widget.videos
                        .map((element) => element['path'] as String)
                        .toList(),
                    initialIndex: widget.initialIndex,
                  ),
                )).then((_) {
              // Lock the orientation again when returning to Local
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
            });
          },
        );
      },
    );
  }
}
