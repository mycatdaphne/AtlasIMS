import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryLocation {
  final String? id;
  final String name;
  final String? address;

  const InventoryLocation({
    this.id,
    required this.name,
    this.address,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory InventoryLocation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return InventoryLocation(
      id: doc.id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String?,
    );
  }
}
