import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:atlas_ims/data/schema/location.dart';
import 'package:atlas_ims/data/schema/tag.dart';

class Entry {
  final String? id;
  final String name;
  final String? locationId;
  final InventoryLocation? location;
  final String? imagePath;
  final String? imageUrl;
  final List<String> tagIds;
  final List<Tag> tags;

  const Entry({
    this.id,
    required this.name,
    this.locationId,
    this.location,
    this.imagePath,
    this.imageUrl,
    this.tagIds = const [],
    this.tags = const [],
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location_id': locationId,
      'image_path': imagePath,
      'image_url': imageUrl,
      'tag_ids': tagIds,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory Entry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Entry(
      id: doc.id,
      name: data['name'] as String? ?? '',
      locationId: data['location_id']?.toString(),
      imagePath: data['image_path'] as String?,
      imageUrl: data['image_url'] as String?,
      tagIds: (data['tag_ids'] as List?)?.cast<String>() ?? const [],
      tags: const [], // resolved later by FirestoreStorage
    );
  }

  Entry withTags(List<Tag> resolvedTags) => Entry(
        id: id,
        name: name,
        locationId: locationId,
        location: location,
        imagePath: imagePath,
        imageUrl: imageUrl,
        tagIds: tagIds,
        tags: resolvedTags,
      );

  Entry withLocation(InventoryLocation? resolvedLocation) => Entry(
        id: id,
        name: name,
        locationId: locationId,
        location: resolvedLocation,
        imagePath: imagePath,
        imageUrl: imageUrl,
        tagIds: tagIds,
        tags: tags,
      );

  @override
  String toString() =>
      'Entry(id: $id, name: $name, locationId: $locationId, tags: ${tags.length})';
}
