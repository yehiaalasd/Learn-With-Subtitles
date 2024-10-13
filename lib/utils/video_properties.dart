import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void toggleFullscreen(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.portrait) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  } else {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }
}
