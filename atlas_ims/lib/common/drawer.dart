import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AtlasDrawer extends StatelessWidget {
  const AtlasDrawer({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.lightBlue,
            padding: EdgeInsets.all(16),
            child: Text('Navigation', style: TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            selected: currentPage == 1,
            onTap: () {currentPage == 1 ? Navigator.pop(context) : context.go('/');}
          ),
        ]
      )
    );
  }
}