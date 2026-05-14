import 'package:flutter/material.dart';
import 'package:atlas_ims/data/firestore_storage.dart';
import 'package:atlas_ims/data/schema/location.dart';

class AtlasSettLocations extends StatelessWidget {
  const AtlasSettLocations({super.key, required this.db});

  final FirestoreStorage db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Locations')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _promptAdd(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<InventoryLocation>>(
        stream: db.locationsStream,
        builder: (context, snapshot) {
          final locations = snapshot.data ?? const <InventoryLocation>[];
          if (locations.isEmpty) {
            return const Center(child: Text('No locations yet.'));
          }
          return ListView.separated(
            itemCount: locations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final location = locations[i];
              return ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(location.name),
                subtitle: location.address == null || location.address!.isEmpty
                    ? null
                    : Text(location.address!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _promptRename(context, location),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, location),
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
    final name = await _textDialog(context, title: 'New location');
    if (name == null || name.trim().isEmpty) return;
    await db.addLocation(name);
  }

  Future<void> _promptRename(
    BuildContext context,
    InventoryLocation location,
  ) async {
    final name = await _textDialog(
      context,
      title: 'Rename location',
      initial: location.name,
    );
    if (name == null || name.trim().isEmpty || name == location.name) return;
    await db.renameLocation(location.id!, name);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    InventoryLocation location,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${location.name}"?'),
        content: const Text(
          'This will remove the location from all entries that use it.',
        ),
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
    if (ok == true) await db.delLocation(location.id!);
  }

  Future<String?> _textDialog(
    BuildContext context, {
    required String title,
    String initial = '',
  }) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Location name'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
