import 'package:atlas_ims/data/schema/tag.dart';

class Entry{
  final int? id;
  final String name;
  final int locationId;
  final String? imagePath;
  final List<Tag> tags;

  const Entry({
    this.id,
    required this.name,
    required this.locationId,
    this.imagePath,
    this.tags = const[],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null)
      'id':id,
      'name':name,
      'location_id':locationId,
      'image_path':imagePath,
    };
  }

  factory Entry.fromMap(Map<String, dynamic> map, {List<Tag> tags = const []}) {
    return Entry(
      id: map['id'] as int?,
      name: map['name'] as String,
      locationId: map['location_id'] as int,
      imagePath: map['image_path'] as String?,
      tags: tags,
    );
  }

  Entry withTags({List<Tag>? tags}) => Entry(
        id: id,
        name: name,
        locationId: locationId,
        imagePath: imagePath,
        tags: tags ?? this.tags,
      );

  @override
  String toString() => 'Item(id: $id, name: $name, locationId: $locationId), tags: ${tags.length}';

}