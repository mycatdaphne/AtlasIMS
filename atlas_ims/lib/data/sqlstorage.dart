import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'schema/entry.dart';

class Sqlstorage {
  late Database db;

  static const _entriesTable = 'entries';

  Future open(String path) async {
    db = await openDatabase(
      join(await getDatabasesPath(), path), 
      version: 1,
      onCreate: (Database db, int version) async {
      await db.execute('''
create table $_entriesTable ( 
  id integer primary key autoincrement, 
  name text not null,
  location_id integer not null
  )
''');
    });
  }

  Future<int> addEntry(Entry entry) async {
    return await db.insert(_entriesTable, entry.toMap());
  }


}

