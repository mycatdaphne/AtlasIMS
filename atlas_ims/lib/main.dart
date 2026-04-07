import 'package:flutter/material.dart';
import 'views/home.dart';

void main() {
  runApp(const AtlasIMS());
}

class AtlasIMS extends StatelessWidget {
  const AtlasIMS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas IMS',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.lightBlue)),
      home: const AtlasHome(title: 'Atlas IMS'),
    );
  }
}
