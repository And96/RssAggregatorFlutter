import 'dart:convert';
import 'package:rss_aggregator_flutter/core/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesList {
  late List<Category> items = [];

  Future<bool> load() async {
    try {
      items = await get();
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
    items = await get();
  }

  Future<bool> add(String name, int color) async {
    try {
      name = name.trim();
      if (name.length > 1) {
        items.removeWhere((e) =>
            (e.name.trim().toLowerCase()) == (name.trim().toLowerCase()));
        var c = Category(
          name: name,
          color: color,
        );
        items.add(c);
        save(items);
        items = await get();
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
