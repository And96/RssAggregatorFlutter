import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DB {
  static Database? _database;

  String databaseName = "db_feeds.db";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<void> close() async {
    try {
      await _database?.close();
    } catch (err) {
      //print('Caught error: $err');
    }
    _database = null;
  }

  Future<Database?> _initDB() async {
    try {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      return openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform.
        join(await getDatabasesPath(), databaseName),
        // When the database is first created, create a table to store dogs.
        onUpgrade: (db, versionOld, versionNew) {
          // Run the CREATE TABLE statement on the database.
          return db.execute(
            'DROP TABLE feeds; CREATE TABLE feeds(link TEXT PRIMARY KEY, title TEXT, pubDate TEXT, iconUrl TEXT, host TEXT)',
          );
        },
        onCreate: (db, version) {
          // Run the CREATE TABLE statement on the database.
          return db.execute(
            'CREATE TABLE feeds(link TEXT PRIMARY KEY, title TEXT, pubDate TEXT, iconUrl TEXT, host TEXT)',
          );
        },
        // Set the version. This executes the onCreate function and provides a
        // path to perform database upgrades and downgrades.
        version: 2,
      );
    } catch (err) {
      //print('Caught error: $err');
    }
    return null;
  }
}
