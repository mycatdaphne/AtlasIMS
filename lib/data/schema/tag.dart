import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  final String? id;
  final String name;
  final bool isDefault;

  const Tag({
    this.id,
    required this.name,
    this.isDefault = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'is_default': isDefault,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory Tag.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Tag(
      id: doc.id,
      name: data['name'] as String? ?? '',
      isDefault: data['is_default'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Tag && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}