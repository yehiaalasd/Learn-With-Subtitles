import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mxplayer/utils/subtitle.dart';

class SubtitleMethods {
  Duration parseTime(String time) {
    final parts = time.split(RegExp(':|,'));
    return Duration(
      milliseconds: int.parse(time),
    );
  }
  // String getCurrentSubtitle(Duration position, List<Subtitle1> subtitles) {
  //   final currentPosition = position;
  //   for (final subtitle in subtitles) {
  //     if (currentPosition >= subtitle.start &&
  //         currentPosition <= subtitle.end) {
  //       return subtitle.text;
  //     }
  //   }
  //   return '';
  // }

  Future<String> readSubtitleFile(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final content = utf8.decode(bytes, allowMalformed: true);
      return content;
    } catch (e) {
      print('Error reading subtitle file: $e');
      return '';
    }
  }

  List<Subtitle1> parseSrt(String content) {
    final subtitles = <Subtitle1>[];
    final blocks = content.split('\n\n');

    for (final block in blocks) {
      final lines = block.split('\n');
      if (lines.length >= 3) {
        final startEnd = lines[1].split(' --> ');
        final startTime = parseTime(startEnd[0]);
        final endTime = parseTime(startEnd[1]);
        final text = lines.sublist(2).join(' ');
        subtitles.add(Subtitle1(startTime, endTime, text));
      }
    }
    return subtitles;
  }
  // Future<List<Subtitle1>> loadSubtitle(String videoPath) async {
  //   final srtPath = '${videoPath.substring(0, videoPath.length - 3)}srt';
  //   if (await File(srtPath).exists()) {
  //     final content = await readSubtitleFile(srtPath);
  //     return parseSrt(content);
  //   } else {
  //     print('Subtitle file does not exist at path: $srtPath');
  //     return [];
  //   }
  // }
}

void _showError(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.red))));
}

void _showSuccess(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.green))));
}
