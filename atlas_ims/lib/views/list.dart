import 'package:flutter/material.dart';
import 'package:atlas_ims/data/firestore_storage.dart';
import 'package:atlas_ims/data/schema/entry.dart';
import 'package:atlas_ims/data/schema/location.dart';

class AtlasList extends StatefulWidget {
  const AtlasList({super.key, required this.title, required this.db});

  final String title;
  final FirestoreStorage db;

  @override
  State<AtlasList> createState() => _AtlasListState();
}

class _AtlasListState extends State<AtlasList> {
  String? _selectedLocationId;

  Widget _buildThumbnail(String? url) {
    const size = 48.0;

    if (url == null || url.isEmpty) {
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: size,
            height: size,
            color: Colors.grey.shade200,
          );
        },
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.broken_image,
              size: 24, color: Colors.grey),
        ),
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

        return StreamBuilder<List<InventoryLocation>>(
          stream: widget.db.locationsStream,
          builder: (context, locationSnapshot) {
            final locations =
                locationSnapshot.data ?? const <InventoryLocation>[];
            final selectedLocationId = locations.any((location) {
              return location.id != null && location.id == _selectedLocationId;
            })
                ? _selectedLocationId
                : null;
            final visibleEntries = selectedLocationId == null
                ? entries
                : entries
                    .where((entry) => entry.locationId == selectedLocationId)
                    .toList();

            return Column(
              children: [
                if (locations.isNotEmpty)
                  _buildLocationFilter(locations, selectedLocationId),
                Expanded(
                  child: visibleEntries.isEmpty
                      ? const Center(child: Text('No entries here yet.'))
                      : ListView.separated(
                          itemCount: visibleEntries.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final e = visibleEntries[index];
                            return Dismissible(
                              key: ValueKey(e.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child:
                                    const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Delete "${e.name}"?'),
                                    content: const Text('This cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
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
                                    SnackBar(
                                        content: Text('Deleted "${e.name}"')),
                                  );
                                }
                              },
                              child: ListTile(
                                leading: _buildThumbnail(e.imageUrl),
                                title: Text(e.name),
                                subtitle: Text(_subtitleFor(e)),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLocationFilter(
    List<InventoryLocation> locations,
    String? selectedLocationId,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DropdownButtonFormField<String>(
        initialValue: selectedLocationId ?? '',
        decoration: const InputDecoration(
          labelText: 'Location',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(
            value: '',
            child: Text('All locations'),
          ),
          for (final location in locations)
            if (location.id != null)
              DropdownMenuItem(
                value: location.id!,
                child: Text(location.name),
              ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedLocationId = value == '' ? null : value;
          });
        },
      ),
    );
  }

  String _subtitleFor(Entry entry) {
    final parts = [
      if (entry.location != null) entry.location!.name,
      if (entry.tags.isNotEmpty) entry.tags.map((t) => t.name).join(', '),
    ];
    return parts.isEmpty ? 'No location' : parts.join(' - ');
  }
}
