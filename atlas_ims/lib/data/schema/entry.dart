class Entry{
  final int? id;
  final String name;
  final int locationId;
  final String? imagePath;

  const Entry({
    this.id,
    required this.name,
    required this.locationId,
    this.imagePath
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

  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'] as int?,
      name: map['name'] as String,
      locationId: map['location_id'] as int,
      imagePath: map['image_path'] as String?,
    );
  }

  @override
  String toString() => 'Item(id: $id, name: $name, locationId: $locationId)';

}