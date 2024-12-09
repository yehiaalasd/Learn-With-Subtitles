import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/features/known_words/domain/known_words_model.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';
import 'package:provider/provider.dart';

class ShowTranslationDialog extends StatefulWidget {
  final String word;
  final String translate;
  final VideoPlayerViewModel model;

  const ShowTranslationDialog({
    super.key,
    required this.translate,
    required this.model,
    required this.word,
  });

  @override
  State<ShowTranslationDialog> createState() => _ShowTranslationDialogState();
}

class _ShowTranslationDialogState extends State<ShowTranslationDialog> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KnownWordsModel>(context);

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      child: SizedBox(
        width: width > height ? width * 0.4 : width * 0.7,
        height: width > height ? height * 0.7 : height * 0.45,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTranslationText(),
              const SizedBox(height: 16),
              _buildActionButtons(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationText() {
    return SizedBox(
      height: MediaQuery.of(context).size.height *
          (MediaQuery.of(context).size.width >
                  MediaQuery.of(context).size.height
              ? 0.45
              : 0.3),
      child: SingleChildScrollView(
        child: Text(
          widget.translate,
          style: const TextStyle(color: white),
        ),
      ),
    );
  }

  Widget _buildActionButtons(KnownWordsModel provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () async {
            _handleKnown(provider, true);
          },
          child: const Text('I Knew it'),
        ),
        ElevatedButton(
          onPressed: () async {
            _handleKnown(provider, false);
          },
          child: const Text('Not Known'),
        ),
      ],
    );
  }

  Future<void> _handleKnown(KnownWordsModel provider, bool isKnown) async {
    Navigator.pop(context);

    // Run the following in the background
    Future.microtask(() async {
      widget.model.controller.play(); // Play the video
      await provider.updateKnownWords(
          widget.word, isKnown); // Update known words
      final currentSubtitle = widget.model.subtitleViewModel.firstWhere(
        (data) => data.indexOfVide == widget.model.currentIndex,
      );
      currentSubtitle.subtitleViewDataFirst.setKnownWordsModel(provider);
      currentSubtitle.subtitleViewDataFirst.removeKnownWordsFromSubtitles();
    });
  }
}
