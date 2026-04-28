import 'package:flutter/material.dart';

class AtlasAdd extends StatefulWidget { 
  const AtlasAdd({super.key, required this.title});

  final String title;

  @override
  State<AtlasAdd> createState() => _AtlasAddState();

}

class _AtlasAddState extends State<AtlasAdd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add')),
      body: const Center(child: Text('Add')),
    );
  }
}