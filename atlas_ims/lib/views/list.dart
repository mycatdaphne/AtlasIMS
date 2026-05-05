import 'package:flutter/material.dart';
import 'package:atlas_ims/data/sqlstorage.dart';
import 'package:atlas_ims/data/schema/entry.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';


class AtlasList extends StatefulWidget {
  const AtlasList({super.key, required this.title, required this.db});

  final String title;
  final Sqlstorage db;

  @override
  State<AtlasList> createState() => _AtlasListState();
}

class _AtlasListState extends State<AtlasList> {

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
            return Dismissible(
              key: ValueKey(e.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Delete "${e.name}"?'),
                    content: const Text('This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) async {
                await widget.db.delEntry(e.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted "${e.name}"')),
                  );
                }
              },
              child: ListTile(
                leading: _buildThumbnail(e.imagePath),
                title: Text(e.name),
                subtitle: Text('Location ID: ${e.locationId}'),
                onTap: () => context.push('/entries/${e.id}'),
              ),
            );
          },
        );
      },
    );
  }
}