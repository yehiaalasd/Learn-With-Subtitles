// lib/screens/video_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxplayer/widgets/videosListWidgets/videoTile.dart';

class VideoListScreen extends StatefulWidget {
  final String directory;
  final List<Map<String, dynamic>> filesList;

  const VideoListScreen({
    Key? key,
    required this.directory,
    required this.filesList,
  }) : super(key: key);

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<Map<String, dynamic>> videos = [];

  @override
  void initState() {
    super.initState();
    getVideos();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> getVideos() async {
    List<Map<String, dynamic>> vids = widget.filesList.where((map) {
      var one = map['path'].toString().split('/');
      one.removeLast();
      return one.last.toString() == widget.directory.split('/').last.toString();
    }).toList();
    setState(() {
      videos = vids;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        title: Text(
          widget.directory.split('/').last,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Icon(Icons.more_vert),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, i) {
            return VideoTile(initialIndex: i, videos: videos);
          },
        ),
      ),
    );
  }
}
