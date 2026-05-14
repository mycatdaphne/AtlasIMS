import 'package:flutter/material.dart';
import 'package:atlas_ims/data/schema/tag.dart';
import 'package:atlas_ims/data/firestore_storage.dart';

class TagPicker extends StatelessWidget {
  const TagPicker({
    super.key,
    required this.db,
    required this.selectedIds,
    required this.onChanged,
  });

  final FirestoreStorage db;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Tag>>(
      stream: db.tagsStream,
      builder: (context, snapshot) {
        final tags = snapshot.data ?? const <Tag>[];
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in tags)
              FilterChip(
                label: Text(tag.name),
                selected: selectedIds.contains(tag.id),
                onSelected: (sel) {
                  final next = Set<String>.from(selectedIds);
                  if (sel) {
                    if (tag.id != null) next.add(tag.id!);
                  } else {
                    next.remove(tag.id);
                  }
                  onChanged(next);
                },
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('New tag'),
              onPressed: () => _promptNewTag(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _promptNewTag(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tag name'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Add')),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    try {
      final newId = await db.addTag(name);
      onChanged({...selectedIds, newId});
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add tag: $e')),
        );
      }
    }
  }
}