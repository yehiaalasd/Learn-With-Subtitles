import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Drawer(
      child: Column(
        children: [
          Container(
            height: height * 0.25,
            color: Colors.blue,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(width * 0.05),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.userCircle,
                          size: height * 0.05, color: Colors.white),
                      SizedBox(width: width * 0.03),
                      Text("Sign In",
                          style: TextStyle(
                              fontSize: height * 0.03, color: Colors.white)),
                    ],
                  ),
                ),
                // Add more items here as in your original drawer
              ],
            ),
          ),
          // Add your other drawer items here
        ],
      ),
    );
  }
}
