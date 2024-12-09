import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';
import 'package:mxplayer/features/video_player/presentation/widgets/show_dialogs.dart';
import 'package:mxplayer/features/video_player/presentation/widgets/subdowndialog.dart';

class AppBarWidget extends StatefulWidget {
  final VideoPlayerViewModel model;
  final List<String> videoPaths;

  const AppBarWidget({
    Key? key,
    required this.model,
    required this.videoPaths,
  }) : super(key: key);

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  List<dynamic> _subtitles = [];

  Future<void> fetchSubtitlesFromSubscene(
      String movieName, String selectedLanguage) async {
    try {
      // Prepare the search URL
      final searchUrl =
          'https://subscene.com/subtitles/title?q=${Uri.encodeComponent(movieName)}';

      // Send the request
      final response = await http.get(Uri.parse(searchUrl));

      if (response.statusCode == 200) {
        // Parse the HTML response
        var document = html_parser.parse(response.body);
        var subtitleElements = document.querySelectorAll('tbody tr');

        // Extract subtitle information based on selected language
        List<Map<String, String>> subtitles = [];
        for (var element in subtitleElements) {
          var languageElement = element.querySelector('.a1');
          var downloadLinkElement =
              element.querySelector('a[href^="/subtitles/"]');

          if (languageElement != null && downloadLinkElement != null) {
            var language = languageElement.text.trim();
            var downloadLink =
                'https://subscene.com${downloadLinkElement.attributes['href']}';

            if (selectedLanguage == 'All' ||
                language.contains(selectedLanguage)) {
              // Add subtitle info to the list
              subtitles.add({
                'language': language,
                'link': downloadLink,
              });
            }
          }
        }

        setState(() {
          _subtitles = subtitles;
        });
        print('Fetched ${subtitles.length} subtitles');
      } else {
        throw Exception('Failed to load subtitles: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> downloadSubtitle(String downloadLink) async {
    Dio dio = Dio();
    try {
      await dio.download(downloadLink, 'path_to_save_subtitle.srt');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Download complete!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  void showSubtitleDialog() {
    showDialog(
      context: context,
      builder: (context) => SubtitleDialog(
        onFetch: fetchSubtitlesFromSubscene,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final bool showControls = widget.model.showControls;

    return Positioned(
      top: showControls ? 0 : 15,
      child: Container(
        width: width,
        height:
            width > height ? height * 0.15 : height * 0.08, // Adjusted height
        color: transparentBlack,
        child: Align(
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBackButton(context),
              _buildVideoTitle(),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  IconButton _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: white),
      onPressed: () => Navigator.pop(context),
    );
  }

  Text _buildVideoTitle() {
    final videoTitle = widget.videoPaths[widget.model.currentIndex]
        .split('/')
        .last
        .split('.')
        .first;

    return Text(
      videoTitle,
      style: const TextStyle(
          color: white, backgroundColor: Colors.transparent, fontSize: 18),
    );
  }

  Row _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildSubtitleButton(context),
        const SizedBox(width: 10),
        _buildMoreOptionsButton(),
        const SizedBox(width: 30),
      ],
    );
  }

  IconButton _buildSubtitleButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.subtitles, color: white),
      onPressed: () {
        widget.model.playPause();
        showSubtitleDownloadDialog(context, widget.model);
        widget.model.hideControls();
      },
    );
  }

  IconButton _buildMoreOptionsButton() {
    return IconButton(
      icon: const Icon(Icons.more_vert, color: white),
      onPressed: () {
        widget.model.extractSubtitles(
            widget.model.videoPaths[widget.model.currentIndex]);
        // showSubtitleDialog();
      },
    );
  }
}
