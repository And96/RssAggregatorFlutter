import 'package:feed_finder/feed_finder.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart';

class Site {
  var siteName = "";
  var siteLink = "";
  var iconUrl = "";
  Site({
    required this.siteName,
    required this.siteLink,
    required this.iconUrl,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      siteName: json["siteName"],
      siteLink: json["siteLink"],
      iconUrl: json["iconUrl"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "siteName": siteName,
      "siteLink": siteLink,
      "iconUrl": iconUrl,
    };
  }

  @override
  String toString() =>
      '{siteName: $siteName siteLink: $siteLink iconUrl: $iconUrl}';

  static Future<String> getUrlFormatted(String url, bool advancedSearch) async {
    try {
      if (url.isEmpty) {
        return "";
      }
      url = url.trim();
      if (url.length < 4) {
        return "";
      }
      if (url.trim().startsWith("%")) {
        return "";
      }
      if (url.contains(".") && !url.startsWith("http")) {
        url = "https://$url";
      }
      bool valid = await isUrlRSS(url);
      if (valid) {
        return url;
      }
      url = await getRssFromUrl(url, advancedSearch);

      return url;
    } catch (err) {
      // print('Caught error: $err');
    }
    return "";
  }

  static Future<bool> isUrlRSS(String url) async {
    try {
      final response =
          await get(Uri.parse(url)).timeout(const Duration(milliseconds: 3000));
      var channel = RssFeed.parse(response.body);
      if (channel.items!.isNotEmpty) {
        return true;
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  static Future<String> getRssFromUrl(String url, bool advancedSearch) async {
    try {
      //70% of websites use this template for rss
      if (url.endsWith("/")) {
        url = url.substring(0, url.length - 1);
      }
      if (url.contains(".")) {
        String urlRss = "$url/feed/";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (!advancedSearch) {
        return "";
      }
      //search rss in html
      if (url.contains(".")) {
        try {
          List<String> rssUrls = await FeedFinder.scrape(url);
          for (String rssUrl in rssUrls) {
            if (!rssUrl.contains("comment")) {
              bool valid = await isUrlRSS(rssUrl);
              if (valid) {
                return rssUrl;
              }
            }
          }
        } catch (err) {/**/}
      }

      //try common rss url
      if (url.contains(".")) {
        String urlRss = "$url/rss/";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains("medium") && url.contains("/tag")) {
        String urlRss = url.replaceAll("tag/", "feed/tag/");
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains("medium.com")) {
        String urlRss = url.replaceAll("medium.com/", "medium.com/feed/");
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains("ecodibergamo") &&
          !url.contains("/feed/") &&
          !url.contains("rss")) {
        String urlRss = "https://www.ecodibergamo.it/feeds/latesthp/268/";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/blog/rss.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/blog/rss";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/blog/feed/";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/feeds/";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/category/feed/";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/tag/feed/";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/rss.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/feed.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/blog/rss.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/it/feed/";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/en/feed/";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/rss2.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/rss/home.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/rss/all/rss2.0.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/atom.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/feeds/news.rss";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/feed.rss";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains(".")) {
        String urlRss = "$url/latest.rss";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.length > 1) {
        String urlRss =
            "https://news.google.com/rss/search?q=${url.replaceAll("http://", "").replaceAll("https://", "").replaceAll("www.", "")}";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.length > 1) {
        String hostsiteName = url;
        if (hostsiteName.replaceAll("//", "/").contains("/")) {
          hostsiteName = Uri.parse(url.toString()).host.toString();
        }
        String urlRss =
            "http://feeds.feedburner.com/${hostsiteName.replaceAll(".com", "").replaceAll(".it", "").replaceAll(".net", "").replaceAll(".org", "")}";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return "";
  }
}
