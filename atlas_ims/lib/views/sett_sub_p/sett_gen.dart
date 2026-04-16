import 'package:flutter/material.dart';

class AtlasSettGen extends StatefulWidget {
  const AtlasSettGen({super.key, required this.title});

  final String title;

  @override
  State<AtlasSettGen> createState() => _AtlasSettGenState();
}

class _AtlasSettGenState extends State<AtlasSettGen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General')),
      body: const Center(child: Text('General Test')),
    );
  }
}