import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';

class Tile extends StatelessWidget {
  final String name;
  final String videos;
  final VoidCallback onTap;
  final Color folderColor;

  const Tile({
    super.key,
    required this.name,
    required this.videos,
    required this.onTap,
    this.folderColor = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.6,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
      decoration: BoxDecoration(
        color: elementColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.folder, size: 65, color: folderColor),
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE8E5EE),
              fontFamily: "fantasy",
            ),
          ),
        ),
        subtitle: Text(
          "$videos Videos",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF6B7682),
        ),
      ),
    );
  }
}
