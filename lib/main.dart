import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:flutter/scheduler.dart'; //
import 'package:http/http.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/screens/sites_page.dart';
import 'package:rss_aggregator_flutter/screens/settings_page.dart';
//import 'package:rss_aggregator_flutter/utilities/sites_icon.dart';
import 'package:webfeed/webfeed.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
import 'dart:async';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:share_plus/share_plus.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter/services.dart';
//import 'package:rss_aggregator_flutter/theme/theme_color.dart';

// ignore: depend_on_referenced_packages
import 'package:pref/pref.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final service = await PrefServiceShared.init(
    defaults: {
      'settings_ui_theme': 'light',
      'settings_ui_color': ThemeColor.primaryColorLight,
      'settings_timeout': 4,
      'settings_days_limit': 90,
      'settings_feeds_limit': 20,
      'settings_load_images': true,
    },
  );

  runApp(
    Phoenix(
      child: MyApp(service),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp(this.service, {Key? key}) : super(key: key);

  final BasePrefService service;

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Color? _uiColor = ThemeColor.primaryColorLight;
  ThemeMode? _brightness;
  StreamSubscription<String>? _stream;
  StreamSubscription<int?>? _streamColor;

  @override
  void dispose() {
    _stream?.cancel();
    _streamColor?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _stream ??=
        widget.service.stream<String>('settings_ui_theme').listen((event) {
      setState(() {
        switch (event) {
          case 'system':
            _brightness = ThemeMode.system;
            break;
          case 'light':
            _brightness = ThemeMode.light;
            break;
          case 'dark':
            _brightness = ThemeMode.dark;
            break;
        }
      });
    });

    _streamColor ??=
        widget.service.stream<int?>('settings_ui_color').listen((event) {
      setState(() {
        _uiColor = event == null ? null : Color(event);
      });
    });

    return PrefService(
      service: widget.service,
      child: MaterialApp(
        title: 'Aggregator',
        themeMode: _brightness,
        theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _uiColor!,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: _uiColor!, brightness: Brightness.dark),
          brightness: Brightness.dark,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late List<FeedItem> listFeed = [];
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  static bool darkMode = false;

  double opacityAnimation = 1.0;

  int settingsFeedsLimit = 20;
  int settingsDaysLimit = 90;
  bool settingsLoadImages = true;
  int settingsTimeout = 4;

  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    _refreshIconController.dispose();
    super.dispose();
  }

  @override
  initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadPackageInfo();
      await loadSettings();
      await setOpacityAnimation();
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
      await loadData();
      super.initState();
    });
  }

  Future<bool> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    settingsFeedsLimit = (prefs.getInt('settings_feeds_limit'))!;
    settingsDaysLimit = (prefs.getInt('settings_days_limit'))!;
    settingsLoadImages = (prefs.getBool('settings_load_images'))!;
    settingsTimeout = (prefs.getInt('settings_timeout'))!;
    return true;
  }

  setOpacityAnimation() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          opacityAnimation = opacityAnimation <= 0.5 ? 1.0 : 0.5;
          setOpacityAnimation();
        });
      }
    });
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
        String hostname = site.siteName;
        setState(() {
          itemLoading = hostname;
        });
        final response = await get(Uri.parse(site.siteLink))
            .timeout(Duration(seconds: settingsTimeout));
        RssFeed channel = RssFeed();
        try {
          channel = RssFeed.parse(utf8.decode(
              response.bodyBytes)); //risolve accenti sbagliati esempio agi
        } catch (err) {
          //crash in utf8 with some site e.g. ilmattino, so try again without it and it works
          try {
            channel = RssFeed.parse(response.body);
          } catch (err) {
            // print('Caught error: $err');
          }
        }

        String? iconUrl = site.iconUrl.trim() != ""
            ? site.iconUrl
            : channel.image?.url?.toString();

        int nItem = 0;
        channel.items?.forEach((element) {
          if (element.title?.isEmpty == false) {
            if (element.title.toString().length > 5) {
              if (nItem < settingsFeedsLimit || settingsFeedsLimit == 0) {
                nItem++;
                var p1 = FeedItem(
                    title: element.title == null ||
                            element.title.toString().trim() == ""
                        ? Utility().cleanText(element.description)
                        : Utility().cleanText(element.title),
                    link: element.link == null ||
                            element.link.toString().trim() == ""
                        ? element.guid.toString().trim()
                        : element.link.toString().trim(),
                    iconUrl: iconUrl.toString(),
                    description: element.content != null &&
                            element.content!.value.toString().trim().length > 10
                        ? Utility().cleanText(element.content!.value)
                        : Utility().cleanText(element.description),
                    pubDate: Utility().tryParse(element.pubDate.toString()),
                    host: hostname);
                listFeed.add(p1);
              }
            }
          }
        });
      }
    } catch (err) {
      //print('Caught error: $err');
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
      if (isLoading) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      listFeed = [];

      List<Site> listaSiti = await leggiListaFeed();
      for (var i = 0; i < listaSiti.length; i++) {
        try {
          await loadDataUrl(listaSiti[i]);
        } catch (err) {
          // print('Caught error: $err');
        }
        continue;
      }

      //remove feed older than N days
      listFeed.removeWhere((e) =>
          (Utility().daysBetween(e.pubDate!, DateTime.now()) >
              settingsDaysLimit));

      //sort
      listFeed.sort((a, b) => b.pubDate!.compareTo(a.pubDate!));

      setState(() {
        listFeed = listFeed;
        isLoading = false;
      });
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  int _selectedIndex = 0;

  void showOptionDialog(BuildContext context, FeedItem item) {
    var dialog = SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            height: 17,
            width: 17,
            child: item.iconUrl.toString().trim() == ""
                ? const Icon(Icons.link)
                : CachedNetworkImage(
                    imageUrl: item.iconUrl,
                    placeholder: (context, url) => const Icon(Icons.link),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.link),
                  ),
          ),
          Text(
            item.host,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      contentPadding: const EdgeInsets.all(8),
      children: <Widget>[
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Text(
            item.link,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.left,
            maxLines: 2,
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.open_in_new),
          title: const Text('Open site'),
          onTap: () async {
            Utility().launchInBrowser(Uri.parse(item.link));
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.watch_later_outlined),
          title: const Text('Read later'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.star_border),
          title: const Text('Add to starred'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.copy),
          title: const Text('Copy link'),
          onTap: () {
            Clipboard.setData(ClipboardData(text: item.link));
            Navigator.pop(context);
            const snackBar = SnackBar(
              duration: Duration(milliseconds: 500),
              content: Text('Link copied to clipboard'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share link'),
          onTap: () {
            Share.share(item.link);
            Navigator.pop(context);
          },
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  _showAlertDialog(BuildContext context) async {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(appName),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(packageName),
          const SizedBox(height: 15),
          Text("Version: $buildNumber"),
          const SizedBox(height: 15),
          Text("Build Number: $buildNumber"),
          const SizedBox(height: 15),
          const Text("Developer: Andrea"),
          const SizedBox(height: 15),
        ],
      ),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  late final AnimationController _refreshIconController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  void pageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(index,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  bool onSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: !onSearch || isLoading || listFeed.isEmpty
            ? AppBar(
                title: const Text("Aggregator"),
                actions: <Widget>[
                  if (!isLoading)
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () {
                        sleep(const Duration(milliseconds: 200));
                        setState(() {
                          onSearch = onSearch ? false : true;
                          searchController.text = '';
                        });
                      },
                    ), //
                  !isLoading
                      ? IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh',
                          onPressed: () => {
                            sleep(const Duration(milliseconds: 200)),
                            loadData()
                          },
                        )
                      : IconButton(
                          icon: AnimatedBuilder(
                            animation: _refreshIconController,
                            builder: (_, child) {
                              return Transform.rotate(
                                angle:
                                    _refreshIconController.value * 4 * 3.1415,
                                child: child,
                              );
                            },
                            child: const Icon(Icons.refresh),
                          ),
                          onPressed: () => {},
                        ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'Setting',
                    onPressed: () {},
                  ),
                ],
              )
            : AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: () {
                    setState(() {
                      sleep(const Duration(milliseconds: 200));
                      onSearch = false;
                      searchController.text = '';
                    });
                  },
                ), //
                title: TextField(
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  controller: searchController,
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                    onPressed: () {
                      setState(() {
                        listFeed = listFeed;
                      });
                    },
                  ), //
                ],
              ),
        drawer: onSearch
            ? null
            : Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                          color: darkMode
                              ? Colors.black12
                              : Theme.of(context).colorScheme.primary),
                      accountName: const Text("Aggregator RSS"),
                      accountEmail: const Text("News Feed Reader"),
                      currentAccountPicture: const CircleAvatar(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        child: Icon(Icons.rss_feed),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.newspaper),
                      title: const Text("Read News"),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.toc_outlined),
                      title: const Text("Manage Sites"),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SitesPage()));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.label),
                      title: const Text("Categories"),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text("Settings"),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => const SettingsPage()))
                            .then((value) => Phoenix.rebirth(context));
                      },
                    ),
                    const Divider(),
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
            selectedItemColor: darkMode
                ? const Color.fromARGB(255, 220, 220, 220)
                : Theme.of(context).colorScheme.primary,
            onTap: bottomTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        body: PageView(
          controller: pageController,
          onPageChanged: (index) {
            pageChanged(index);
          },
          children: <Widget>[
            Stack(
              children: [
                isLoading == false
                    ? listFeed.isEmpty
                        ? Center(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              EmptySection(
                                title: 'Nessuna notizia presente',
                                description: 'Aggiungi i tuoi siti da seguire',
                                icon: Icons.new_label,
                                darkMode: darkMode,
                              ),
                            ],
                          ))
                        : Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Scrollbar(
                                child: ListView.separated(
                                    itemCount: listFeed.length,
                                    separatorBuilder: (context, index) {
                                      return Visibility(
                                          visible: !onSearch ||
                                              listFeed[index]
                                                  .title
                                                  .toLowerCase()
                                                  .contains(searchController
                                                      .text
                                                      .toString()
                                                      .toLowerCase()) ||
                                              listFeed[index]
                                                  .link
                                                  .toLowerCase()
                                                  .contains(searchController
                                                      .text
                                                      .toString()
                                                      .toLowerCase()) ||
                                              listFeed[index]
                                                  .host
                                                  .toLowerCase()
                                                  .contains(searchController
                                                      .text
                                                      .toString()
                                                      .toLowerCase()),
                                          child: const Divider());
                                    },
                                    itemBuilder: (BuildContext context, index) {
                                      final item = listFeed[index];

                                      return Visibility(
                                          visible: !onSearch ||
                                              listFeed[index]
                                                  .title
                                                  .toLowerCase()
                                                  .contains(searchController
                                                      .text
                                                      .toString()
                                                      .toLowerCase()) ||
                                              listFeed[index]
                                                  .link
                                                  .toLowerCase()
                                                  .contains(searchController
                                                      .text
                                                      .toString()
                                                      .toLowerCase()) ||
                                              listFeed[index]
                                                  .host
                                                  .toLowerCase()
                                                  .contains(searchController
                                                      .text
                                                      .toString()
                                                      .toLowerCase()),
                                          child: InkWell(
                                            onTap: () => showOptionDialog(
                                                context, listFeed[index]),
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
                                                          imageUrl:
                                                              item.iconUrl,
                                                          placeholder: (context,
                                                                  url) =>
                                                              const Icon(
                                                                  Icons.link),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                                  Icons.link),
                                                        ),
                                                ),
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 0),
                                                  child: Text(
                                                    (item.host.toString()),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: darkMode
                                                          ? const Color
                                                                  .fromARGB(255,
                                                              150, 150, 150)
                                                          : const Color
                                                                  .fromARGB(255,
                                                              120, 120, 120),
                                                    ),
                                                  ),
                                                ),
                                                isThreeLine: true,
                                                subtitle: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          child: Text(
                                                            item.title
                                                                .toString(),
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: darkMode
                                                                  ? const Color
                                                                          .fromARGB(
                                                                      255,
                                                                      210,
                                                                      210,
                                                                      210)
                                                                  : const Color
                                                                          .fromARGB(
                                                                      255,
                                                                      5,
                                                                      5,
                                                                      5),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                (DateFormat('dd/MM/yyyy HH:mm').format(Utility()
                                                                    .tryParse(item
                                                                        .pubDate
                                                                        .toString())
                                                                    .toLocal())),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  color: darkMode
                                                                      ? const Color
                                                                              .fromARGB(
                                                                          255,
                                                                          150,
                                                                          150,
                                                                          150)
                                                                      : const Color
                                                                              .fromARGB(
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
                                          ));
                                    })),
                          )
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AnimatedOpacity(
                              opacity: isLoading ? opacityAnimation : 1.0,
                              duration: const Duration(milliseconds: 500),
                              child: EmptySection(
                                title: 'Ricerca notizie in corso',
                                description: itemLoading,
                                icon: Icons.query_stats,
                                darkMode: darkMode,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
            Center(
              child: EmptySection(
                title: 'Non hai niente in sospeso',
                description:
                    'Ricontrolla periodicamente per verificare se ci sono prodotti e offerte speciali oppure per utilizzare un codice promozionale,',
                icon: Icons.watch_later,
                darkMode: darkMode,
              ),
            ),
            Center(
              child: EmptySection(
                title: 'Starred item',
                description:
                    'Ricontrolla periodicamente per verificare se ci sono prodotti e offerte speciali oppure per utilizzare un codice promozionale,',
                icon: Icons.star_rate,
                darkMode: darkMode,
              ),
            ),
            Center(
              child: EmptySection(
                title: 'Discover new websites',
                description:
                    'Ricontrolla periodicamente per verificare se ci sono prodotti e offerte speciali oppure per utilizzare un codice promozionale,',
                icon: Icons.safety_check_sharp,
                darkMode: darkMode,
              ),
            ),
          ],
        ));
  }
}

class FeedItem {
  var title = "";
  var description = "";
  var link = "";
  var host = "";
  DateTime? pubDate;
  var iconUrl = "";
  FeedItem(
      {required this.link,
      required this.title,
      required this.pubDate,
      required this.iconUrl,
      required this.host,
      required this.description});
}
