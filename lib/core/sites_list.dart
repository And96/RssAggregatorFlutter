import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rss_aggregator_flutter/core/site_icon.dart';

class SitesList {
  late List<Site> items = [];
  String itemLoading = "";

  late final ValueChanged<String> updateItemLoading;
  SitesList({required this.updateItemLoading});

  Future<bool> load() async {
    try {
      items = await readSites();
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<void> saveSites(List<Site> tList) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('db_site', jsonEncode(tList));
  }

  void deleteSite(String url) async {
    if (url == "*") {
      items = [];
    } else {
      items.removeWhere(
          (e) => (e.siteLink.trim().toLowerCase() == url.trim().toLowerCase()));
    }
    saveSites(items);
    items = await readSites();
  }

  Future<bool> addSite(String url, bool advancedSearch) async {
    try {
      String hostsiteName = url;
      if (hostsiteName.replaceAll("//", "/").contains("/")) {
        String tmp = Uri.parse(url.toString()).host.toString().toLowerCase();
        if (tmp.trim() != "") {
          hostsiteName = tmp;
          url = url.replaceAll(hostsiteName, hostsiteName.toLowerCase());
        }
      }
      itemLoading = hostsiteName;
      updateItemLoading(itemLoading);
      url = await Site.getUrlFormatted(url, advancedSearch);
      /*if (url.endsWith("/")) { 'tuttosport dont work if missing / at the end
        url = url.substring(0, url.length - 1);
      }*/
      if (!hostsiteName.contains(".")) {
        hostsiteName = Uri.parse(url.toString()).host.toString();
      }
      if (url.length > 1) {
        items.removeWhere((e) => (e.siteLink
                .trim()
                .toLowerCase()
                .replaceAll("https", "")
                .replaceAll("http", "")
                .replaceAll(":", "")
                .replaceAll("/", "")
                .replaceAll("www", "")
                .replaceAll(".", "")
                .replaceAll("rss", "")
                .replaceAll("feed", "") ==
            url
                .trim()
                .toLowerCase()
                .replaceAll("https", "")
                .replaceAll("http", "")
                .replaceAll(":", "")
                .replaceAll("/", "")
                .replaceAll("www", "")
                .replaceAll(".", "")
                .replaceAll("rss", "")
                .replaceAll("feed", "")));
        var s1 = Site(
          siteName: hostsiteName,
          siteLink: url,
          iconUrl: await SiteIcon().getIcon(hostsiteName, url),
        );
        items.add(s1);
        saveSites(items);
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return true;
  }

  Future<List<Site>> readSites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_site') ?? '[]');
      late List<Site> listLocal =
          List<Site>.from(jsonData.map((model) => Site.fromJson(model)));

      return listLocal;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }

  Future<bool> addDefaultSites() async {
    try {
      //TEST
      await addSite(
          "https://news.google.com/rss/search?q=KEYWORD&hl=it&gl=IT&ceid=IT%3Ait",
          false);
      await addSite("https://hano.it/feed", false);
      await addSite("https://myvalley.it/feed", false);
      await addSite("https://medium.com/feed/tag/programming", false);
    } catch (err) {
      // print('Caught error: $err');
    }
    return true;
  }
}
