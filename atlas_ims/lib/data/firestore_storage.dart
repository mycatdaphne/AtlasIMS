import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:atlas_ims/data/schema/entry.dart';
import 'package:atlas_ims/data/schema/tag.dart';

class FirestoreStorage {
  FirestoreStorage({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _defaultTags = [
    'Kitchen',
    'Bedroom',
    'Bathroom',
    'Living Room',
    'Garage',
    'Pantry',
    'Appliances',
    'Tools',
    'Miscellaneous',
    'Working',
    'Broken',
    'Damaged',
  ];

  List<Entry> _latestRawEntries = const [];
  List<Tag> _latestTags = const [];

  final _entriesController = StreamController<List<Entry>>.broadcast();
  final _tagsController = StreamController<List<Tag>>.broadcast();
  List<Entry> _latestJoinedEntries = const [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _entriesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tagsSub;

  Stream<List<Entry>> get entriesStream async* {
    yield _latestJoinedEntries;
    yield* _entriesController.stream;
  }

  Stream<List<Tag>> get tagsStream async* {
    yield _latestTags;
    yield* _tagsController.stream;
  }

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError(
        'FirestoreStorage used before sign-in. '
        'Make sure FirebaseAuth.instance.signInAnonymously() completes in main().',
      );
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _entriesCol =>
      _firestore.collection('users').doc(_uid).collection('entries');

  CollectionReference<Map<String, dynamic>> get _tagsCol =>
      _firestore.collection('users').doc(_uid).collection('tags');

  Future<void> init() async {
    await _seedDefaultTagsIfEmpty();

    _tagsSub = _tagsCol.orderBy('name').snapshots().listen((snap) {
      _latestTags = snap.docs.map(Tag.fromFirestore).toList();
      _tagsController.add(_latestTags);
      _recombine(); // tag rename should refresh joined entries too
    });

    _entriesSub =
        _entriesCol.orderBy('created_at').snapshots().listen((snap) {
      _latestRawEntries = snap.docs.map(Entry.fromFirestore).toList();
      _recombine();
    });
  }

  Future<void> close() async {
    await _entriesSub?.cancel();
    await _tagsSub?.cancel();
    await _entriesController.close();
    await _tagsController.close();
  }

  void _recombine() {
    final tagsById = {
      for (final t in _latestTags)
        if (t.id != null) t.id!: t,
    };

    _latestJoinedEntries = [
      for (final e in _latestRawEntries)
        e.withTags([
          for (final tid in e.tagIds)
            if (tagsById[tid] != null) tagsById[tid]!,
        ]),
    ];
    _entriesController.add(_latestJoinedEntries);
  }

  Future<void> _seedDefaultTagsIfEmpty() async {
    final existing = await _tagsCol.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    for (final name in _defaultTags) {
      final ref = _tagsCol.doc();
      batch.set(ref, {
        'name': name,
        'is_default': true,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<String> addEntry(
    Entry entry, {
    List<String> tagIds = const [],
  }) async {
    final doc = _entriesCol.doc();
    final payload = {
      ...entry.toFirestore(),
      'tag_ids': tagIds,
    };
    await doc.set(payload);
    return doc.id;
  }

  Future<void> delEntry(String id) async {
    await _entriesCol.doc(id).delete();
  }

  Future<List<Entry>> retrieveRecent({int limit = 5}) async {
    final snap = await _entriesCol
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(Entry.fromFirestore).toList();
  }

  Future<List<Tag>> retrieveAllTags() async {
    final snap = await _tagsCol.orderBy('name').get();
    return snap.docs.map(Tag.fromFirestore).toList();
  }

  Future<String> addTag(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }

    final lower = trimmed.toLowerCase();
    final existing = _latestTags.firstWhere(
      (t) => t.name.toLowerCase() == lower,
      orElse: () => const Tag(name: ''),
    );
    if (existing.id != null) return existing.id!;

    final doc = _tagsCol.doc();
    await doc.set({
      'name': trimmed,
      'is_default': false,
      'created_at': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> renameTag(String id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }
    await _tagsCol.doc(id).update({'name': trimmed});
  }

  Future<void> delTag(String id) async {
    final affected = await _entriesCol
        .where('tag_ids', arrayContains: id)
        .get();

    final batch = _firestore.batch();
    for (final doc in affected.docs) {
      batch.update(doc.reference, {
        'tag_ids': FieldValue.arrayRemove([id]),
      });
    }
    batch.delete(_tagsCol.doc(id));
    await batch.commit();
  }
}