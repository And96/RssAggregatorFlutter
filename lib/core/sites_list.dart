import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rss_aggregator_flutter/core/site_icon.dart';

class SitesList {
  late List<Site> items = [];
  String itemLoading = "";
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

  Future<bool> load() async {
    try {
      categoriesList.load();
      items = await get();
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<void> save(List<Site> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('db_sites', jsonEncode(list));
  }

  void delete(String url) async {
    if (url == "*") {
      items = [];
    } else {
      items.removeWhere(
          (e) => (e.siteLink.trim().toLowerCase() == url.trim().toLowerCase()));
    }
    save(items);
    await load();
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

  Future<bool> add(String url, bool advancedSearch,
      [String category = '', String siteName = '']) async {
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
        items.removeWhere((e) => (Utility().cleanUrlCompare(e.siteLink) ==
            Utility().cleanUrlCompare(url)));
        var s1 = Site(
          siteName: siteName.trim() != '' ? siteName : hostsiteName,
          siteLink: url,
          iconUrl: await SiteIcon()
              .getIcon(siteName.trim() != '' ? siteName : hostsiteName, url),
          category:
              category.trim() != '' ? category : categoriesList.defaultCategory,
        );
        items.add(s1);
        await save(items);
        items = await get();
        return true;
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<List<Site>> get() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_sites') ?? '[]');
      late List<Site> list =
          List<Site>.from(jsonData.map((model) => Site.fromJson(model)));
      //sort
      list.sort((a, b) =>
          a.siteName.toLowerCase().compareTo(b.siteName.toLowerCase()));
      return list;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }
}
