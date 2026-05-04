import 'package:flutter/material.dart';
import 'package:atlas_ims/data/sqlstorage.dart';
import 'package:atlas_ims/data/schema/entry.dart';

class AtlasList extends StatefulWidget {
  const AtlasList({super.key, required this.title, required this.db});

  final String title;
  final Sqlstorage db;

  @override
  State<AtlasList> createState() => _AtlasListState();
}

class _AtlasListState extends State<AtlasList> {
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
                leading: CircleAvatar(child: Text('${e.id}')),
                title: Text(e.name),
                subtitle: Text('Location ID: ${e.locationId}'),
              ),
            );
          },
        );
      },
    );
  }
}