import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

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
          .replaceAll(".", "")
          .replaceAll("rss", "")
          .replaceAll("feed", "");
    } catch (err) {
      // print('Caught error: $err');
    }
    return inputText.toString();
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  DateTime tryParse(String formattedDate) {
    try {
      var dateTime =
          DateFormat("yyyy-MM-dd HH:mm:ss").parse(formattedDate, true);

//test on mobile because desktop is always english
      /* var utc = DateTime.parse("2020-06-11 17:47:35 Z");
      print(utc.toString()); // 2020-06-11 17:47:35.000Z
      print(utc.isUtc.toString()); // true
      print(utc.toLocal().toString());*/

      return dateTime.toLocal();

      //return DateTime.parse(datetime).toUtc().toLocal();
    } on FormatException {
      DateTime now = DateTime.now();
      return DateTime(now.year, now.month, now.day).toLocal();
    }
  }
}
