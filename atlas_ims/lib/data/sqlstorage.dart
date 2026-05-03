import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

import 'schema/entry.dart';

class Sqlstorage {
  late Database db;

  static const _entriesTable = 'entries';

  final _entriesController = StreamController<List<Entry>>.broadcast();
  List<Entry> _latest = const [];

  Stream<List<Entry>> get entriesStream async* {
    yield _latest;
    yield* _entriesController.stream;
  }


Future open(String path) async {
  db = await openDatabase(
    join(await getDatabasesPath(), path),
    version: 2, 
    onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE $_entriesTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          location_id INTEGER NOT NULL,
          image_path TEXT
        )
      ''');
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE $_entriesTable ADD COLUMN image_path TEXT');
      }
    },
  );
  await _send();
}

  Future<int> addEntry(Entry entry) async {
    final id = await db.insert(_entriesTable, entry.toMap());
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
    return rows.map((r) => Entry.fromMap(r)).toList();
  }

  Future<void> _send() async{
    _latest = await retrieveAll();
    _entriesController.add(_latest);
  }

  Future<void> close() async {
    await _entriesController.close();
    await db.close();
  }

  Future<List<Entry>> retrieveRecent({int limit = 5}) async {
    final rows = await db.query(
      _entriesTable,
      orderBy: 'id DESC',
      limit: limit,
    );
    return rows.map((r) => Entry.fromMap(r)).toList();
}


}

