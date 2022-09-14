import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rss_aggregator_flutter/utilities/sites_icon.dart';
import 'add_feed.dart';

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

  void addSite(String url) async {
    try {
      if (url.isEmpty == false &&
          url.length > 7 &&
          url.contains(".") &&
          !url.trim().startsWith("%")) {
        listUpdated.removeWhere((e) => (e.link == url));
        String hostname = url;
        if (hostname.replaceAll("//", "/").contains("/")) {
          hostname = Uri.parse(url.toString()).host.toString();
        }
        var s1 = Sito(
          name: hostname,
          link: url,
          iconUrl: await SitesIcon().getIcon(hostname),
        );
        listUpdated.add(s1);
        saveSites(listUpdated);
        //listUpdated = await leggiNew();
        setState(() {
          list = listUpdated;
        });
      }
    } catch (err) {
      // print('Caught error: $err');
    }
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
      setState(() {
        list = listUpdated;
        isLoading = false;
      });
    } catch (err) {
      //print('Caught error: $err');
    }
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

    if (result != null) {
      if (result.toString().contains("<") ||
          result.toString().contains(";") ||
          result.toString().contains(" ")) {
        List<String> listUrl = getUrlsFromText(result);
        if (listUrl.length > 1) {
          for (String item in listUrl) {
            addSite(item);
          }
          return;
        }
      }
      addSite(result);
    }
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
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ],
      ),
    );
  }
}
