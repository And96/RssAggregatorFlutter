import 'package:rss_aggregator_flutter/core/utility.dart';

class Feed {
  var link = "";
  var title = "";
  DateTime? pubDate;
  var iconUrl = "";
  var host = "";
  Feed(
      {required this.link,
      required this.title,
      required this.pubDate,
      required this.iconUrl,
      required this.host});

  factory Feed.fromMap(Map<String, dynamic> json) {
    return Feed(
      link: json["link"],
      title: json["title"],
      pubDate: Utility().tryParse(json["pubDate"]),
      iconUrl: json["iconUrl"],
      host: json["host"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'link': link,
      'title': title,
      'pubDate': Utility().tryParse(pubDate.toString()).toIso8601String(),
      "iconUrl": iconUrl,
      'host': host,
    };
  }

  @override
  String toString() => '{title: $title link: $link}';
}
