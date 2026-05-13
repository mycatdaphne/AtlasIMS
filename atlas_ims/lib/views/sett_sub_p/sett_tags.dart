import 'package:flutter/material.dart';
import 'package:atlas_ims/data/schema/tag.dart';
import 'package:atlas_ims/data/firestore_storage.dart';

class AtlasSettTags extends StatelessWidget {
  const AtlasSettTags({super.key, required this.db});

  final FirestoreStorage db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tags')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _promptAdd(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Tag>>(
        stream: db.tagsStream,
        builder: (context, snapshot) {
          final tags = snapshot.data ?? const <Tag>[];
          if (tags.isEmpty) {
            return const Center(child: Text('No tags yet.'));
          }
          return ListView.separated(
            itemCount: tags.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final tag = tags[i];
              return ListTile(
                title: Text(tag.name),
                subtitle: tag.isDefault ? const Text('Default') : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _promptRename(context, tag),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, tag),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _promptAdd(BuildContext context) async {
    final name = await _textDialog(context, title: 'New tag');
    if (name == null || name.trim().isEmpty) return;
    await db.addTag(name);
  }

  Future<void> _promptRename(BuildContext context, Tag tag) async {
    final name =
        await _textDialog(context, title: 'Rename tag', initial: tag.name);
    if (name == null || name.trim().isEmpty || name == tag.name) return;
    await db.renameTag(tag.id!, name);
  }

  Future<void> _confirmDelete(BuildContext context, Tag tag) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${tag.name}"?'),
        content: const Text(
            'This will remove the tag from all entries that use it.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) await db.delTag(tag.id!);
  }

  Future<String?> _textDialog(BuildContext context,
      {required String title, String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
  }
}