// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:favicon/favicon.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SiteIcon {
  String? siteName = "";
  String? iconUrl = "";
  SiteIcon({
    this.siteName,
    this.iconUrl,
  });

  factory SiteIcon.fromJson(Map<String, dynamic> json) {
    return SiteIcon(
      siteName: json["siteName"],
      iconUrl: json["iconUrl"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "siteName": siteName,
      "iconUrl": iconUrl,
    };
  }

  @override
  String toString() => '{siteName: $siteName iconUrl: $iconUrl}';

  Future<String> getIcon(String siteName, String siteUrl) async {
    String iconUrl = "";
    try {
      //search icon via google api
      iconUrl = await getIconDuckDuckGo(siteName);
      if (iconUrl.length > 5) {
        return iconUrl;
      }

      //search icon via google api
      iconUrl = await getIconGoogle(siteName);
      if (iconUrl.length > 5) {
        return iconUrl;
      }

      //search icon locally
      iconUrl = await getIconLocal(siteName);
      if (iconUrl.length > 5) {
        return iconUrl;
      }

      //l'icona si potrebbe prendere anche dal feed rss per i siti che la compilano da image > link, li ce l'url esempio HDBLOG

      //fetch icon from web
      iconUrl = await getIconWeb(siteName);
      if (iconUrl.length < 5) {
        iconUrl = "";
      } else {
        await saveIconLocal(siteName, iconUrl);
      }
    } catch (e) {}
    return iconUrl;
  }

  Future<String> getIconGoogle(String url) async {
    try {
      String iconFinderUrl =
          "https://www.google.com/s2/favicons?sz=64&domain_url=$url";

      final response = await get(Uri.parse(iconFinderUrl))
          .timeout(const Duration(milliseconds: 10000));

      //if google return default icon
      if (response.body.padRight(100).substring(0, 100).contains("pHYs")) {
        if (response.body.padRight(100).substring(0, 100).contains("IDAT8")) {
          return "";
        }
      }
      //if google find the icon
      if (response.body.substring(0, 100).toLowerCase().contains("png")) {
        return iconFinderUrl;
      }
      if (response.body.substring(0, 100).toLowerCase().contains("ico")) {
        return iconFinderUrl;
      }
      if (response.body.substring(0, 100).toLowerCase().contains("jfif")) {
        return iconFinderUrl;
      }
      if (response.body.substring(0, 100).toLowerCase().contains("jpg")) {
        return iconFinderUrl;
      }
      if (response.body.substring(0, 100).toLowerCase().contains("jpeg")) {
        return iconFinderUrl;
      }
      if (response.body.substring(0, 100).toLowerCase().contains("webp")) {
        return iconFinderUrl;
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return "";
  }

  Future<String> getIconDuckDuckGo(String url) async {
    try {
      url = url.replaceAll("https://", "").replaceAll("http://", "");
      String iconFinderUrl = "https://icons.duckduckgo.com/ip3/$url.ico";

      final response = await get(Uri.parse(iconFinderUrl))
          .timeout(const Duration(milliseconds: 10000));

      //if google return default icon
      if (response.body.padRight(1500).substring(0, 1500).contains("?3v")) {
        if (response.body.padRight(1500).substring(0, 1500).contains(":nCa")) {
          return "";
        }
      }
      //if duckduckgo find the icon
      if (response.body.substring(0, 100).toLowerCase().contains("png")) {
        return iconFinderUrl;
      }
      if (response.body.substring(0, 100).toLowerCase().contains("ico")) {
        return iconFinderUrl;
      }
      if (response.body.substring(0, 100).toLowerCase().contains("jfif")) {
        return iconFinderUrl;
      }
      if (response.body.substring(0, 100).toLowerCase().contains("jpg")) {
        return iconFinderUrl;
      }
      if (response.body.substring(0, 100).toLowerCase().contains("jpeg")) {
        return iconFinderUrl;
      }
      if (response.body.substring(0, 100).toLowerCase().contains("webp")) {
        return iconFinderUrl;
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return "";
  }

  Future<String> getIconWeb(String url) async {
    String iconUrl = "";
    try {
      //fetch icon from network
      var favicon = await FaviconFinder.getBest("https://$url")
          .timeout(const Duration(milliseconds: 7000));

      if (favicon?.url != null) {
        iconUrl = favicon!.url.toString();
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return iconUrl;
  }

  Future<String> getIconLocal(String siteName) async {
    String iconUrl = "";
    try {
      //read all icons
      List<SiteIcon> listIconUrl = await getListIconLocal();

      //search icon for this url
      if (listIconUrl.isNotEmpty) {
        var iconUrl = listIconUrl.where((e) => e.siteName == siteName);
        if (iconUrl.isNotEmpty) {
          return iconUrl.first.iconUrl.toString();
        }
      }
    } catch (e) {}
    return iconUrl;
  }

  Future<List<SiteIcon>> getListIconLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_site_icon') ?? '[]');
      return List<SiteIcon>.from(
          jsonData.map((model) => SiteIcon.fromJson(model)));
    } catch (e) {
      throw 'Error reading icons url';
    }
  }

  Future<String> saveIconLocal(String siteName, String iconUrl) async {
    try {
      if (siteName.trim.toString() != "" && iconUrl.trim().toString() != "") {
        //read all icons
        List<SiteIcon> listIconUrl = await getListIconLocal();

        //remove icon if exists
        listIconUrl.removeWhere((e) => (e.siteName == siteName));

        //add new icon
        var i = SiteIcon(
          siteName: siteName,
          iconUrl: iconUrl,
        );
        listIconUrl.add(i);

        //save to memory
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('db_site_icon', jsonEncode(listIconUrl));
      }
    } catch (e) {}
    return iconUrl;
  }
}
