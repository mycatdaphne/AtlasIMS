import 'package:flutter/material.dart';
import 'package:atlas_ims/data/firestore_storage.dart';
import 'package:atlas_ims/data/schema/location.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({
    super.key,
    required this.db,
    required this.selectedId,
    required this.onChanged,
  });

  final FirestoreStorage db;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryLocation>>(
      stream: db.locationsStream,
      builder: (context, snapshot) {
        final locations = snapshot.data ?? const <InventoryLocation>[];
        final selectedValue = locations.any((location) {
          return location.id != null && location.id == selectedId;
        })
            ? selectedId!
            : '';
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedValue,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('No location'),
                  ),
                  for (final location in locations)
                    if (location.id != null)
                      DropdownMenuItem<String>(
                        value: location.id!,
                        child: Text(location.name),
                      ),
                ],
                onChanged: (next) => onChanged(next == '' ? null : next),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 56,
              height: 56,
              child: Tooltip(
                message: 'Add location',
                child: OutlinedButton(
                  onPressed: () => _promptNewLocation(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.add_location_alt_outlined),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _promptNewLocation(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New location'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Location name'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    try {
      final newId = await db.addLocation(name);
      onChanged(newId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add location: $e')),
        );
      }
    }
  }
}
