import 'package:flutter/material.dart';

OverlayEntry buildOverlayIcon(bool left) {
  return OverlayEntry(
    builder: (context) => Positioned(
      top: 50.0, // يمكنك تغيير هذا لتحديد مكان الظهور
      left: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Material(
        color: Colors.transparent,
        child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.black.withOpacity(0.7),
            child: Icon(
                left ? Icons.fast_forward_sharp : Icons.fast_rewind_sharp)),
      ),
    ),
  );
}
