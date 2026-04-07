import 'package:flutter/material.dart';

class AtlasSettings extends StatefulWidget {
  const AtlasSettings({super.key, required this.title});

  final String title;

  @override
  State<AtlasSettings> createState() => _AtlasSettingsState();

}

class _AtlasSettingsState extends State<AtlasSettings> {
  @override

  Widget build(BuildContext context) {
    return Center(
      child: Text('Settings test'),
    );
  }
}