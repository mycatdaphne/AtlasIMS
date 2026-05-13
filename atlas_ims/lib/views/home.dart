import 'package:atlas_ims/views/search.dart';
import 'package:atlas_ims/views/list.dart';
import 'package:atlas_ims/views/settings.dart';
import 'package:atlas_ims/views/add.dart';
import 'package:atlas_ims/views/home_view.dart';
import 'package:atlas_ims/data/auth_service.dart';
import 'package:atlas_ims/data/firestore_storage.dart';
import 'package:flutter/material.dart';

class AtlasHome extends StatefulWidget {
  const AtlasHome({
    super.key,
    required this.title,
    required this.storage,
    required this.authService,
  });

  final String title;
  final FirestoreStorage storage;
  final AuthService authService;

  @override
  State<AtlasHome> createState() => _AtlasHomeState();
}

class _AtlasHomeState extends State<AtlasHome> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    AtlasHomeView(db: widget.storage),
    AtlasList(title: 'List', db: widget.storage),
    AtlasAdd(title: 'New Entry', db: widget.storage),
    AtlasSearch(title: 'Search', db: widget.storage),
    AtlasSettings(title: 'Settings', authService: widget.authService),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
        backgroundColor: Colors.lightBlue,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(
              icon: Icon(Icons.plus_one_rounded), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
