import 'package:flutter/material.dart';
import 'package:mxplayer/model/VideoPlayerModel/VideoPlayerModel.dart';
import 'package:mxplayer/model/knownWordsModel/knownWordsModel.dart';
import 'package:mxplayer/model/localeModel/localeModel.dart';
import 'package:mxplayer/views/homeScreen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => KnownWordsModel()),
        ChangeNotifierProvider(
            create: (context) => VideoPlayerModel(
                  [],
                  0,
                  context,
                )),
        ChangeNotifierProvider(create: (context) => LocaleModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
