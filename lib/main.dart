import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}
/*
class Lista {
  var link;
  var title;
  var pubDate;
  var icon;
  var host;
  Lista({link, title, pubDate, icon, host});
}*/

class x extends RssItem {
  /*x({link, title, pubDate, icon, host}) {
    link = super.link;
    title = this.title;
    pubDate = this.pubDate;
  }*/

  var host = '';

  x({super.link, super.title, super.pubDate, required this.host});
}

DateTime tryParse(String formattedString) {
  try {
    return DateTime.parse(formattedString);
  } on FormatException {
    return DateTime.parse(DateTime.now().toString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  late RssFeed rss = RssFeed();

  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      /* RssItemX ax = new RssItemX(
          title: "titolo",
          link: "link",
          pubDate: DateTime.parse('2020-01-02 03:04:05'),
          icon: "",
          host: "www.google.it");*/

      var p1 = x(
          title: "titolo",
          link: "https://www.open.online/rss",
          pubDate: DateTime.parse('2020-01-02 03:04:05'),
          host: "https://www.open.online/rss");

      rss.items?.add(p1);

      const api = 'https://www.open.online/rss';
      final response = await get(Uri.parse(api));
      var channel = RssFeed.parse(response.body);

      channel.items?.add(p1);

      setState(() {
        rss = channel;
        isLoading = false;
      });
    } catch (err) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.newspaper),
        title: const Text('Rss Feed Aggregator'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => loadData(),
          ), //IconButton
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Setting',
            onPressed: () {},
          ), //IconButton
        ], //<Widg
      ),
      body: Stack(
        children: [
          isLoading == false
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Scrollbar(
                      child: ListView.separated(
                          itemCount: rss.items!.length,
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, index) {
                            final item = rss.items![index];

                            return InkWell(
                              onTap: () async {
                                _launchInBrowser(
                                    Uri.parse((item.link.toString())));
                              },
                              child: ListTile(
                                  leading: const Icon(Icons.rss_feed),
                                  title: Padding(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Text(
                                      (Uri.parse(item.link.toString())
                                          .host
                                          .toString()),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Color.fromARGB(255, 90, 90, 90),
                                      ),
                                    ),
                                  ),
                                  isThreeLine: true,
                                  subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(
                                            child: Text(
                                              item.title.toString(),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                                color: Color.fromARGB(
                                                    255, 20, 20, 20),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Row(
                                              children: [
                                                Text(DateFormat(
                                                        'dd/MM/yyyy hh:mm')
                                                    .format(tryParse(item
                                                        .pubDate
                                                        .toString()))),
                                              ],
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
