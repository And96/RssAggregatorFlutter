import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rss_aggregator_flutter/core/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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

  double round(double val, int places) {
    try {
      num mod = pow(10.0, places);
      return ((val * mod).round().toDouble() / mod);
    } catch (err) {
      // print('Caught error: $err');
    }
    return val;
  }

  bool compareSearch(List<String?> textList, String? textSearch) {
    try {
      for (var text in textList) {
        for (var value in textSearch.toString().split(";")) {
          if (cleanSearchText(text).contains(cleanSearchText(value))) {
            return true;
          }
        }
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  int daysBetween(DateTime from, DateTime to) {
    try {
      from = DateTime(from.year, from.month, from.day);
      to = DateTime(to.year, to.month, to.day);
      return (to.difference(from).inHours / 24).round();
    } catch (err) {
      // print('Caught error: $err');
    }
    return 0;
  }

  int minutesBetween(DateTime from, DateTime to) {
    try {
      return (to.difference(from).inMinutes).round();
    } catch (err) {
      // print('Caught error: $err');
    }
    return 0;
  }

  DateTime tryParse(String dateString) {
    try {
      print(dateString);

      DateTime dateLocal = DateTime.parse(dateString).toLocal();
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

  Future<void> clearData() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      final appDir = await getApplicationSupportDirectory();
      if (appDir.existsSync()) {
        appDir.deleteSync(recursive: true);
      }
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      DB().close;

      String path = await getDatabasesPath();
      await ((await openDatabase(
              join(await getDatabasesPath(), DB().databaseName)))
          .close());
      await deleteDatabase(path);
      databaseFactory.deleteDatabase;
      deleteDatabase(path);

      deleteDir(path);
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<void> deleteDir(String dirString) async {
    try {
      Directory dir = Directory(dirString);
      if (dir.existsSync()) {
        dir.listSync().forEach((e) {
          if (e.path.contains(".db")) {
            deleteFile(File(e.path));
          }
        });
      }
    } catch (e) {
      //print('Caught error: $e');
    }
  }

  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  List<String> blacklistParental = [
    'porn',
    'sess',
    'violen',
    'sex',
    'uccid',
    'tromb',
    'mort',
    'mastur'
  ];
}
