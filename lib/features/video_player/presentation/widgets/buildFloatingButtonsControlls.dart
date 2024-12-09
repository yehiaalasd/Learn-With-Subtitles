import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';

Widget buildFloatingIcon(Icon icon, void Function()? onPressed) {
  return Container(
    color: transparentBlack,
    child: IconButton(
      onPressed: onPressed,
      icon: icon,
      color: white,
    ),
  );
}

class BuildFloatingButtonIcons extends StatefulWidget {
  final VideoPlayerViewModel model;
  const BuildFloatingButtonIcons({super.key, required this.model});

  @override
  State<BuildFloatingButtonIcons> createState() =>
      _BuildFloatingButtonIconsState();
}

class _BuildFloatingButtonIconsState extends State<BuildFloatingButtonIcons> {
  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;
    return Positioned(
        left: 20,
        top: 50,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: transparentBlack,
                child: const Text(
                  '1X',
                  style: TextStyle(color: white, fontSize: 21),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              buildFloatingIcon(
                  const Icon(
                    Icons.headphones,
                    color: white,
                  ),
                  () {}),
              const SizedBox(
                width: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    color: widget.model.canRotation
                        ? Colors.blueAccent
                        : transparentBlack,
                    borderRadius: BorderRadius.circular(50)),
                child: buildFloatingIcon(
                    const Icon(
                      Icons.screen_rotation,
                      color: white,
                    ), () {
                  widget.model.toggleRotation();
                  setState(() {});
                }),
              ),
            ],
          ),
        ));
  }
}
