import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:rss_aggregator_flutter/screens/edit_feeds.dart';
import 'package:rss_aggregator_flutter/utilities/sites_icon.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  runApp(const MyApp());
}

class Elemento {
  var link = "";
  var title = "";
  DateTime? pubDate;
  //Image? icon;
  var iconUrl = "";
  var host = "";
  Elemento(
      {required this.link,
      required this.title,
      required this.pubDate,
      required this.iconUrl,
      required this.host});
}

DateTime tryParse(String formattedString) {
  try {
    return DateTime.parse(formattedString).toLocal();
  } on FormatException {
    return DateTime.parse(DateTime.now().toLocal().toString());
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
  late List<Elemento> list = [];
  late List<Elemento> listUpdated = [];

  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  @override
  void initState() {
    loadPackageInfo();
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

  String itemLoading = '';

  loadPackageInfo() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  loadDataUrl(String url) async {
    try {
      if (url.trim().toLowerCase().contains("http")) {
        String hostname = Uri.parse(url.toString()).host.toString();
        setState(() {
          itemLoading = hostname;
        });

        final response = await get(Uri.parse(url))
            .timeout(const Duration(milliseconds: 2000));
        var channel = RssFeed.parse(response.body);

        String iconUrl = await SitesIcon()
            .getIcon(hostname)
            .timeout(const Duration(milliseconds: 2000));

        int maxItem = 20;
        int nItem = 0;
        channel.items?.forEach((element) {
          if (element.title?.isEmpty == false) {
            if (element.title.toString().length > 5) {
              if (nItem <= maxItem) {
                nItem++;
                var p1 = Elemento(
                    title: element.title.toString(),
                    link: element.link.toString(),
                    iconUrl: iconUrl,
                    pubDate: element.pubDate,
                    host: hostname);
                listUpdated.add(p1);
              }
            }
          }
        });
      }
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  Future<List<Sito>> leggiListaFeed() async {
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

      listUpdated = [];

      List<Sito> listaSiti = await leggiListaFeed();
      for (var i = 0; i < listaSiti.length; i++) {
        String link = listaSiti[i].link;
        try {
          await loadDataUrl(link);
        } catch (err) {
          // print('Caught error: $err');
        }
        continue;

        if (i + 3 <= listaSiti.length) {
          // ignore: unused_local_variable
          List responses = await Future.wait([
            loadDataUrl(listaSiti[i].link),
            loadDataUrl(listaSiti[i + 1].link),
            loadDataUrl(listaSiti[i + 2].link),
            loadDataUrl(listaSiti[i + 3].link)
          ]);
        } else {
          String link = listaSiti[i].link;
          await loadDataUrl(link);
        }
      }
/*
      for (var sito in listaSiti) {
        try {
          await loadDataUrl(sito.link);
        } on Exception catch (_) {}
      }*/
/*
//esegue tutte le richieste in parallelo
      List responses = await Future.wait([
        loadDataUrl("https://hano.it/feed"),
        loadDataUrl("https://www.open.online/rss"),
        loadDataUrl("https://myvalley.it/feed"),
        loadDataUrl("https://www.ansa.it/sito/ansait_rss.xml"),
        loadDataUrl(
            "https://news.google.com/rss/search?q=ecodibergamo&hl=it&gl=IT&ceid=IT%3Ait"),
        loadDataUrl("http://feeds.feedburner.com/hd-blog"),
        loadDataUrl("https://www.ilpost.it/rss"),
        loadDataUrl("https://medium.com/feed/tag/programming")
      ]);
*/

      //await loadDataUrl("https://medium.com/feed/tag/programming");

      listUpdated.sort((a, b) => b.pubDate!.compareTo(a.pubDate!));

      setState(() {
        list = listUpdated;
        isLoading = false;
      });
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Feed list',
    ),
    Text(
      'Read later',
    ),
    Text(
      'Starred items',
    ),
    Text(
      'Discover new websites',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  _showAlertDialog(BuildContext context) async {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(appName),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(packageName),
          const SizedBox(height: 15),
          Text("Version: $version $buildNumber"),
          const SizedBox(height: 15),
          const Text("Developer: Andrea"),
          const SizedBox(height: 15),
          const Text("2022"),
        ],
      ),
      actions: [
        okButton,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: const Icon(Icons.newspaper),
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
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text("Aggregator RSS"),
              accountEmail: Text("News Feed Reader"),
              currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white, child: Icon(Icons.rss_feed)),
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text("Read Feeds"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.new_label),
              title: const Text("Edit Feed"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const EditFeeds()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("Info"),
              onTap: () {
                Navigator.pop(context);
                _showAlertDialog(context);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10.0),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'News Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.watch_later_outlined),
              label: 'Read Later',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Starred',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.travel_explore_rounded),
              label: 'Discover',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueGrey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      /*body:  Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),*/

      body: _selectedIndex != 0
          ? Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            )
          : Stack(
              children: [
                isLoading == false
                    ? Padding(
                        padding: const EdgeInsets.only(top: 5),
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
                                    onTap: () async {
                                      _launchInBrowser(
                                          Uri.parse((item.link.toString())));
                                    },
                                    child: ListTile(
                                        minLeadingWidth: 30,
                                        /*leading: const Icon(Icons.link),*/
                                        leading: /*Image(image: item.icon!.image),*/
                                            /*image: item.icon!.image,*/

                                            SizedBox(
                                          height: double.infinity,
                                          width: 17,
                                          child: item.iconUrl
                                                      .toString()
                                                      .trim() ==
                                                  ""
                                              ? const Icon(Icons.link)
                                              : CachedNetworkImage(
                                                  imageUrl: item.iconUrl,
                                                  placeholder: (context, url) =>
                                                      const Icon(Icons.link),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.link),
                                                ),
                                        ),
                                        title: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0),
                                          child: Text(
                                            (item.host.toString()),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: Color.fromARGB(
                                                  255, 120, 120, 120),
                                            ),
                                          ),
                                        ),
                                        isThreeLine: true,
                                        subtitle: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                SizedBox(
                                                  child: Text(
                                                    item.title.toString(),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Color.fromARGB(
                                                          255, 10, 10, 10),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        (DateFormat(
                                                                'dd/MM/yyyy HH:mm')
                                                            .format(tryParse(item
                                                                    .pubDate
                                                                    .toString())
                                                                .toLocal())),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Color.fromARGB(
                                                              255,
                                                              120,
                                                              120,
                                                              120),
                                                        ),
                                                      ),
                                                    ],
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
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('Loading'),
                                const SizedBox(height: 15),
                                const CircularProgressIndicator(),
                                const SizedBox(height: 15),
                                Text(itemLoading),
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
    );
  }
}
