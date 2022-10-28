import 'dart:convert';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendedCategory {
  RecommendedCategory(
      this.name, this.color, this.iconData, this.language, this.sites);
  final String name;
  final int color;
  final int iconData;
  final String language;
  final List<RecommendedSite> sites;

  factory RecommendedCategory.fromJson(Map<String, dynamic> data) {
    final name = data['name'] as String;
    final color = data['color'] as int;
    final iconData = data['iconData'] as int;
    final language = data['language'] as String;
    final sitesData = data['sites'] as List<dynamic>?;
    final sites = sitesData != null
        ? sitesData
            .map((reviewData) => RecommendedSite.fromJson(reviewData))
            .toList()
        : <RecommendedSite>[];
    return RecommendedCategory(name, color, iconData, language, sites);
  }
}

class RecommendedSite {
  RecommendedSite(this.siteName, this.siteLink, this.iconUrl);
  final String siteName;
  final String siteLink;
  final String iconUrl;
  bool added = false;

  factory RecommendedSite.fromJson(Map<String, dynamic> data) {
    final siteName = data['siteName'] as String;
    final siteLink = data['siteLink'] as String;
    final iconUrl = data['iconUrl'] as String;
    return RecommendedSite(siteName, siteLink, iconUrl);
  }
}

class RecommendedList {
  late List<RecommendedCategory> items = [];

//validate json with https://jsonlint.com/
//for icons
//https://api.flutter.dev/flutter/material/Icons-class.html
//0xe50c icon must be converted to integer using online hex to convert https://www.binaryhexconverter.com/hex-to-decimal-converter

  String json = """[{
		"name": "Tecnologia",
		"color": 4281408402,
		"iconData": 62571,
		"language": "italiano",
		"sites": [{
				"siteName": "tuttoandroid.net",
				"siteLink": "https://tuttoandroid.net/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/tuttoandroid.net.ico"
			},
			{
				"siteName": "hdblog.it",
				"siteLink": "https://hdblog.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/hdblog.it.ico"
			},
			{
				"siteName": "androidworld.it",
				"siteLink": "https://androidworld.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/androidworld.it.ico"
			}
		]
	},
	{
		"name": "Motori",
		"color": 4283215696,
		"iconData": 58865,
		"language": "italiano",
		"sites": [{
			"siteName": "partitaiva24.it",
			"siteLink": "https://test.net/feed/",
			"iconUrl": "https://icons.duckduckgo.com/ip3/partitaiva24.it.ico"
		}]
	},
	{
		"name": "Sport",
		"color": 4278351805,
		"iconData": 58857,
		"language": "italiano",
		"sites": [{
				"siteName": "gazzetta.it",
				"siteLink": "https://tuttoandroid.net/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/tuttoandroid.net.ico"
			},
			{
				"siteName": "hdblog.it",
				"siteLink": "https://hdblog.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/hdblog.it.ico"
			},
			{
				"siteName": "androidworld.it",
				"siteLink": "https://androidworld.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/androidworld.it.ico"
			}
		]
	},
	{
		"name": "Bergamo",
		"color": 4289533015,
		"iconData": 61871,
		"language": "italiano",
		"sites": [{
				"siteName": "bergamonews.it",
				"siteLink": "https://bergamonews.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/bergamonews.it.ico"
			},
			{
				"siteName": "hdblog.it",
				"siteLink": "https://hdblog.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/hdblog.it.ico"
			},
			{
				"siteName": "xda-developers.com",
				"siteLink": "https://xda-developers.com/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/xda-developers.com.ico"
			},
			{
				"siteName": "xiaomitoday.it",
				"siteLink": "https://xiaomitoday.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/xiaomitoday.it.ico"
			},
			{
				"siteName": "andreagaleazzi.com",
				"siteLink": "https://andreagaleazzi.com/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/andreagaleazzi.com.ico"
			},
			{
				"siteName": "open.online",
				"siteLink": "https://open.online/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/open.online.ico"
			},
			{
				"siteName": "telefonino.net",
				"siteLink": "https://telefonino.net/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/telefonino.net.ico"
			},
			{
				"siteName": "androidworld.it",
				"siteLink": "https://androidworld.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/androidworld.it.ico"
			}
		]
	},
	{
		"name": "Lavoro",
		"color": 4292363029,
		"iconData": 58866,
		"language": "italiano",
		"sites": [{
			"siteName": "partitaiva24.it",
			"siteLink": "https://test.net/feed/",
			"iconUrl": "https://icons.duckduckgo.com/ip3/partitaiva24.it.ico"
		}]
	},
	{
		"name": "News",
		"color": 4278223759,
		"iconData": 984385,
		"language": "italiano",
		"sites": [{
			"siteName": "partitaiva24.it",
			"siteLink": "https://test.net/feed/",
			"iconUrl": "https://icons.duckduckgo.com/ip3/partitaiva24.it.ico"
		}]
	},
	{
		"name": "Gossip",
		"color": 4279060385,
		"iconData": 57943,
		"language": "italiano",
		"sites": [{
				"siteName": "gazzetta.it",
				"siteLink": "https://tuttoandroid.net/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/tuttoandroid.net.ico"
			},
			{
				"siteName": "hdblog.it",
				"siteLink": "https://hdblog.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/hdblog.it.ico"
			},
			{
				"siteName": "androidworld.it",
				"siteLink": "https://androidworld.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/androidworld.it.ico"
			}
		]
	},
	{
		"name": "Scienza",
		"color": 4278217052,
		"iconData": 58714,
		"language": "italiano",
		"sites": [{
			"siteName": "partitaiva24.it",
			"siteLink": "https://test.net/feed/",
			"iconUrl": "https://icons.duckduckgo.com/ip3/partitaiva24.it.ico"
		}]
	},
	{
		"name": "Gossip",
		"color": 4279060385,
		"iconData": 61871,
		"language": "english",
		"sites": [{
				"siteName": "gazzetta.it",
				"siteLink": "https://tuttoandroid.net/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/tuttoandroid.net.ico"
			},
			{
				"siteName": "hdblog.it",
				"siteLink": "https://hdblog.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/hdblog.it.ico"
			},
			{
				"siteName": "androidworld.it",
				"siteLink": "https://androidworld.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/androidworld.it.ico"
			}
		]
	}
]""";

  late SitesList sitesList = SitesList(updateItemLoading: _updateItemLoading);
  void _updateItemLoading(String itemLoading) {
    //setState(() {});
  }

  Future<bool> load(String language, String category) async {
    try {
      await save(json);
      items = await get(language, category);
      for (RecommendedCategory c in items) {
        for (RecommendedSite s in c.sites) {
          if (await sitesList.exists(s.siteLink)) {
            s.added = true;
          }
        }
      }

      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<void> save(String jsonRecommended) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('db_recommended', jsonRecommended);
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<List<RecommendedCategory>> get(
      String language, String category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_recommended') ?? '[]');
      late List<RecommendedCategory> list = List<RecommendedCategory>.from(
          jsonData.map((model) => RecommendedCategory.fromJson(model)));
      if (language.trim() != "") {
        list = list
            .where((e) =>
                e.language.toLowerCase() == language.toString().toLowerCase())
            .toList();
      }
      if (category.trim() != '') {
        list = list
            .where((e) =>
                e.name.toLowerCase().trim() ==
                category.toString().toLowerCase().trim())
            .toList();
      }

      return list;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }
}
