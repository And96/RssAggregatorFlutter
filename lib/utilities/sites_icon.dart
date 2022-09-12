// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:favicon/favicon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IconUrl {
  var websiteUrl = "";
  var iconUrl = "";
  IconUrl({
    required this.websiteUrl,
    required this.iconUrl,
  });

  factory IconUrl.fromJson(Map<String, dynamic> json) {
    return IconUrl(
      websiteUrl: json["websiteUrl"],
      iconUrl: json["iconUrl"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "websiteUrl": websiteUrl,
      "iconUrl": iconUrl,
    };
  }

  @override
  String toString() => '{websiteUrl: $websiteUrl iconUrl: $iconUrl}';
}

class SitesIcon {
  Future<String> getIcon(String url) async {
    String iconUrl = "";
    try {
      //get hostname from full url (Because some sites return rss file directly)
      String hostname = url;
      if (hostname.contains("/")) {
        hostname = Uri.parse(url.toString()).host.toString();
      }

      //search icon locally
      iconUrl = await getIconLocal(hostname);
      if (iconUrl.length > 5) {
        return iconUrl;
      }

      //fetch icon from web
      iconUrl = await getIconWeb(hostname);
      if (iconUrl.length < 5) {
        iconUrl = "";
      } else {
        saveIconLocal(hostname, iconUrl);
      }
    } catch (e) {}
    return iconUrl;
  }

  Future<String> getIconWeb(String url) async {
    String iconUrl = "";
    try {
      /* List<String>? suffixesFormat = ["ico", "png"];
      List<Favicon> favicons =
          await FaviconFinder.getAll("https://$url", suffixes: suffixesFormat);
      iconUrl = favicons.isNotEmpty ? favicons.first.url.toString() : "";*/

      //fetch icon from network
      var favicon = await FaviconFinder.getBest("https://$url")
          .timeout(const Duration(milliseconds: 10000));

      if (favicon?.url != null) {
        iconUrl = favicon!.url.toString();
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return iconUrl;
  }

  Future<String> getIconLocal(String url) async {
    String iconUrl = "";
    try {
      //read all icons
      List<IconUrl> listIconsUrl = await getListIconLocal(url);

      //search icon for this url
      if (listIconsUrl.isNotEmpty) {
        var iconUrl = listIconsUrl.where((e) => e.websiteUrl == url);
        if (iconUrl.isNotEmpty) {
          return iconUrl.first.iconUrl;
        }
      }
    } catch (e) {}
    return iconUrl;
  }

  Future<List<IconUrl>> getListIconLocal(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('icons_url') ?? '[]');
      return List<IconUrl>.from(
          jsonData.map((model) => IconUrl.fromJson(model)));
    } catch (e) {
      throw 'Error reading icons url $url';
    }
  }

  Future<String> saveIconLocal(String url, String iconUrl) async {
    try {
      if (url.trim.toString() != "" && iconUrl.trim().toString() != "") {
        //read all icons
        List<IconUrl> listIconsUrl = await getListIconLocal(url);

        //remove icon if exists
        listIconsUrl.removeWhere((e) => (e.websiteUrl == url));

        //add new icon
        var i = IconUrl(
          websiteUrl: url,
          iconUrl: iconUrl,
        );
        listIconsUrl.add(i);

        //save to memory
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('icons_url', jsonEncode(listIconsUrl));
      }
    } catch (e) {}
    return iconUrl;
  }
}
