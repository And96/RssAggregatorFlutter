import 'dart:convert';
import 'package:flutter/animation.dart';
import 'package:rss_aggregator_flutter/core/category.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';

class CategoriesList {
  late List<Category> items = [];
  late List<Category> tabs = [];
  String defaultCategory = 'News';

  Color getColorSync(String categoryName) {
    try {
      if (items.isEmpty) {
        load(false);
      }
      return Color(items.firstWhere((e) => e.name == categoryName).color);
    } catch (err) {
      // print('Caught error: $err');
    }
    return Color(ThemeColor().defaultCategoryColor);
  }

  Future<Color> getColor(String categoryName) async {
    try {
      if (items.isEmpty) {
        await load(false);
      }
      return Color(items.firstWhere((e) => e.name == categoryName).color);
    } catch (err) {
      // print('Caught error: $err');
    }
    return Color(ThemeColor().defaultCategoryColor);
  }

  Future<int> getIcon(String categoryName) async {
    try {
      if (items.isEmpty) {
        await load(false);
      }
      return items.firstWhere((e) => e.name == categoryName).icon;
    } catch (err) {
      // print('Caught error: $err');
    }
    return ThemeColor().defaultCategoryIcon;
  }

  List<String> toList() {
    List<String> list = [];
    try {
      for (Category item in items) {
        list.add(item.name);
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return list;
  }

  List<String> getSiteList() {
    List<String> list = [];
    try {
      for (Category item in items) {
        list.add(item.name);
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return list;
  }

  Future<bool> load([bool loadCategoryTabs = false]) async {
    try {
      items = await get();
      if (loadCategoryTabs) {
        tabs = await getTabs();
      }
      //items.add(Category(name: '*', color: ThemeColor().defaultCategoryColor));
      defaultCategory = 'News';
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<bool> exists(String name) async {
    try {
      List<Category> c = await get();
      c = c
          .where(
              (e) => (e.name.trim().toLowerCase() == name.trim().toLowerCase()))
          .toList();
      if (c.isNotEmpty) {
        return true;
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<List<Category>> getTabs() async {
    try {
      List<Category> categories = await get();
      List<Category> tabs = [];
      tabs.add(Category(
          name: '*', color: ThemeColor().defaultCategoryColor, icon: 0));
      SitesList sitesList =
          SitesList.withIndicator(updateItemLoading: (String value) {});
      await sitesList.load();
      for (Category c in categories) {
        List<String> sites = await sitesList.getSitesFromCategory(c.name);
        if (sites.isNotEmpty) {
          tabs.add(c);
        }
      }
      if (tabs.length == 2) {
        tabs.removeWhere((element) => element.name != "*");
      }

      return tabs;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }

  Future<void> save(List<Category> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('db_categories', jsonEncode(list));
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  void delete(String name) async {
    try {
      if (name == "*") {
        items = [];
      } else {
        items.removeWhere(
            (e) => (e.name.trim().toLowerCase() == name.trim().toLowerCase()));
      }
      await save(items);
      await load();
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  Future<bool> add(String name, [int color = -1, int icon = -1]) async {
    try {
      await load();
      name = name.trim();
      if (name.length > 1) {
        items.removeWhere((e) =>
            (e.name.trim().toLowerCase()) == (name.trim().toLowerCase()));
        if (color < 0) {
          color = ThemeColor().defaultCategoryColor;
        }
        if (icon < 0) {
          icon = ThemeColor().defaultCategoryIcon;
        }
        var c = Category(
          name: name,
          color: color,
          icon: icon,
        );
        items.add(c);
        await save(items);
        await load();
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return true;
  }

  Future<List<Category>> get() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_categories') ?? '[]');
      late List<Category> list = List<Category>.from(
          jsonData.map((model) => Category.fromJson(model)));
      //sort
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }
}
