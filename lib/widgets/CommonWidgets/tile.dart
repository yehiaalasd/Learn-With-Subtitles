import 'dart:typed_data';
import 'package:flutter/material.dart';

ListTile tiles(String name, String videos, void Function()? onTap,
    Uint8List thumb, bool isFolder) {
  return ListTile(
    onTap: onTap,
    leading: isFolder
        ? Icon(Icons.folder, size: 65, color: Colors.blue.shade400)
        : thumb.isEmpty
            ? Icon(Icons.video_file, size: 30, color: Colors.blue.shade400)
            : SizedBox(
                height: 100,
                width: 100,
                child: Image.memory(
                  thumb,
                  fit: BoxFit.contain,
                ),
              ),
    title: Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(
        name,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
            fontFamily: "fantasy"),
      ),
    ),
    subtitle: Text(videos,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey)),
  );
}
