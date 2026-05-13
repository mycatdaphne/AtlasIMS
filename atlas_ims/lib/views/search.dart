import 'package:flutter/material.dart';
import 'dart:io';
import 'package:atlas_ims/data/schema/entry.dart';
import 'package:go_router/go_router.dart';
import 'package:atlas_ims/data/firestore_storage.dart';

class AtlasSearch extends StatefulWidget {
  const AtlasSearch({super.key, required this.title, required this.db});

  final String title;
  final FirestoreStorage db;

  @override
  State<AtlasSearch> createState () => _AtlasSearchState();
}

class _AtlasSearchState extends State<AtlasSearch> {
  final _controller = TextEditingController();
  String _query = '';

  List<Entry> _filter(List<Entry> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((e) {
      if (e.name.toLowerCase().contains(q)) return true;
      if (e.tags.any((t) => t.name.toLowerCase().contains(q))) return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _controller,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Search by name or tag',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Entry>>(
            stream: widget.db.entriesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final all = snapshot.data!;
              final results = _filter(all);

              if (_query.isEmpty) {
                return const Center(
                  child: Text(
                    'Start typing to search',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              if (results.isEmpty) {
                return Center(
                  child: Text(
                    'No matches for "$_query"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                itemCount: results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final e = results[index];
                  return ListTile(
                    leading: _buildThumbnail(e.imagePath),
                    title: Text(e.name),
                    subtitle: e.tags.isEmpty
                        ? Text('Location ID: ${e.locationId}')
                        : Wrap(
                            spacing: 4,
                            children: [
                              for (final tag in e.tags.take(3))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tag.name,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                            ],
                          ),
                          onTap: () => context.push('/entries/${e.id}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
    // stolen from list.dart
    Widget _buildThumbnail(String? path) {
    const size = 48.0;

    if (path == null || path.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.image_not_supported,
            size: 24, color: Colors.grey),
      );
    }

    final file = File(path);
    if (!file.existsSync()) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.file(
        file,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}