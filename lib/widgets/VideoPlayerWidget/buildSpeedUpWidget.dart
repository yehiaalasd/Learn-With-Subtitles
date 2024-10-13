import 'dart:ui';

import 'package:flutter/material.dart';

Widget buildSpeedUpWidget(BuildContext context) {
  return Positioned(
    top: 100,
    left: MediaQuery.of(context).size.width * 0.5,
    child: const Row(
      children: [
        Text(
          '2X',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        SizedBox(
          width: 7,
        ),
        Icon(
          Icons.fast_forward,
          color: Colors.white,
          size: 30,
        )
      ],
    ),
  );
}
