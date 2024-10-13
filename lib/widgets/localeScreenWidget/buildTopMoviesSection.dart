import 'package:flutter/material.dart';
import 'package:mxplayer/views/music.dart';

Widget buildTopMoviesSection(dynamic movies, BuildContext context) {
  return SizedBox(
    height: 180,
    child: ListView.builder(
      itemCount: movies.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => topmovie(img: movies[index].img),
    ),
  );
}
