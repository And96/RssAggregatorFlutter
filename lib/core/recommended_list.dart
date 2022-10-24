import 'dart:convert';
//import 'package:flutter/material.dart';
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
  RecommendedSite(this.siteLink, this.iconUrl, this.category, this.siteName);
  final String siteName;
  final String siteLink;
  final String iconUrl;
  final String category;

  factory RecommendedSite.fromJson(Map<String, dynamic> data) {
    final siteName = data['siteName'] as String;
    final siteLink = data['siteLink'] as String;
    final iconUrl = data['iconUrl'] as String;
    final category = data['category'] as String;
    return RecommendedSite(siteName, siteLink, iconUrl, category);
  }
}

class RecommendedList {
  late List<RecommendedCategory> items = [];

//0xe50c icon must be converted to integer using online hex to convert
//validate json with https://jsonlint.com/
  String json = """[{
		"name": "Tecnologia",
		"color": 4283215696,
		"iconData": 58865,
		"language": "it",
		"sites": [{
				"siteName": "tuttoandroid.net",
				"siteLink": "https://tuttoandroid.net/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/tuttoandroid.net.ico",
				"category": "News"
			},
			{
				"siteName": "hdblog.it",
				"siteLink": "https://hdblog.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/hdblog.it.ico",
				"category": "News"
			},
			{
				"siteName": "androidworld.it",
				"siteLink": "https://androidworld.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/androidworld.it.ico",
				"category": "News"
			}
		]
	},
	{
		"name": "Sport",
		"color": 4278351805,
		"iconData": 58302,
		"language": "it",
		"sites": [{
				"siteName": "gazzetta.it",
				"siteLink": "https://tuttoandroid.net/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/tuttoandroid.net.ico",
				"category": "News"
			},
			{
				"siteName": "hdblog.it",
				"siteLink": "https://hdblog.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/hdblog.it.ico",
				"category": "News"
			},
			{
				"siteName": "androidworld.it",
				"siteLink": "https://androidworld.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/androidworld.it.ico",
				"category": "News"
			}
		]
	}
  ,
	{
		"name": "Bergamo",
		"color": 4289533015,
		"iconData": 58866,
		"language": "it",
		"sites": [{
				"siteName": "gazzetta.it",
				"siteLink": "https://tuttoandroid.net/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/tuttoandroid.net.ico",
				"category": "News"
			},
			{
				"siteName": "hdblog.it",
				"siteLink": "https://hdblog.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/hdblog.it.ico",
				"category": "News"
			},
			{
				"siteName": "androidworld.it",
				"siteLink": "https://androidworld.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/androidworld.it.ico",
				"category": "News"
			}
		]
	}
  ,
	{
		"name": "Gossip",
		"color": 4279060385,
		"iconData": 61871,
		"language": "it",
		"sites": [{
				"siteName": "gazzetta.it",
				"siteLink": "https://tuttoandroid.net/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/tuttoandroid.net.ico",
				"category": "News"
			},
			{
				"siteName": "hdblog.it",
				"siteLink": "https://hdblog.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/hdblog.it.ico",
				"category": "News"
			},
			{
				"siteName": "androidworld.it",
				"siteLink": "https://androidworld.it/feed/",
				"iconUrl": "https://icons.duckduckgo.com/ip3/androidworld.it.ico",
				"category": "News"
			}
		]
	}
]""";

  Future<bool> load() async {
    try {
      await save(json);
      items = await get();
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

  Future<List<RecommendedCategory>> get() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_recommended') ?? '[]');
      late List<RecommendedCategory> list = List<RecommendedCategory>.from(
          jsonData.map((model) => RecommendedCategory.fromJson(model)));
      //sort
      //items.sort((a, b) => b.pubDate!.compareTo(a.pubDate!));
      return list;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }
}
