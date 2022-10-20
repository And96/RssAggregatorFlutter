import 'dart:convert';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesList {
  late List<Feed> items = [];

  Future<bool> load() async {
    try {
      items = await get();
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<void> save(List<Feed> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('db_favourites', jsonEncode(list));
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  void delete(String link) async {
    await load();
    if (link == "*") {
      items = [];
    } else {
      items.removeWhere(
          (e) => (e.link.trim().toLowerCase() == link.trim().toLowerCase()));
    }
    await save(items);
    await load();
  }

  Future<bool> add(Feed feed) async {
    await load();
    try {
      if (feed.link.length > 1) {
        items.removeWhere((e) => (Utility().cleanUrlCompare(e.link) ==
            Utility().cleanUrlCompare(feed.link)));
        items.add(feed);
        await save(items);
        await load();
        return true;
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<List<Feed>> get() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_favourites') ?? '[]');
      late List<Feed> list =
          List<Feed>.from(jsonData.map((model) => Feed.fromMap(model)));
      //sort
      items.sort((a, b) => b.pubDate!.compareTo(a.pubDate!));
      return list;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }
}
