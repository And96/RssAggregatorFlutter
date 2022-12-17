import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/database.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rss_aggregator_flutter/core/settings.dart';
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class FeedsList {
  late List<Site> sites = [];
  late List<Feed> items = [];

  String itemLoading = "";
  double progressLoading = 0;
  int progressCompleted = 0;
  int progressRemaining = 0;
  int progressAll = 0;

  Settings settings = Settings();

  late ValueChanged<String>? updateItemLoading;
  FeedsList({this.updateItemLoading});

  Future<bool> load(bool loadFromWeb, int siteID, String categoryName) async {
    try {
      await settings.init();
      sites = await readSites(siteID, categoryName);
      items = await readFeeds(loadFromWeb);
      if (loadFromWeb &&
          items.isNotEmpty &&
          siteID <= 0 &&
          categoryName.length <= 1) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('last_update_feeds', DateTime.now().toIso8601String());
      }
      return true;
    } catch (err) {
      //print('Caught error: $err');
    }
    return false;
  }

  Future<bool> isUpdateFeedsRequired() async {
    try {
      await settings.init();
      if (settings.settingsRefreshAfter >= 0) {
        //Force refresh is time is passed after parameter
        final prefs = await SharedPreferences.getInstance();
        String? lastUpdate = prefs.getString('last_update_feeds');
        if (lastUpdate == null) {
          return true;
        }
        if (settings.settingsRefreshAfter == 0 ||
            Utility().minutesBetween(
                    DateTime.parse(lastUpdate), DateTime.now()) >
                settings.settingsRefreshAfter) {
          return true;
        }
        //force refresh if no site is loaded
        if (await countFeedFromDB() == 0) {
          return true;
        }
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<List<Site>> readSites(int siteID, String categoryName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_sites') ?? '[]');
      late List<Site> listLocal =
          List<Site>.from(jsonData.map((model) => Site.fromJson(model)));
      if (siteID > 0) {
        listLocal =
            listLocal.where((element) => element.siteID == siteID).toList();
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

      progressCompleted = 0;
      progressRemaining = 0;
      progressAll = 0;

      //dont load anything if no sites
      if (sites.isEmpty) {
        return [];
      }

      //online
      if (loadFromWeb) {
        progressLoading = sites.isNotEmpty && sites.length < 10
            ? 1 / (sites.length) - (1 / (sites.length * 2))
            : 0.001;
        setUpdateItemLoading('');
        int u = 0; //number sites in updating
        int c = 0; //number sites with update completed
        List<String> listU =
            []; //keep both u and listu because listu may have url duplicated
        progressAll = sites.length;
        progressRemaining = sites.length;
        for (var i = 0; i < sites.length; i++) {
          try {
            while (true) {
              if (u < settings.settingsNetworkSimultaneous) {
                u++;
                listU.add(sites[i].siteName);
                setUpdateItemLoading(sites[i].siteName);
                syncFeedsFromWeb(sites[i]).whenComplete(() => {
                      u--,
                      c++,
                      progressCompleted = c,
                      progressRemaining = progressAll - progressCompleted,
                      listU.remove(sites[i].siteName),
                      progressLoading = Utility().round(c / sites.length, 2),
                      if (progressLoading <= 0.05) {progressLoading = 0.05},
                      if (progressLoading > 0.90) {progressLoading = 1},
                      setUpdateItemLoading(null)
                    });
                break;
              } else {
                await Future.delayed(
                    Duration(milliseconds: settings.settingsNetworkDelay));
              }
            }
          } catch (err) {
            //print('Caught error: $err');
          }
        }

        //print("fine sync web");

        //wait that all fees are loaded, because readFeedsFromWeb is async but not waited
        while (u != 0) {
          try {
            await Future.delayed(const Duration(milliseconds: 100));
            if (listU.isNotEmpty) {
              setUpdateItemLoading(listU[listU.length - 1]);
            }
          } catch (err) {
            //print('Caught error: $err');
          }
        }
        setUpdateItemLoading('');
        progressLoading = 1;
        setUpdateItemLoading('');
        await Future.delayed(
            Duration(milliseconds: sites.length < 10 ? 500 : 100));
      }

      //reset if offline
      if (!loadFromWeb) {
        progressLoading = 0;
      }

      //reload both online both offline
      for (var i = 0; i < sites.length; i++) {
        try {
          //progressLoading = (i + 1) / sites.length;
          await readFeedFromDB(sites[i]).then((value) => items.addAll(value));
        } catch (err) {
          //print('Caught error: $err');
        }
      }

      //}

      //remove feeds (older than N days)
      if (settings.settingsDaysLimit > 0) {
        items.removeWhere((e) =>
            (Utility().daysBetween(e.pubDate, DateTime.now()) >
                settings.settingsDaysLimit));
      }

      //remove feeds (blacklist parental)
      if (settings.settingsBlacklistParental) {
        for (String keywoard in Utility().blacklistParental) {
          items.removeWhere((e) =>
              (e.title.toLowerCase().contains(keywoard.toLowerCase().trim())));
        }
      }

      //remove feeds (blacklist custom)
      if (settings.settingsBlacklistCustom.toString().trim().length > 1) {
        List<String> blacklist = settings.settingsBlacklistCustom
            .toString()
            .trim()
            .replaceAll("\n", ";")
            .split(";");
        for (String keywoard in blacklist) {
          if (keywoard.trim() != "") {
            items.removeWhere((e) => (e.title
                .toLowerCase()
                .contains(keywoard.toLowerCase().trim())));
          }
        }
      }

      //sort
      items.sort((a, b) => b.pubDate.compareTo(a.pubDate));

      return items;
    } catch (err) {
      //print('Caught error: $err');
    }
    return [];
  }

  Future<List<Feed>> parseRssFeed(Site site, Response response) async {
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
                host: site.siteName,
                siteID: site.siteID);
            itemsSite.add(feed);
          }
        }
      });
    } catch (err) {
      // print('Caught error: $err');
    }
    return itemsSite;
  }

  Future<List<Feed>> parseAtomFeed(Site site, Response response) async {
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
                link: getLinkAtom(element),
                iconUrl: iconUrl.toString(),
                pubDate: Utility().tryParse(element.published == null
                    ? element.updated.toString()
                    : element.published.toString()),
                host: site.siteName,
                siteID: site.siteID);
            itemsSite.add(feed);
          }
        }
      });
    } catch (err) {
      // print('Caught error: $err');
    }
    return itemsSite;
  }

  String getLinkAtom(AtomItem element) {
    try {
      if (element.links != null) {
        try {
          return element.links!
              .firstWhere((element) =>
                  element.href.toString().toLowerCase().contains(".htm"))
              .href
              .toString()
              .trim();
        } catch (err) {
          //
        }
        try {
          return element.links!
              .firstWhere((element) =>
                  !element.href.toString().toLowerCase().contains("comment") &&
                  !element.href.toString().contains("www.blogger.com"))
              .href
              .toString()
              .trim();
        } catch (err) {
          //
        }
        try {
          return element.links!.first.href.toString().trim();
        } catch (err) {
          //
        }
      }
      return element.id.toString().trim();
    } catch (err) {
      // print('Caught error: $err');
    }
    return "";
  }

  setUpdateItemLoading(String? text) {
    try {
      if (text != null) {
        itemLoading = text.toString();
      }
      if (updateItemLoading != null) {
        updateItemLoading!(itemLoading);
      }
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  Future<void> syncFeedsFromWeb(Site site) async {
    /* DateTime t1;*/
    try {
      //print(site.siteLink);

      /*//DEBUG TIME ***
      t1 = DateTime.now();
      print('Start: ${DateTime.now().difference(t1).inMicroseconds}');*/

      if (site.siteLink.trim().toLowerCase().contains("http")) {
/*//DEBUG TIME ***
        print(
            'Before response: ${DateTime.now().difference(t1).inMicroseconds}');
        t1 = DateTime.now();*/

        final response = await get(Uri.parse(site.siteLink))
            .timeout(Duration(seconds: settings.settingsNetworkTimeout));

/*//DEBUG TIME ***
        print(
            'After response: ${DateTime.now().difference(t1).inMicroseconds}');
        t1 = DateTime.now();*/

        List<Feed> itemsSite;
        itemsSite = await parseRssFeed(site, response);
        if (itemsSite.isEmpty) {
          itemsSite = await parseAtomFeed(site, response);
        }

/*//DEBUG TIME ***
        print('After parse: ${DateTime.now().difference(t1).inMicroseconds}');
        t1 = DateTime.now();*/

        //sort
        itemsSite.sort((a, b) => b.pubDate.compareTo(a.pubDate));

//DEBUG TIME ***

        /*print('After sort: ${DateTime.now().difference(t1).inMicroseconds}');
        t1 = DateTime.now();*/
/*xxx
        await deleteDB(site.siteName, site.siteID);*/ //now keep last n record

//DEBUG TIME ***

        /*print('After delete: ${DateTime.now().difference(t1).inMicroseconds}');
        t1 = DateTime.now();*/

        //filter first N items
        itemsSite = itemsSite
            .take(settings.settingsFeedsLimit == 0
                ? 9999
                : settings.settingsFeedsLimit)
            .toList();

//remove feed with same title multiple source can report same news/link
        for (Feed feed in itemsSite) {
          await deleteDBSameTitle(feed.title);
        }

        //save to database
        await insertDBMultiple(itemsSite);

//delete old feed (keep latest 20 items + delete N days ago)
        await deleteDBOld(site.siteID, settings.settingsFeedsLimit);
      }

//DEBUG TIME ***

      /* print('After insert db: ${DateTime.now().difference(t1).inMicroseconds}');
      t1 = DateTime.now();*/

    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<Database> get database async {
    return DB().database;
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

  // Define a function that inserts dogs into the database
  Future<void> insertDBMultiple(List<Feed> list) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (Feed feed in list) {
        batch.insert(
          'feeds',
          feed.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<List<Feed>> readFeedFromDB(Site site) async {
    List<Feed> list = [];
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db
          .rawQuery('SELECT * FROM feeds WHERE siteID=?', [site.siteID]);
      list = List<Feed>.from(maps.map((model) => Feed.fromMap(model)));
    } catch (err) {
      //print('Caught error: $err');
    }
    return list;
  }

  Future<int> countFeedFromDB() async {
    int n = 0;
    try {
      final db = await database;
      n = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM feeds')) ??
          0;
    } catch (err) {
      //print('Caught error: $err');
    }
    return n;
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

  Future<void> deleteDB(String siteName, int siteID) async {
    try {
      final db = await database;

      if (siteID > 0) {
        await db.delete(
          'feeds',
          where: 'siteID = ?',
          whereArgs: [siteID],
        );
      } else {
        final db = await database;
        await db.delete(
          'feeds',
          where: 'host = ?',
          whereArgs: [siteName],
        );
      }
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<void> deleteDBSameTitle(String title) async {
    try {
      final db = await database;
      await db.delete(
        'feeds',
        where: 'TRIM(title) = ?',
        whereArgs: [title.trim()],
      );
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<void> deleteDBOld(int siteID, int settingsFeedsLimit) async {
    try {
      if (settingsFeedsLimit > 0) {
        final db = await database;
        await db.execute(
            'DELETE FROM feeds WHERE siteID=$siteID AND pubDate NOT IN (SELECT pubDate FROM feeds WHERE siteID=$siteID ORDER BY pubDate DESC LIMIT $settingsFeedsLimit)');
      }
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
