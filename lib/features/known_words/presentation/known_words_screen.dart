// lib/features/known_words/presentation/known_words_screen.dart

import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/features/known_words/presentation/widgets/wordsList.dart';
import 'package:provider/provider.dart';
import '../domain/known_words_model.dart';

class KnownWordsScreen extends StatelessWidget {
  const KnownWordsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer<KnownWordsModel>(
        builder: (context, model, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: model.filteredWords.length,
                  itemBuilder: (context, index) {
                    return WordList(word: model.filteredWords[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
