import 'dart:io';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rss_aggregator_flutter/core/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
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

  String dateFormat(BuildContext context, DateTime date) {
    try {
      var languageTag = "it"; // TO-DO IMPLEMENT LANGUAGE LATER
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);

      if (languageTag.toString().toLowerCase().contains("it") == true) {
        final aDate = DateTime(date.year, date.month, date.day);
        if (aDate == today) {
          return "Oggi${DateFormat(' HH:mm').format(
            date.toLocal(),
          )}";
        } else if (aDate == yesterday) {
          return "Ieri${DateFormat(' HH:mm').format(
            date.toLocal(),
          )}";
        } else if (aDate.year == today.year) {
          return DateFormat('dd/MM/yy HH:mm').format(
            date.toLocal(),
          );
        } else {
          return DateFormat('dd/MM/yy HH:mm').format(
            date.toLocal(),
          );
        }
      }

      return DateFormat('dd MMM HH:mm').format(
        date.toLocal(),
      );
    } catch (err) {
      // print('Caught error: $err');
    }
    return date.toString();
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  String cleanText(String? inputText) {
    try {
      return inputText
          .toString()
          .replaceAll("&agrave;", "a")
          .replaceAll("&egrave;", "e")
          .replaceAll("&igrave;", "i")
          .replaceAll("&ograve;", "o")
          .replaceAll("&ugrave;", "u")
          .replaceAll("&aacute;", "a")
          .replaceAll("&eacute;", "e")
          .replaceAll("&iacute;", "i")
          .replaceAll("&oacute;", "o")
          .replaceAll("&uacute;", "u")
          .replaceAll("�", " ")
          .replaceAll("&#039;", " ")
          .replaceAll("&quot;", " ")
          .replaceAll("&#8217;", "'")
          .replaceAll(RegExp('&#[0-9]{1,5};'), " ")
          .replaceAll(RegExp('&[a-z]{3,6};'), " ")
          .replaceAll(RegExp('<[/]{0,1}[a-z]{1,10}[ ]{0,1}[/]{0,1}>'), " ")
          .replaceAll('\n', ". ")
          .replaceAll("  ", " ")
          .replaceAll("  ", " ")
          .trim();
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
    DateTime now = DateTime.now().toUtc();
    DateTime defaultDate = DateTime.now().hour > 12
        ? DateTime.utc(now.year, now.month, now.day) //midnight today
        : DateTime.utc(now.year, now.month, now.day)
            .add(const Duration(days: -1)); //midnight yesterday
    bool ok = false;
    try {
      DateTime dataOra = DateTime.utc(now.year, now.month, now.day);

      if (dateString.toLowerCase().trim() == "null") {
        return defaultDate;
      }

      //TEST 1 DATA NORMALE
      //print(DateTime.parse('2020-01-02')); // 2020-01-02 00:00:00.000
      //print(DateTime.parse('20200102')); // 2020-01-02 00:00:00.000
      //print(DateTime.parse('-12345-03-04')); // -12345-03-04 00:00:00.000
      //print(DateTime.parse('2020-01-02 07')); // 2020-01-02 07:00:00.000
      //print(DateTime.parse('2020-01-02T07')); // 2020-01-02 07:00:00.000
      //print(DateTime.parse('2020-01-02T07:12')); // 2020-01-02 07:12:00.000
      //print(DateTime.parse('2020-01-02T07:12:50')); // 2020-01-02 07:12:50.000
      //print(DateTime.parse('2020-01-02T07:12:50Z')); // 2020-01-02 07:12:50.000Z
      //print(DateTime.parse('2020-01-02T07:12:50+07')); // 2020-01-02 00:12:50.000Z
      //print(DateTime.parse('2020-01-02T07:12:50+0700')); // 2020-01-02 00:12:50.00
      //print(DateTime.parse('2020-01-02T07:12:50+07:00')); // 2020-01-02 00:12:50.00
      if (ok == false) {
        try {
          dataOra = DateTime.tryParse(dateString)!.toUtc();
          ok = true;
        } catch (err) {
          //
        }
      }

      //TEST 2 FORMATO HTTP
      //Wed, 28 Oct 2020 01:02:03 GMT
      //Wednesday, 28-Oct-2020 01:02:03 GMT
      //Wed Oct 28 01:02:03 2020
      if (ok == false) {
        try {
          dataOra = HttpDate.parse(dateString).toUtc();
          ok = true;
        } catch (err) {
          //
        }
      }

      //TEST 3 DATEFORMAT
      //Sat, 12 Nov 2022 12:00:00 +0200
      if (ok == false) {
        try {
          DateTime dataOraSenzaTimeZome =
              DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(dateString);
          if (dateString.contains("+") || dateString.contains("-")) {
            final regex = RegExp(r'([\+\-])([0-9]{2}):{0,1}([0-9]{2})');
            final match = regex.firstMatch(dateString);
            if (match != null && match.groupCount >= 1) {
              int sign = match.group(1).toString() == "-" ? 1 : -1;
              int hoursTimeZone = int.parse(match.group(2).toString());
              int minutesTimeZone = int.parse(match.group(3).toString());
              dataOra = DateTime.utc(
                  dataOraSenzaTimeZome.year,
                  dataOraSenzaTimeZome.month,
                  dataOraSenzaTimeZome.day,
                  dataOraSenzaTimeZome.hour + (hoursTimeZone * sign),
                  dataOraSenzaTimeZome.minute + (minutesTimeZone * sign),
                  dataOraSenzaTimeZome.second);
            }
            ok = true;
          }
        } catch (err) {
          //
        }
      }

      //TEST 4 WEBFEED + CASO SKY (say GMT, but no gmt, it's italian. dont lose time, it's italian only. time is ok)
      //sab, 12 nov 2022 13:40:00 GMT
      if (ok == false) {
        try {
          dateString = dateString
              .toLowerCase()
              .replaceAll("lun", "Mon")
              .replaceAll("mar", "Tue")
              .replaceAll("mer", "Wed")
              .replaceAll("gio", "Thu")
              .replaceAll("ven", "Fri")
              .replaceAll("sab", "Sat")
              .replaceAll("dom", "Sun")
              .replaceAll("gen", "Jan")
              .replaceAll("feb", "Feb")
              .replaceAll("mar", "Mar")
              .replaceAll("apr", "Apr")
              .replaceAll("mag", "May")
              .replaceAll("giu", "Jun")
              .replaceAll("lug", "Jul")
              .replaceAll("ago", "Ago")
              .replaceAll("set", "Sep")
              .replaceAll("ott", "Oct")
              .replaceAll("nov", "Nov")
              .replaceAll("dic", "Dec");
          const rfc822DatePattern = 'EEE, dd MMM yyyy HH:mm:ss Z';
          final num length =
              dateString.length.clamp(0, rfc822DatePattern.length);
          final trimmedPattern = rfc822DatePattern.substring(
              0,
              length
                  as int?); //Some feeds use a shortened RFC 822 date, e.g. 'Tue, 04 Aug 2020'
          final format = DateFormat(trimmedPattern, 'en_US');
          dataOra = format.parse(dateString);
          ok = true;
        } catch (err) {
          //
        }
      }

      /*if (ok = false) {
        print("errore conversione data");
        print(dateString);
      }*/

      //wrong date future, back to midnight
      //Corriere dello sport return Sat, 12 Nov 2022 15:09:42 GMT while it's 14.10 ???
      //Sky dont respect GMT too 99% are ok
      if (dataOra.isAfter(DateTime.now().toUtc())) {
        /* print("data futura");
        print(dateString);
        print(dataOra);*/
        return defaultDate;
      }
      return dataOra;
    } catch (err) {
      return defaultDate;
      //return DateTime(now.year, now.month, now.day).toLocal();
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
    'tromb',
    'mort',
    'lott',
    'scomme',
    'ucci',
    'figa',
    'caz',
    'lesb',
    'drog',
    'vagi',
    'pene',
    'culo',
    'tett',
    'stupr',
    'arm',
    'guerr',
    'war',
    'kil',
    'nud',
    'nak',
    'mastur'
  ];
}
