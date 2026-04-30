import 'package:flutter/material.dart';

import 'package:atlas_ims/data/sqlstorage.dart';


class AtlasList extends StatefulWidget {
  const AtlasList ({super.key, required this.title});

  final String title;

  @override
  State<AtlasList> createState() => _AtlasListState();
}

class _AtlasListState extends State<AtlasList> {

  final _storage = Sqlstorage();
  
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('list test'),);
  }
}