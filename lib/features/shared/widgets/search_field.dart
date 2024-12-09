// lib/widgets/AppBar/search_field.dart

import 'package:flutter/material.dart';
import 'package:mxplayer/constants.dart';

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search folders',
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search, color: white),
      ),
      style: const TextStyle(color: white),
    );
  }
}
