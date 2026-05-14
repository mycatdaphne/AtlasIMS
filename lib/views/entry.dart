import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:atlas_ims/data/firestore_storage.dart';
import 'package:atlas_ims/data/schema/entry.dart';

class AtlasEntryDetail extends StatelessWidget {
  const AtlasEntryDetail({
    super.key,
    required this.db,
    required this.entryId,
  });

  final FirestoreStorage db;
  final String entryId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Entry>>(
      stream: db.entriesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final entry = snapshot.data!
            .where((e) => e.id == entryId)
            .cast<Entry?>()
            .firstWhere((e) => true, orElse: () => null);

        if (entry == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Entry')),
            body: const Center(
              child: Text('Entry not found.',
                  style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(entry.name),
            backgroundColor: Colors.lightBlue,
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, entry),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(entry.imageUrl),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: entry.location?.name ?? 'No location',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tags',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (entry.tags.isEmpty)
                        const Text(
                          'No tags',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final tag in entry.tags)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(tag.name),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        height: 280,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported,
              size: 60, color: Colors.grey),
        ),
      );
    }
    return Image.network(
      url,
      height: 280,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 280,
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        height: 280,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Entry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${entry.name}"?'),
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
    if (ok != true) return;
    await db.delEntry(entry.id!);
    if (context.mounted) context.pop();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
