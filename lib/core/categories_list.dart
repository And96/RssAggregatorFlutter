import 'dart:convert';
import 'package:rss_aggregator_flutter/core/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesList {
  late List<Category> items = [];

  Future<bool> load() async {
    try {
      items = await readCategories();
      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<void> saveCategories(List<Category> tList) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('db_categories', jsonEncode(tList));
  }

  void deleteCategory(String name) async {
    if (name == "*") {
      items = [];
    } else {
      items.removeWhere(
          (e) => (e.name.trim().toLowerCase() == name.trim().toLowerCase()));
    }
    saveCategories(items);
    items = await readCategories();
  }

  Future<bool> addCategory(String name, int color) async {
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
        saveCategories(items);
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return true;
  }

  Future<List<Category>> readCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_categories') ?? '[]');
      late List<Category> listLocal = List<Category>.from(
          jsonData.map((model) => Category.fromJson(model)));

      return listLocal;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }
}
