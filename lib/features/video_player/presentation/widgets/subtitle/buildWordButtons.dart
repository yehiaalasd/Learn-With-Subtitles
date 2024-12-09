import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/features/known_words/domain/known_words_model.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';
import 'package:mxplayer/features/video_player/presentation/widgets/show_dialogs.dart';
import 'package:provider/provider.dart';

class WordButtons extends StatefulWidget {
  final VideoPlayerViewModel model;
  final KnownWordsModel provider;
  final bool isSecondSub;
  const WordButtons(
      {super.key,
      required this.model,
      required this.provider,
      required this.isSecondSub});

  @override
  _WordButtonsState createState() => _WordButtonsState();
}

class _WordButtonsState extends State<WordButtons> {
  String? translate;
  @override
  Widget build(BuildContext context) {
    final currentSub = !widget.isSecondSub
        ? widget.model.subtitleViewModel
            .firstWhere(
              (data) => data.indexOfVide == widget.model.currentIndex,
            )
            .subtitleViewDataFirst
        : widget.model.subtitleViewModel
            .firstWhere(
              (data) => data.indexOfVide == widget.model.currentIndex,
            )
            .subtitleViewDataSecond;
    final provider = Provider.of<KnownWordsModel>(context, listen: true);
    final subtitleText =
        widget.model.showDuration ? '' : currentSub.subtitleText;
    final words = subtitleText.split(' '); // Split by spaces to get full words
    final fontSize = MediaQuery.of(context).size.width < 600 ? 18.0 : 24.0;
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: width > MediaQuery.of(context).size.height
              ? width * 0.65
              : width * 0.70,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: words.map((word) {
                return TextSpan(
                  text: '$word ',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: white,
                    backgroundColor: transparentBlack,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _handleWordTap(word, provider, currentSub.isArabic);
                    },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _handleWordTap(String word, KnownWordsModel provider, bool isAr) {
    if (!isAr) {
      if (!word.contains('***')) {
        widget.model.playPause();
        translate = provider.searchInDictionary(word);
        if (translate != null) {
          showTranslationDialogFun(context, widget.model, translate!, word);
        } else {
          print('Translation not found for: $word');
        }
      }
    }
  }
}
