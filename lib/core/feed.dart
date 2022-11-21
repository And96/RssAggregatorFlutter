import 'package:rss_aggregator_flutter/core/utility.dart';

class Feed {
  var link = "";
  var title = "";
  DateTime pubDate;
  var iconUrl = "";
  var host = "";
  var siteID = 0;
  Feed(
      {required this.link,
      required this.title,
      required this.pubDate,
      required this.iconUrl,
      required this.host,
      required this.siteID});

  factory Feed.fromMap(Map<String, dynamic> json) {
    return Feed(
      link: json["link"],
      title: json["title"],
      pubDate: Utility().tryParse(json["pubDate"]),
      iconUrl: json["iconUrl"],
      host: json["host"],
      siteID: json["siteID"],
    );
  }

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      link: json["link"].toString(),
      title: json["title"].toString(),
      pubDate: Utility().tryParse(json["pubDate"]),
      iconUrl: json["iconUrl"].toString(),
      host: json["host"].toString(),
      siteID: json["siteID"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'link': link,
      'title': title,
      'pubDate': Utility().tryParse(pubDate.toString()).toIso8601String(),
      "iconUrl": iconUrl,
      'host': host,
      'siteID': siteID,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'title': title,
      'pubDate': Utility().tryParse(pubDate.toString()).toIso8601String(),
      "iconUrl": iconUrl,
      'host': host,
      'siteID': siteID,
    };
  }

  @override
  String toString() => '{title: $title link: $link}';
}
