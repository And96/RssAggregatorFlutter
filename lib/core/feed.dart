import 'package:rss_aggregator_flutter/core/utility.dart';

class Feed {
  var title = "";
  var link = "";
  var host = "";
  DateTime? pubDate;
  var iconUrl = "";
  Feed(
      {required this.link,
      required this.title,
      required this.pubDate,
      required this.iconUrl,
      required this.host});

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      title: json["title"],
      link: json["link"],
      host: json["host"],
      pubDate: Utility().tryParse(json["pubDate"]),
      iconUrl: json["iconUrl"],
    );
  }

  Map<String, String> toJson() {
    return {
      "title": title,
      "link": link,
      "host": host,
      "pubDate": Utility().tryParse(pubDate.toString()).toIso8601String(),
      "iconUrl": iconUrl,
    };
  }

  @override
  String toString() => '{title: $title link: $link}';
}
