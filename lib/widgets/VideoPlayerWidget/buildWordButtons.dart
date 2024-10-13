import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mxplayer/model/VideoPlayerModel/VideoPlayerModel.dart';
import 'package:mxplayer/model/knownWordsModel/knownWordsModel.dart';
import 'package:mxplayer/widgets/VideoPlayerWidget/showTranslationDialog.dart';
import 'package:provider/provider.dart';

class WordButtons extends StatefulWidget {
  final VideoPlayerModel model;
  final KnownWordsModel provider;

  WordButtons({required this.model, required this.provider});

  @override
  _WordButtonsState createState() => _WordButtonsState();
}

class _WordButtonsState extends State<WordButtons> {
  String? translate;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KnownWordsModel>(context, listen: true);
    String text = !widget.model.showDuration ? widget.model.subtitleText : '';
    List<String> words = text.split(' '); // Split by spaces to get full words
    double fontSize = MediaQuery.of(context).size.width < 600 ? 18 : 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: words.map((word) {
                return TextSpan(
                  text: '$word ',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                    backgroundColor: Colors.black54,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (!word.contains('***')) {
                        widget.model.playPause();
                        translate = provider.searchInDictionary(word);
                        if (translate != null) {
                          showTranslationDialogFun(
                              context, widget.model, translate!, word);
                        } else {
                          print('Translation not found for: $word');
                        }
                      }
                    },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
