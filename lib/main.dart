import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:rss_aggregator_flutter/screens/edit_sites.dart';
//import 'package:rss_aggregator_flutter/utilities/sites_icon.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';

void main() {
  runApp(const MyApp());
}

class Elemento {
  var link = "";
  var title = "";
  DateTime? pubDate;
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
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day).toLocal();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aggregator RSS',
      theme: ThemeData(primarySwatch: ThemeColor.primaryColor),
      home: const MyHomePage(title: 'News Feed Aggregator'),
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

  loadDataUrl(Site site) async {
    try {
      if (site.siteLink.trim().toLowerCase().contains("http")) {
        String hostname =
            site.siteName; //Uri.parse(site.link.toString()).host.toString();
        setState(() {
          itemLoading = hostname;
        });
        final response = await get(Uri.parse(site.siteLink))
            .timeout(const Duration(milliseconds: 4000));
        RssFeed channel = RssFeed();
        try {
          channel = RssFeed.parse(utf8.decode(
              response.bodyBytes)); //risolve accenti sbagliati esempio agi
        } catch (err) {
          //nel caso di ilmattino crasha in utf8, quindi ritenta senza utf8
          try {
            channel = RssFeed.parse(response.body);
          } catch (err) {
            // print('Caught error: $err');
          }
        }

        //var channel = RssFeed.parse(response.body);

        /*String iconUrl = "";
        try {
          iconUrl = await SitesIcon()
              .getIcon(hostname)
              .timeout(const Duration(milliseconds: 2000));
        } catch (err) {
          // senza questo try/catch salta il pezzo sotto, quindi senza icone non caricherebbe
        }*/

        String? iconUrl = site.iconUrl.trim() != ""
            ? site.iconUrl
            : channel.image?.url?.toString();

        int maxItem = 20;
        int nItem = 0;
        channel.items?.forEach((element) {
          if (element.title?.isEmpty == false) {
            if (element.title.toString().length > 5) {
              if (nItem <= maxItem) {
                nItem++;
                var p1 = Elemento(
                    title: element.title == null ||
                            element.title.toString().trim() == ""
                        ? element.description
                            .toString()
                            .replaceAll("�", " ")
                            .replaceAll("&#039;", " ")
                            .replaceAll("&quot;", " ")
                        : element.title
                            .toString()
                            .trim()
                            .toString()
                            .replaceAll("�", " ")
                            .replaceAll("&#039;", " ")
                            .replaceAll("&quot;", " "),
                    link: element.link == null ||
                            element.link.toString().trim() == ""
                        ? element.guid.toString().trim()
                        : element.link.toString().trim(),
                    iconUrl: iconUrl.toString(),
                    pubDate: tryParse(element.pubDate.toString()),
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

  Future<List<Site>> leggiListaFeed() async {
    final prefs = await SharedPreferences.getInstance();
    final List<dynamic> jsonData =
        await jsonDecode(prefs.getString('db_site') ?? '[]');
    return List<Site>.from(jsonData.map((model) => Site.fromJson(model)));
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      list = [];
      listUpdated = [];

      List<Site> listaSiti = await leggiListaFeed();
      for (var i = 0; i < listaSiti.length; i++) {
        try {
          await loadDataUrl(listaSiti[i]);
        } catch (err) {
          // print('Caught error: $err');
        }
        continue;
      }

      //remove feed older than 3 months
      listUpdated
          .removeWhere((e) => (daysBetween(e.pubDate!, DateTime.now()) > 90));

//sort
      listUpdated.sort((a, b) => b.pubDate!.compareTo(a.pubDate!));

      setState(() {
        list = listUpdated;
        isLoading = false;
      });
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
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
        title: const Text('Aggregator'),
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
                    MaterialPageRoute(builder: (context) => const EditSites()));
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
                                separatorBuilder: (context, index) {
                                  return const Divider();
                                },
                                itemBuilder: (BuildContext context, index) {
                                  final item = list[index];
                                  return InkWell(
                                    onTap: () async {
                                      _launchInBrowser(
                                          Uri.parse((item.link.toString())));
                                    },
                                    child: ListTile(
                                        minLeadingWidth: 30,
                                        leading: SizedBox(
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
