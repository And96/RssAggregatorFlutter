import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rss_aggregator_flutter/core/settings.dart';
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';

class FeedsList {
  late List<Site> sites = [];
  late List<Feed> items = [];

  String itemLoading = "";
  double progressLoading = 0;

  Settings settings = Settings();

  late final ValueChanged<String> updateItemLoading;
  FeedsList({required this.updateItemLoading});

  Future<bool> load() async {
    try {
      await settings.init();
      sites = await readSites();
      items = await readFeeds();
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<List<Site>> readSites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_sites') ?? '[]');
      late List<Site> listLocal =
          List<Site>.from(jsonData.map((model) => Site.fromJson(model)));
      return listLocal;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }

  Future<List<Feed>> readFeeds() async {
    try {
      try {
        items = [];

        for (var i = 0; i < sites.length; i++) {
          try {
            progressLoading = (i + 1) / sites.length;
            await loadDataUrl(sites[i]);
          } catch (err) {
            // print('Caught error: $err');
          }
          continue;
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

      String? iconUrl = site.iconUrl.trim() != ""
          ? site.iconUrl
          : channel.image?.url?.toString();
      List<Feed> itemsSite = [];
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

      String? iconUrl =
          site.iconUrl.trim() != "" ? site.iconUrl : channel.icon?.toString();
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

  loadDataUrl(Site site) async {
    try {
      if (site.siteLink.trim().toLowerCase().contains("http")) {
        String hostname = site.siteName;
        itemLoading = hostname;
        updateItemLoading(itemLoading);
        final response = await get(Uri.parse(site.siteLink))
            .timeout(Duration(seconds: settings.settingsTimeout));

        List<Feed> itemsSite;
        itemsSite = await parseRssFeed(site, hostname, response);
        if (itemsSite.isEmpty) {
          itemsSite = await parseAtomFeed(site, hostname, response);
        }

        //sort
        itemsSite.sort((a, b) => b.pubDate!.compareTo(a.pubDate!));

        //filter first items
        for (Feed f in itemsSite.take(settings.settingsFeedsLimit == 0
            ? 9999
            : settings.settingsFeedsLimit)) {
          items.add(f);
        }
      }
    } catch (err) {
      //print('Caught error: $err');
    }
  }
}
