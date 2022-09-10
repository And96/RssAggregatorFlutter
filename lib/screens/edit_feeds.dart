import 'dart:convert';

import 'package:favicon/favicon.dart' hide Icon;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'add_feed.dart';

class Sito {
  var link = "";
  var iconUrl = "";
  Sito({
    required this.link,
    required this.iconUrl,
  });

  factory Sito.fromJson(Map<String, dynamic> json) {
    return Sito(
      link: json["link"],
      iconUrl: json["iconUrl"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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

  showAlertDialog(BuildContext context, String url) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        deleteItem(url);
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete link"),
      content: const Text("Do you confirm?"),
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

  Future<void> salva(List<Sito> tList) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('feed_subscriptions', jsonEncode(tList));
  }

  void deleteItem(String url) async {
    listUpdated.removeWhere((e) => (e.link == url));
    salva(listUpdated);
    listUpdated = await leggiNew();
    setState(() {
      list = listUpdated;
    });
  }

  void aggiungi(String url) async {
    if (url.isEmpty == false) {
      listUpdated.removeWhere((e) => (e.link == url));
      var s1 = Sito(
        link: url,
        iconUrl: "",
      );
      listUpdated.add(s1);
      salva(listUpdated);
      listUpdated = await leggiNew();
      setState(() {
        list = listUpdated;
      });
    }
  }

  Future<List<Sito>> leggiNew() async {
    final prefs = await SharedPreferences.getInstance();
    final List<dynamic> jsonData =
        await jsonDecode(prefs.getString('feed_subscriptions') ?? '[]');
    return List<Sito>.from(jsonData.map((model) => Sito.fromJson(model)));
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      list = [];

      /* if (list.isEmpty) {
        var s1 = Sito(
          link: "ss",
          iconUrl: "",
        );
        listUpdated.add(s1);

        var s2 = Sito(
          link: "ss",
          iconUrl: "",
        );
        listUpdated.add(s2);
      }*/

      //await salva(listUpdated);
      listUpdated = await leggiNew();
/*
      for (var element in listUpdated) {
        var s1 = Sito(
          link: element.link.toString(),
          iconUrl: "",
        );
        listUpdated.add(s1);
      }*/

      setState(() {
        list = listUpdated;
        isLoading = false;
      });
    } catch (err) {
      rethrow;
    }
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
      if (result != null) {
        aggiungi(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Feeds'),
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
              aggiungi("https://hano.it/feed"),
              aggiungi("https://www.open.online/rss"),
              aggiungi("https://myvalley.it/feed"),
              aggiungi("https://www.ansa.it/sito/ansait_rss.xml"),
              aggiungi(
                  "https://news.google.com/rss/search?q=ecodibergamo&hl=it&gl=IT&ceid=IT%3Ait"),
              aggiungi("http://feeds.feedburner.com/hd-blog"),
              aggiungi("https://www.ilpost.it/rss"),
              aggiungi("https://medium.com/feed/tag/programming")
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading == false
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Scrollbar(
                      child: ListView.separated(
                          itemCount: list.length,
                          /*itemCount: rss.items!.length,*/
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, index) {
                            /*final item = rss.items![index];*/
                            final item = list[index];
                            return InkWell(
                              /*onTap: () async {
                                _launchInBrowser(
                                    Uri.parse((item.link.toString())));
                              },*/
                              child: ListTile(
                                  minLeadingWidth: 30,
                                  /*leading: const Icon(Icons.link),*/
                                  leading: /*Image(image: item.icon!.image),*/
                                      /*image: item.icon!.image,*/

                                      SizedBox(
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
                                      (item.link.toString()),
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
                                    onPressed: () =>
                                        showAlertDialog(context, item.link),
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
                                              maxLines: 3,
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
