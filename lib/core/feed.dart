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
}
