import 'dart:convert';
import 'package:rss_aggregator_flutter/core/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesList {
  late List<Category> items = [];
  String defaultCategory = 'News';
  int defaultColor = 4284513675;

  int getColor(String categoryName) {
    try {
      return items.firstWhere((e) => e.name == categoryName).color;
    } catch (err) {
      // print('Caught error: $err');
    }
    return -1;
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

  Future<bool> load() async {
    try {
      items = await get();
      if (items.isEmpty) {
        add('News', -1);
      }
      if (items.length == 1) {
        defaultCategory = items[0].name;
      } else {
        defaultCategory = 'News';
      }
      if (defaultCategory == 'News') {
        if (items.where((e) => e.name == 'News').isEmpty) {
          add('News', -1);
        }
      }

      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<void> save(List<Category> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('db_categories', jsonEncode(list));
  }

  void delete(String name) async {
    if (name == "*") {
      items = [];
    } else {
      items.removeWhere(
          (e) => (e.name.trim().toLowerCase() == name.trim().toLowerCase()));
    }
    save(items);
    load();
  }

  Future<bool> add(String name, int color) async {
    try {
      name = name.trim();
      if (name.length > 1) {
        items.removeWhere((e) =>
            (e.name.trim().toLowerCase()) == (name.trim().toLowerCase()));
        if (color < 0) {
          color = defaultColor;
        }
        var c = Category(
          name: name,
          color: color,
        );
        items.add(c);
        save(items);
        load();
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
