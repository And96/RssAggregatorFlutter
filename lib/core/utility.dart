import 'package:url_launcher/url_launcher.dart';

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

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  DateTime tryParse(String formattedString) {
    try {
      return DateTime.parse(formattedString).toLocal();
    } on FormatException {
      DateTime now = DateTime.now();
      return DateTime(now.year, now.month, now.day).toLocal();
    }
  }
}
