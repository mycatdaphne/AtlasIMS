import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

import 'package:atlas_ims/data/schema/entry.dart';
import 'package:atlas_ims/data/schema/tag.dart';

class Sqlstorage {
  late Database db;

  static const _entriesTable = 'entries';
  static const _tagsTable = 'tags';
  static const _entryTagsTable = 'entry_tags';

  static const _defaultTags = [
    'Kitchen',
    'Bedroom',
    'Bathroom',
    'Living Room',
    'Garage',
    'Pantry',
    'Appliances'
    'Tools',
    'Miscelanneous',
    'Working',
    'Broken',
    'Damaged',
  ];


  final _entriesController = StreamController<List<Entry>>.broadcast();
  final _tagsController = StreamController<List<Tag>>.broadcast();
  List<Entry> _latestEntries = const [];
  List<Tag> _latestTags = const [];

  Stream<List<Entry>> get entriesStream async* {
    yield _latestEntries;
    yield* _entriesController.stream;
  }

  Stream<List<Tag>> get tagsStream async* {
    yield _latestTags;
    yield* _tagsController.stream;
  }


Future open(String path) async {
    db = await openDatabase(
      join(await getDatabasesPath(), path),
      version: 3,
      onCreate: (db, version) async {
        await _createEntries(db);
        await _createTags(db);
        await _createEntryTags(db);
        await _seedDefaultTags(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE $_entriesTable ADD COLUMN image_path TEXT');
        }
        if (oldVersion < 3) {
          await _createTags(db);
          await _createEntryTags(db);
          await _seedDefaultTags(db);
        }
      },
    );
    await _send();
    await _sendTags();
  }

  Future<void> _createEntries(Database db) => db.execute('''
        CREATE TABLE $_entriesTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          location_id INTEGER NOT NULL,
          image_path TEXT
        )
      ''');

  Future<void> _createTags(Database db) => db.execute('''
        CREATE TABLE $_tagsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE COLLATE NOCASE,
          is_default INTEGER NOT NULL DEFAULT 0
        )
      ''');

  Future<void> _createEntryTags(Database db) => db.execute('''
        CREATE TABLE $_entryTagsTable (
          entry_id INTEGER NOT NULL,
          tag_id INTEGER NOT NULL,
          PRIMARY KEY (entry_id, tag_id),
          FOREIGN KEY (entry_id) REFERENCES $_entriesTable(id) ON DELETE CASCADE,
          FOREIGN KEY (tag_id) REFERENCES $_tagsTable(id) ON DELETE CASCADE
        )
      ''');

  Future<void> _seedDefaultTags(Database db) async {
    final batch = db.batch();
    for (final name in _defaultTags) {
      batch.insert(
        _tagsTable,
        {'name': name, 'is_default': 1},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }



  Future<int> addEntry(Entry entry, {List<int> tagIds = const []}) async {
    final id = await db.insert(_entriesTable, entry.toMap());
    if (tagIds.isNotEmpty) {
      final batch = db.batch();
      for (final tagId in tagIds) {
        batch.insert(_entryTagsTable, {'entry_id': id, 'tag_id': tagId});
      }
      await batch.commit(noResult: true);
    }
    await _send();
    return id;
  }

  Future<int> delEntry (int id) async {
    final e = await db.delete(_entriesTable, where: 'id = ?', whereArgs: [id]);
    await _send();
    return e;
  }

  Future<List<Entry>> retrieveAll() async {
    final rows = await db.query(_entriesTable, orderBy: 'id ASC');
    final entries = <Entry>[];
    for (final r in rows) {
      final tagRows = await db.rawQuery('''
        SELECT t.* FROM tags t
        JOIN entry_tags et ON et.tag_id = t.id
        WHERE et.entry_id = ?
      ''', [r['id']]);
      final tags = tagRows.map((tr) => Tag.fromMap(tr)).toList();
      entries.add(Entry.fromMap(r, tags: tags));
    }
    return entries;
  }

  Future<void> _send() async{
    _latestEntries = await retrieveAll();
    _entriesController.add(_latestEntries);
  }

  Future<List<Entry>> retrieveRecent({int limit = 5}) async {
    final rows = await db.query(
      _entriesTable,
      orderBy: 'id DESC',
      limit: limit,
    );
    return rows.map((r) => Entry.fromMap(r)).toList();
  }

  Future<List<Tag>> retrieveAllTags() async {
    final rows = await db.query(
      _tagsTable,
      orderBy: 'is_default DESC, name COLLATE NOCASE ASC',
    );
    return rows.map((r) => Tag.fromMap(r)).toList();
  }

  Future<int> addTag(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }
    final existing = await db.query(
      _tagsTable,
      where: 'name = ? COLLATE NOCASE',
      whereArgs: [trimmed],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    final id = await db.insert(_tagsTable, {
      'name': trimmed,
      'is_default': 0,
    });
    await _sendTags();
    return id;
  }

  Future<int> renameTag(int id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }
    final n = await db.update(
      _tagsTable,
      {'name': trimmed},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _sendTags();
    await _send();
    return n;
  }

  Future<int> delTag(int id) async {
    final n = await db.delete(_tagsTable, where: 'id = ?', whereArgs: [id]);
    await _sendTags();
    await _send();
    return n;
  }

  Future<void> _sendTags() async {
    _latestTags = await retrieveAllTags();
    _tagsController.add(_latestTags);
  }

  Future<void> close() async {
    await _entriesController.close();
    await _tagsController.close();
    await db.close();
  }
}    


