import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rss_aggregator_flutter/core/site_icon.dart';

class SitesList {
  late List<Site> items = [];
  String itemLoading = "";
  String sort = "name";
  late CategoriesList categoriesList = CategoriesList();

  late final ValueChanged<String> updateItemLoading;
  SitesList({required this.updateItemLoading});

  List<String> toList() {
    List<String> list = [];
    try {
      for (Site item in items) {
        list.add(item.siteLink);
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return list;
  }

  Future<List<String>> getSitesFromCategory(String category) async {
    List<String> list = [];
    try {
      for (Site item in items) {
        if (category.trim() == "" ||
            item.category.toLowerCase().trim() ==
                category.toLowerCase().trim()) {
          list.add(item.siteLink);
        }
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return list;
  }

  Future<bool> load([String sort = ""]) async {
    try {
      if (sort.trim() != "") {
        this.sort = sort;
      }
      categoriesList.load();
      items = await get();
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<bool> exists(String url) async {
    try {
      List l = await get();
      l = l
          .where((e) =>
              (e.siteLink.trim().toLowerCase() == url.trim().toLowerCase()))
          .toList();
      if (l.isNotEmpty) {
        return true;
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<void> save(List<Site> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('db_sites', jsonEncode(list));
  }

  Future<bool> delete(String url) async {
    try {
      await load();
      if (url == "*") {
        items = [];
        await FeedsList(updateItemLoading: null).deleteAllDB();
      } else {
        items.removeWhere((e) =>
            (e.siteLink.trim().toLowerCase() == url.trim().toLowerCase()));
        await FeedsList(updateItemLoading: null).deleteDB(url);
      }
      await save(items);
      await load();
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<bool> renameCategory(String categoryOld, String categoryNew) async {
    try {
      await load();
      for (var item in items) {
        if (item.category.trim().toLowerCase() ==
            categoryOld.trim().toLowerCase()) {
          item.category = categoryNew;
        }
      }
      await save(items);
      await load();
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<bool> setCategory(String siteLink, String category) async {
    try {
      await load();
      for (var item in items) {
        if (item.siteLink.trim().toLowerCase() ==
            siteLink.trim().toLowerCase()) {
          item.category = category;
          break;
        }
      }
      await save(items);
      await load();
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<bool> addSite(Site site) async {
    try {
      await load();
      items.removeWhere((e) => (Utility().cleanUrlCompare(e.siteLink) ==
          Utility().cleanUrlCompare(site.siteLink)));
      items.add(site);
      await save(items);
      await load();
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<List<String>> add(String url, bool advancedSearch,
      [String category = '', String siteName = '']) async {
    List<String> siteAgg = [];
    try {
      String hostsiteName = url;
      if (url.toLowerCase().replaceFirst("http", "").contains("http") &&
          url.toLowerCase().contains("google")) {
        for (String link
            in Utility().getUrlsFromText(url.replaceAll("http", " http"))) {
          if (!link.contains("google")) {
            url = link;
          }
        }
      }
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
      /* if (url.contains(
        ".",
      )) {
        hostsiteName = Uri.parse(url.toString()).host.toString();
      */
      if (!hostsiteName.contains(".")) {
        hostsiteName = Uri.parse(url.toString()).host.toString();
      }
      hostsiteName = hostsiteName
          .toLowerCase()
          .replaceAll('www.', '')
          .replaceAll('https://.', '')
          .replaceAll('http://', '')
          .replaceAll("/", "")
          .replaceAll(RegExp(r'(^m\.)'), '');

      if (url.length > 1) {
        var s1 = Site(
          siteName: siteName.trim() != '' ? siteName : hostsiteName,
          siteLink: url,
          iconUrl: await SiteIcon()
              .getIcon(siteName.trim() != '' ? siteName : hostsiteName, url),
          category:
              category.trim() != '' ? category : categoriesList.defaultCategory,
        );
        await addSite(s1);
        siteAgg.add(s1.siteLink);
        return siteAgg;
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return siteAgg;
  }

  Future<List<Site>> get() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_sites') ?? '[]');
      late List<Site> list =
          List<Site>.from(jsonData.map((model) => Site.fromJson(model)));
      if (sort == "name") {
        list.sort((a, b) =>
            a.siteName.toLowerCase().compareTo(b.siteName.toLowerCase()));
      }
      if (sort == "category") {
        list.sort((a, b) => (a.category + a.siteName)
            .toLowerCase()
            .compareTo((b.category + b.siteName).toLowerCase()));
      }
      return list;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }
}
