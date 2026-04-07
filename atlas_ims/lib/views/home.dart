import 'package:atlas_ims/views/search.dart';
import 'package:flutter/material.dart';

class AtlasHome extends StatefulWidget {
  const AtlasHome({super.key, required this.title});

  final String title;

  @override
  State<AtlasHome> createState() => _AtlasHomeState();
}

class _AtlasHomeState extends State<AtlasHome> {
  // int _counter = 0;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Home')),
    const AtlasSearch(title: 'Search'),
    const Center(child: Text('#3')),
  ];

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  //   print('_counter after: $_counter');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
    ),
    body: IndexedStack(
      index: _selectedIndex,
      children: _pages,
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'List',
        ),
      ],
    )
    );
  }
}