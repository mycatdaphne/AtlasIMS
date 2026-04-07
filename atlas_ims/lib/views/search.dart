import 'package:flutter/material.dart';

class AtlasSearch extends StatefulWidget {
  const AtlasSearch({super.key, required this.title});

  final String title;

  @override
  State<AtlasSearch> createState () => _AtlasSearchState();
}

class _AtlasSearchState extends State<AtlasSearch> {

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('search test'),
    );
  }
}