import 'package:flutter/material.dart';

import 'package:atlas_ims/data/sqlstorage.dart';
import 'package:atlas_ims/data/schema/entry.dart';


class AtlasList extends StatefulWidget {
  const AtlasList ({super.key, required this.title, required this.db});

  final String title;
  final Sqlstorage db;

  @override
  State<AtlasList> createState() => _AtlasListState();
}

class _AtlasListState extends State<AtlasList> {

  final db = Sqlstorage();
  
@override
Widget build(BuildContext context) {
  return StreamBuilder<List<Entry>>(
    stream: widget.db.entriesStream,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final entries = snapshot.data!;
      if (entries.isEmpty) {
        return const Center(child: Text('No entries yet.'));
      }
      return ListView.separated(
        itemCount: entries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final e = entries[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${e.id}')),
            title: Text(e.name),
            subtitle: Text('Location ID: ${e.locationId}'),
          );
        },
      );
    },
  );
}
}