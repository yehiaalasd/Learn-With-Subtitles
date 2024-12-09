import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/features/known_words/domain/known_words_model.dart';
import 'package:provider/provider.dart';

class WordList extends StatefulWidget {
  final String word;

  const WordList({
    super.key,
    required this.word,
  });
  @override
  State<WordList> createState() => _WordListState();
}

class _WordListState extends State<WordList> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KnownWordsModel>(context);
    bool isKnown = provider.knownWords.contains(widget.word);

    return ListTile(
      title: Text(
        widget.word,
        style: const TextStyle(color: white),
      ),
      trailing: Checkbox(
        hoverColor: const Color(0xFF6B7682),
        focusColor: const Color(0xFF6B7682),
        activeColor: Colors.transparent,
        checkColor: indicatingColor, // Orange

        value: isKnown,
        onChanged: (isChecked) {
          setState(() {
            provider.updateKnownWords(widget.word, isChecked!);
          });
        },
      ),
    );
  }
}
