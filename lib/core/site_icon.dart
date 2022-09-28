// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:favicon/favicon.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      /*   //get siteHostname from full url (Because some sites return rss file directly)
      String siteHostname = siteUrl;
      if (siteHostname.contains("/")) {
        siteHostname = Uri.parse(siteUrl.toString()).host.toString();
      }*/

      //search icon locally
      iconUrl = await getIconLocal(siteName);
      if (iconUrl.length > 5) {
        return iconUrl;
      }

      //l'icona si potrebbe prendere anche dal feed rss per i siti che la mpilano da image > link, li ce l'url esempio HDBLOG

      //fetch icon from web
      iconUrl = await getIconWeb(siteName);
      if (iconUrl.length < 5) {
        iconUrl = "";
      } else {
        saveIconLocal(siteName, iconUrl);
      }
    } catch (e) {}
    return iconUrl;
  }

  Future<String> getIconWeb(String url) async {
    String iconUrl = "";
    try {
      /* try { --medium dont work, it has icon but not available at that url
        //fetch icon from network (.ico only for fast performance)
        List<String>? suffixesFormat = ["ico"];
        List<Favicon> favicons =
            await FaviconFinder.getAll("https://$url", suffixes: suffixesFormat)
                .timeout(const Duration(milliseconds: 1500));
        iconUrl = favicons.isNotEmpty ? favicons.first.url.toString() : "";
        if (iconUrl != "") {
          return iconUrl;
        }
      } catch (err) {
        // print('Caught error: $err');
      }*/

      //fetch icon from network
      var favicon = await FaviconFinder.getBest("https://$url")
          .timeout(const Duration(milliseconds: 6000));

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
        prefs.setString('db_site_icon', jsonEncode(listIconUrl));
      }
    } catch (e) {}
    return iconUrl;
  }
}
