import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rss_aggregator_flutter/utilities/sites_icon.dart';
import 'package:webfeed/webfeed.dart';
import 'add_feed.dart';
import 'package:feed_finder/feed_finder.dart';

class Sito {
  var name = "";
  var link = "";
  var iconUrl = "";
  Sito({
    required this.name,
    required this.link,
    required this.iconUrl,
  });

  factory Sito.fromJson(Map<String, dynamic> json) {
    return Sito(
      name: json["name"],
      link: json["link"],
      iconUrl: json["iconUrl"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "link": link,
      "iconUrl": iconUrl,
    };
  }

  @override
  String toString() => '{link: $link}';
}

class EditFeeds extends StatefulWidget {
  const EditFeeds({Key? key}) : super(key: key);

  @override
  State<EditFeeds> createState() => _EditFeedsState();
}

class _EditFeedsState extends State<EditFeeds> {
  bool isLoading = false;
  late List<Sito> list = [];
  late List<Sito> listUpdated = [];

  String itemLoading = '';

  @override
  void initState() {
    loadData();
    super.initState();
  }

  showDeleteAlertDialog(BuildContext context, String url) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        deleteSite(url);
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: const Text("Confirm delete?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> saveSites(List<Sito> tList) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('feed_subscriptions', jsonEncode(tList));
  }

  void deleteSite(String url) async {
    if (url == "*") {
      listUpdated = [];
    } else {
      listUpdated.removeWhere((e) => (e.link == url));
    }
    saveSites(listUpdated);
    listUpdated = await readSites();
    setState(() {
      list = listUpdated;
    });
  }

  Future<bool> isUrlRSS(String url) async {
    try {
      final response =
          await get(Uri.parse(url)).timeout(const Duration(milliseconds: 2000));
      var channel = RssFeed.parse(response.body);
      if (channel.items!.isNotEmpty) {
        return true;
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<String> getRssFromUrl(String url) async {
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
        String hostname = url;
        if (hostname.replaceAll("//", "/").contains("/")) {
          hostname = Uri.parse(url.toString()).host.toString();
        }
        String urlRss =
            "http://feeds.feedburner.com/${hostname.replaceAll(".com", "").replaceAll(".it", "").replaceAll(".net", "").replaceAll(".org", "")}";
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

  Future<String> getUrlFormatted(String url) async {
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
      url = await getRssFromUrl(url);
      return url;
    } catch (err) {
      // print('Caught error: $err');
    }
    return "";
  }

  Future<bool> addSite(String url) async {
    try {
      String hostname = url;
      if (hostname.replaceAll("//", "/").contains("/")) {
        hostname = Uri.parse(url.toString()).host.toString();
      }
      setState(() {
        itemLoading = hostname;
      });
      url = await getUrlFormatted(url);
      if (url.length > 1) {
        listUpdated.removeWhere((e) => (e.link == url));
        var s1 = Sito(
          name: hostname,
          link: url,
          iconUrl: await SitesIcon().getIcon(hostname),
        );
        listUpdated.add(s1);
        saveSites(listUpdated);
        setState(() {
          list = listUpdated;
        });
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    return true;
  }

  Future<List<Sito>> readSites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('feed_subscriptions') ?? '[]');
      late List<Sito> listLocal =
          List<Sito>.from(jsonData.map((model) => Sito.fromJson(model)));

      return listLocal;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      list = [];
      listUpdated = await readSites();
    } catch (err) {
      //print('Caught error: $err');
    }
    setState(() {
      list = listUpdated;
      isLoading = false;
    });
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

  void _awaitReturnValueFromSecondScreen(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddFeed(),
        ));

    // after the SecondScreen result comes back update the Text widget with it

    setState(() {
      isLoading = true;
    });

    if (result != null) {
      if (result.toString().contains("<") ||
          result.toString().contains(";") ||
          result.toString().contains(" ")) {
        List<String> listUrl = getUrlsFromText(result);
        if (listUrl.length > 1) {
          for (String item in listUrl) {
            await addSite(item);
          }
          return;
        }
      }
      await addSite(result.toString().trim().replaceAll("\n", ""));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Feeds (${list.length})'),
        backgroundColor: Colors.blueGrey,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add feed',
              onPressed: () => _awaitReturnValueFromSecondScreen(context)),
          IconButton(
            icon: const Icon(Icons.model_training_outlined),
            tooltip: 'Default',
            onPressed: () => {
              addSite("https://hano.it/feed"),
              addSite("https://www.open.online/rss"),
              addSite("https://myvalley.it/feed"),
              addSite("https://www.ansa.it/sito/ansait_rss.xml"),
              addSite(
                  "https://news.google.com/rss/search?q=ecodibergamo&hl=it&gl=IT&ceid=IT%3Ait"),
              addSite("http://feeds.feedburner.com/hd-blog"),
              addSite("https://www.ilpost.it/rss"),
              addSite("https://medium.com/feed/tag/programming")
            },
          ),
          IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: () => showDeleteAlertDialog(context, "*")),
        ],
      ),
      body: Stack(
        children: [
          isLoading == false
              ? Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Scrollbar(
                      child: ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, index) {
                            final item = list[index];
                            return InkWell(
                              /*onTap: () async {
                                _launchInBrowser(
                                    Uri.parse((item.link.toString())));
                              },*/
                              child: ListTile(
                                  minLeadingWidth: 30,
                                  leading: SizedBox(
                                    height: double.infinity,
                                    width: 17,
                                    child: item.iconUrl.toString().trim() == ""
                                        ? const Icon(Icons.link)
                                        : CachedNetworkImage(
                                            imageUrl: item.iconUrl,
                                            placeholder: (context, url) =>
                                                const Icon(Icons.link),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.link),
                                          ),
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Text(
                                      (item.name.toString()),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            Color.fromARGB(255, 120, 120, 120),
                                      ),
                                    ),
                                  ),
                                  isThreeLine: false,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Default',
                                    onPressed: () => showDeleteAlertDialog(
                                        context, item.link),
                                  ),
                                  subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(
                                            child: Text(
                                              item.link.toString(),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                                color: Color.fromARGB(
                                                    255, 10, 10, 10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))),
                            );
                          })),
                )
              : Center(
                  child: SizedBox(
                    height: 175,
                    width: 275,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text('Loading'),
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        Text(itemLoading),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
