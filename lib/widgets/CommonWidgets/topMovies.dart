import 'package:flutter/material.dart';

class topmovie extends StatelessWidget {
  final String? img;
  const topmovie({required this.img});
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    height = height / 100;
    width = width / 100;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 18 * height,
        width: 50 * width,
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(5),
            image: new DecorationImage(
                image: new AssetImage(img!), fit: BoxFit.fill)),
      ),
    );
  }
}
