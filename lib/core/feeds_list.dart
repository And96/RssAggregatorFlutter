import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rss_aggregator_flutter/core/settings.dart';
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FeedsList {
  late List<Site> sites = [];
  late List<Feed> items = [];

  String itemLoading = "";
  double progressLoading = 0;

  Settings settings = Settings();

  late ValueChanged<String>? updateItemLoading;
  FeedsList({this.updateItemLoading});

  Future<bool> load(
      bool loadFromWeb, String siteName, String categoryName) async {
    try {
      await settings.init();
      sites = await readSites(siteName, categoryName);
      items = await readFeeds(loadFromWeb);
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<List<Site>> readSites(String siteName, String categoryName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_sites') ?? '[]');
      late List<Site> listLocal =
          List<Site>.from(jsonData.map((model) => Site.fromJson(model)));
      if (siteName != "*") {
        listLocal =
            listLocal.where((element) => element.siteName == siteName).toList();
      }
      if (categoryName != "*") {
        listLocal = listLocal
            .where((element) => element.category == categoryName)
            .toList();
      }
      return listLocal;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }

  Future<List<Feed>> readFeeds(bool loadFromWeb) async {
    try {
      items = [];

      for (var i = 0; i < sites.length; i++) {
        try {
          progressLoading = (i + 1) / sites.length;
          if (loadFromWeb) {
            await readFeedsFromWeb(sites[i]);
          } else {
            await readFeedFromDB(sites[i]).then((value) => items.addAll(value));
          }
        } catch (err) {
          // print('Caught error: $err');
        }
      }

      //remove feed older than N days
      if (settings.settingsDaysLimit > 0) {
        items.removeWhere((e) =>
            (Utility().daysBetween(e.pubDate!, DateTime.now()) >
                settings.settingsDaysLimit));
      }

      //sort
      items.sort((a, b) => b.pubDate!.compareTo(a.pubDate!));

      return items;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }

  Future<List<Feed>> parseRssFeed(
      Site site, String hostname, Response response) async {
    List<Feed> itemsSite = [];
    try {
      RssFeed channel = RssFeed();
      try {
        channel = RssFeed.parse(utf8.decode(
            response.bodyBytes)); //risolve accenti sbagliati esempio agi
      } catch (err) {
        //crash in utf8 with some site e.g. ilmattino, so try again without it and it works
        try {
          channel = RssFeed.parse(response.body);
        } catch (err) {
          // print('Caught error: $err');
        }
      }

      String? iconUrl = site.iconUrl.trim();
      channel.items?.forEach((element) {
        if (element.title?.isEmpty == false) {
          if (element.title.toString().length > 5) {
            var feed = Feed(
                title: element.title == null ||
                        element.title.toString().trim() == ""
                    ? Utility().cleanText(element.description)
                    : Utility().cleanText(element.title),
                link:
                    element.link == null || element.link.toString().trim() == ""
                        ? element.guid.toString().trim()
                        : element.link.toString().trim(),
                iconUrl: iconUrl.toString(),
                pubDate: Utility().tryParse(element.pubDate.toString()),
                host: hostname);
            itemsSite.add(feed);
          }
        }
      });
    } catch (err) {
      // print('Caught error: $err');
    }
    return itemsSite;
  }

  Future<List<Feed>> parseAtomFeed(
      Site site, String hostname, Response response) async {
    List<Feed> itemsSite = [];
    try {
      AtomFeed channel = AtomFeed();
      try {
        channel = AtomFeed.parse(utf8.decode(
            response.bodyBytes)); //risolve accenti sbagliati esempio agi
      } catch (err) {
        //crash in utf8 with some site e.g. ilmattino, so try again without it and it works
        try {
          channel = AtomFeed.parse(response.body);
        } catch (err) {
          // print('Caught error: $err');
        }
      }

      String? iconUrl = site.iconUrl.trim();
      channel.items?.forEach((element) {
        if (element.title?.isEmpty == false) {
          if (element.title.toString().length > 5) {
            var feed = Feed(
                title: element.title == null ||
                        element.title.toString().trim() == ""
                    ? Utility().cleanText(element.content)
                    : Utility().cleanText(element.title),
                link: element.links == null ||
                        element.links!.first.href.toString().trim() == ""
                    ? element.id.toString().trim()
                    : element.links!.first.href.toString().trim(),
                iconUrl: iconUrl.toString(),
                pubDate: Utility().tryParse(element.published.toString()),
                host: hostname);
            itemsSite.add(feed);
          }
        }
      });
    } catch (err) {
      // print('Caught error: $err');
    }
    return itemsSite;
  }

  readFeedsFromWeb(Site site) async {
    try {
      if (site.siteLink.trim().toLowerCase().contains("http")) {
        String hostname = site.siteName;
        itemLoading = hostname;
        if (updateItemLoading != null) {
          updateItemLoading!(itemLoading);
        }

        final response = await get(Uri.parse(site.siteLink))
            .timeout(Duration(seconds: settings.settingsTimeout));

        List<Feed> itemsSite;
        itemsSite = await parseRssFeed(site, hostname, response);
        if (itemsSite.isEmpty) {
          itemsSite = await parseAtomFeed(site, hostname, response);
        }

        //sort
        itemsSite.sort((a, b) => b.pubDate!.compareTo(a.pubDate!));

        deleteDB(site.siteName);

        //filter first items
        for (Feed f in itemsSite.take(settings.settingsFeedsLimit == 0
            ? 9999
            : settings.settingsFeedsLimit)) {
          items.add(f);
          await insertDB(f);
        }
      }
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
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
        join(await getDatabasesPath(), 'db_feeds.db'),
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

// Define a function that inserts dogs into the database
  Future<void> insertDB(Feed feed) async {
    try {
      // Get a reference to the database.
      final db = await database;

      // Insert the Dog into the correct table. You might also specify the
      // `conflictAlgorithm` to use in case the same dog is inserted twice.
      //
      // In this case, replace any previous data.
      await db.insert(
        'feeds',
        feed.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Feed>> readFeedFromDB(Site site) async {
    List<Feed> list = [];
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db
          .rawQuery('SELECT * FROM feeds WHERE host=?', [site.siteName]);
      list = List<Feed>.from(maps.map((model) => Feed.fromMap(model)));
    } catch (err) {
      //print('Caught error: $err');
    }
    return list;
  }

  Future<void> updateDB(Feed feed) async {
    try {
      final db = await database;
      await db.update(
        'feeds',
        feed.toMap(),
        where: 'link = ?',
        whereArgs: [feed.link],
      );
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<void> deleteDB(String host) async {
    try {
      final db = await database;
      await db.delete(
        'feeds',
        where: 'host = ?',
        whereArgs: [host],
      );
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<void> deleteAllDB() async {
    try {
      final db = await database;
      await db.delete(
        'feeds',
      );
    } catch (err) {
      //print('Caught error: $err');
    }
  }
}
