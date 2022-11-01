import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Utility {
  List<String> getUrlsFromText(String text) {
    try {
      RegExp exp =
          RegExp(r'(?:(?:https?|http):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
      Iterable<RegExpMatch> matches = exp.allMatches(text);
      List<String> listUrl = [];
      for (var match in matches) {
        if (match.toString().length > 6) {
          listUrl.add(text.substring(match.start, match.end));
        }
      }
      return listUrl;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }

  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  bool isMultipleLink(String inputText) {
    try {
      if (inputText.toString().contains("<") ||
          inputText.toString().contains(";") ||
          inputText.toString().contains(" ") ||
          inputText.toString().contains("\n")) {
        return true;
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  String cleanText(String? inputText) {
    try {
      return inputText
          .toString()
          .trim()
          .replaceAll("�", " ")
          .replaceAll("&#039;", " ")
          .replaceAll("&quot;", " ")
          .replaceAll("&#8217;", "'")
          .replaceAll(RegExp('&#[0-9]{1,5};'), " ")
          .replaceAll("  ", " ");
    } catch (err) {
      // print('Caught error: $err');
    }
    return inputText.toString();
  }

  String cleanUrlCompare(String? inputText) {
    try {
      return inputText
          .toString()
          .trim()
          .toLowerCase()
          .replaceAll("https", "")
          .replaceAll("http", "")
          .replaceAll(":", "")
          .replaceAll("/", "")
          .replaceAll("www", "")
          .replaceAll("m.", "")
          .replaceAll(".", "")
          .replaceAll("rss", "")
          .replaceAll("feed", "");
    } catch (err) {
      // print('Caught error: $err');
    }
    return inputText.toString();
  }

  String cleanSearchText(String? inputText) {
    try {
      return inputText
          .toString()
          .toLowerCase()
          .replaceAll(".", "")
          .replaceAll("'", "")
          .replaceAll("è", "e")
          .replaceAll("à", "a")
          .replaceAll("ò", "o")
          .replaceAll("é", "e")
          .replaceAll("ù", "u")
          .replaceAll("ì", "i")
          .replaceAll("/", "")
          .replaceAll("-", "")
          .replaceAll("_", "");
    } catch (err) {
      // print('Caught error: $err');
    }
    return inputText.toString();
  }

  bool compareSearch(List<String?> textList, String? value) {
    try {
      for (var text in textList) {
        if (cleanSearchText(text).contains(cleanSearchText(value))) {
          return true;
        }
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  DateTime tryParse(String formattedString) {
    try {
      DateTime dateLocal = DateTime.parse(formattedString).toLocal();
      if (dateLocal.isAfter(DateTime.now())) {
        return DateTime.now();
      }
      return dateLocal;
    } on FormatException {
      DateTime now = DateTime.now();
      return DateTime(now.year, now.month, now.day).toLocal();
    }
  }

  Future<void> clearCache() async {
    try {
      DefaultCacheManager().emptyCache();
      //ON WINDOWS IT DELETE ALL C:/Users/ADMIN/AppData/Local/Temp/
      /* final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }*/
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  /*Future<void> clearData() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      final appDir = await getApplicationSupportDirectory();
      if (appDir.existsSync()) {
        appDir.deleteSync(recursive: true);
      }
      final dbDir = await getDatabasesPath();
      final dir = Directory(dbDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } catch (err) {
      // print('Caught error: $err');
    }
  }*/
}
