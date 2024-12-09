import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';

class SpeedUpWidget extends StatelessWidget {
  const SpeedUpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: MediaQuery.of(context).size.width * 0.5,
      child: const Row(
        children: [
          Text(
            '2X',
            style: TextStyle(color: white, fontSize: 24),
          ),
          SizedBox(
            width: 7,
          ),
          Icon(
            Icons.fast_forward,
            color: white,
            size: 30,
          )
        ],
      ),
    );
  }
}
