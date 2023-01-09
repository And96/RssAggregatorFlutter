import 'package:rss_aggregator_flutter/core/database.dart';
import 'package:sqflite/sqflite.dart';

class Cache {
  //key
  //type
  //value
  //date

  Future<Database> get database async {
    return DB().database;
  }

  Future<void> save(String key, String type, String value) async {
    try {
      await delete(key, type);
      final db = await database;
      int date = DateTime.now().millisecondsSinceEpoch;
      await db.rawInsert(
          'INSERT INTO [cache] ([key],[type],[value],[date]) VALUES(?,?,?,?)',
          [key, type, value, date]);
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<void> delete(String key, String type) async {
    try {
      final db = await database;
      await db.execute(
          'DELETE FROM [cache] WHERE [key]=? AND [type]=?', [key, type]);
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<void> clean() async {
    try {
      final db = await database;
      await db.execute('DELETE FROM [cache]');
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<void> cleanEmpty() async {
    try {
      final db = await database;
      await db.execute('DELETE FROM [cache] WHERE LENGTH([value])<=5');
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<void> cleanOld() async {
    try {
      final db = await database;
      int date =
          DateTime.now().add(const Duration(hours: -24)).millisecondsSinceEpoch;
      await db.execute('DELETE FROM [cache] WHERE [date]<=?', [date]);
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<String> get(String key, String type) async {
    String value = "";
    try {
      final db = await database;
      List<Map> result = await db.rawQuery(
          'SELECT [value] FROM [cache] WHERE [key]=? AND [type]=?',
          [key, type]);
      if (result.isNotEmpty) {
        return result.first.values.toList()[0];
      }
    } catch (err) {
      //print('Caught error: $err');
    }
    return value;
  }
}
