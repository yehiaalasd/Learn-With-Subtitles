import 'package:flutter/material.dart';

Widget buildFastForwardIcon(bool isLeftSide) {
  return Align(
    alignment: isLeftSide ? Alignment.centerLeft : Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 120),
      child: Row(
        mainAxisAlignment:
            !isLeftSide ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Icon(
            !isLeftSide ? Icons.fast_forward_sharp : Icons.fast_rewind_sharp,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text('[5]', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
  );
}
