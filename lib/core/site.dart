import 'package:feed_finder/feed_finder.dart';
import 'dart:io';
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
      if (response.body.substring(0, 500).contains("<channel")) {
        var channel = RssFeed.parse(response.body);
        if (channel.items!.isNotEmpty) {
          return true;
        }
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  static String getHostName(String url, bool includeProtocol) {
    try {
      String hostName = url;
      if (hostName.replaceAll("//", "/").contains("/")) {
        hostName = Uri.parse(url.toString()).host.toString();
      }
      if (url.contains("http:")) {
        return 'http://$hostName';
      } else {
        return 'https://$hostName';
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return url;
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

      String name = getHostName(url, false);

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

      if (url.contains("tg24.sky") &&
          !url.contains("/feed") &&
          !url.contains("rss")) {
        String urlRss = "https://tg24.sky.it/rss/tg24_flipboard.cronaca.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains("rainews.it") &&
          !url.contains("/feed") &&
          !url.contains("rss")) {
        String urlRss = "https://www.rainews.it/rss/tutti";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains("la7.it") && !url.contains("/feed")) {
        String urlRss =
            "https://news.google.com/rss/search?q=site:la7.it+when:2d&hl=it&gl=IT&ceid=IT:it";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains("rai.it") &&
          !url.contains("/feed") &&
          !url.contains("rss")) {
        String urlRss =
            "https://www.servizitelevideo.rai.it/televideo/pub/rss101.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains("corriere.it") &&
          !url.contains("/feed") &&
          !url.contains("rss")) {
        String urlRss = "http://xml2.corriereobjects.it/rss/homepage.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains("ilsole24ore.com") &&
          !url.contains("/feed") &&
          !url.contains("rss")) {
        String urlRss = "https://www.ilsole24ore.com/rss/italia--attualita.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }
      if (url.contains("ansa.it") &&
          !url.contains("/feed") &&
          !url.contains("rss")) {
        String urlRss = "https://www.ansa.it/sito/ansait_rss.xml";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }

      if (url.contains("sport.sky.it") &&
          !url.contains("/feed") &&
          !url.contains("rss")) {
        String urlRss =
            "https://news.google.com/rss/search?q=site:sport.sky.it+when:2d&hl=it&gl=IT&ceid=IT:it";
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
        final String defaultLocale = Platform.localeName;
        String langGoogleNews = "";
        if (defaultLocale.toString().toLowerCase().contains("it")) {
          langGoogleNews = "&hl=it&gl=IT&ceid=IT:it";
        } else {
          langGoogleNews = "&hl=en-US&gl=US&ceid=US:en";
        }
        //https://news.google.com/rss?hl=<LANGUAGE_CODE>&gl=<COUNTRY_CODE>&ceid=<COUNTRY_CODE>:<LANGUAGE_CODE>'
        String urlRss =
            "https://news.google.com/rss/search?q=${name.replaceAll("http://", "").replaceAll("https://", "").replaceAll("www.", "")}+when:2d$langGoogleNews";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }

      if (url.length > 1) {
        String urlRss =
            "http://feeds.feedburner.com/${name.replaceAll(".com", "").replaceAll(".it", "").replaceAll(".net", "").replaceAll(".org", "")}";
        bool valid = await isUrlRSS(urlRss);
        if (valid) {
          return urlRss;
        }
      }

      if (url.length > 1) {
        String urlRss =
            "https://www.bing.com/news/search?q=${name.replaceAll("http://", "").replaceAll("https://", "").replaceAll("www.", "")}&format=rss";
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

  List<String> getUrlsFromText(String text) {
    try {
      RegExp exp =
          RegExp(r'(?:(?:https?|http):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
      Iterable<RegExpMatch> matches = exp.allMatches(text);
      List<String> listUrl = [];
      for (var match in matches) {
        if (match.toString().length > 6) {
          listUrl.add(text.substring(match.start, match.end));
        }
      }
      return listUrl;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }
}
