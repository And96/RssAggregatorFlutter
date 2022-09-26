import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:flutter/scheduler.dart'; //
import 'package:http/http.dart';
import 'package:rss_aggregator_flutter/screens/edit_sites.dart';
import 'package:rss_aggregator_flutter/screens/settings_page.dart';
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
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
import 'dart:async';
import 'package:flutter_phoenix/flutter_phoenix.dart';

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

          /*floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: const Color.fromARGB(255, 10, 10, 10),
          ),*/
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
  late List<Elemento> list = [];
  late List<Elemento> listUpdated = [];
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  static bool darkMode = false;

  double opacity = 1.0;

  @override
  initState() {
    loadPackageInfo();
    loadData();
    changeOpacity();
    ThemeColor.isDarkMode()
        .then((value) => {darkMode = value, super.initState()});
  }

  changeOpacity() {
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        opacity = opacity <= 0.5 ? 1.0 : 0.5;
        changeOpacity();
      });
    });
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
                            .trim()
                            .toString()
                            .replaceAll("�", " ")
                            .replaceAll("&#039;", " ")
                            .replaceAll("&quot;", " ")
                            .replaceAll("&#8217;", "'")
                            .replaceAll(RegExp('&#[0-9]{1,5};'), " ")
                            .replaceAll("  ", " ")
                        : element.title
                            .toString()
                            .trim()
                            .toString()
                            .replaceAll("�", " ")
                            .replaceAll("&#039;", " ")
                            .replaceAll("&quot;", " ")
                            .replaceAll("&#8217;", "'")
                            .replaceAll(RegExp('&#[0-9]{1,5};'), " ")
                            .replaceAll("  ", " "),
                    link: element.link == null ||
                            element.link.toString().trim() == ""
                        ? element.guid.toString().trim()
                        : element.link.toString().trim(),
                    iconUrl: iconUrl.toString(),
                    description: element.description == null ||
                            element.description.toString().trim() == ""
                        ? " "
                        : element.description
                            .toString()
                            .trim()
                            .toString()
                            .replaceAll("�", " ")
                            .replaceAll("&#039;", " ")
                            .replaceAll("&quot;", " ")
                            .replaceAll("&#8217;", "'")
                            .replaceAll(RegExp('&#[0-9]{1,5};'), " ")
                            .replaceAll("  ", " "),
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
      if (isLoading) {
        return;
      }

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

  TextStyle header = const TextStyle(
      color: Color.fromARGB(100, 100, 100, 100),
      fontSize: 20,
      fontWeight: FontWeight.bold);

  int _selectedIndex = 0;

  void _showBottomSheet(BuildContext context, Elemento item) {
    showModalBottomSheet(
        /* shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),*/
        isScrollControlled: true,
        context: context,
        builder: (context) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 2, 2, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SizedBox(
                            height: 25,
                            width: 25,
                            child: item.iconUrl.toString().trim() == ""
                                ? const Icon(Icons.link)
                                : CachedNetworkImage(
                                    imageUrl: item.iconUrl,
                                    placeholder: (context, url) =>
                                        const Icon(Icons.link),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.link),
                                  ),
                          ),
                          Text(
                            item.host,
                            style: Theme.of(context).textTheme.titleLarge,
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
                    ),
                    Row(children: const <Widget>[
                      Expanded(child: Divider()),
                    ]),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm')
                          .format(tryParse(item.pubDate.toString()).toLocal()),
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    Row(children: const <Widget>[
                      Expanded(child: Divider()),
                    ]),
                    Text(
                      item.link,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    Row(children: const <Widget>[
                      Expanded(child: Divider()),
                    ]),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FloatingActionButton.extended(
                            icon: const Icon(Icons.open_in_full),
                            label: const Text('Read Website'),
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 0,
                                ),
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () => _launchInBrowser(
                                Uri.parse((item.link.toString()))),
                          ),
                          FloatingActionButton.extended(
                            icon: const Icon(Icons.watch_later),
                            label: const Text(''),
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 0,
                                ),
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () {},
                          ),
                          FloatingActionButton.extended(
                            icon: const Icon(Icons.star),
                            label: const Text(''),
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 0,
                                ),
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
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

    // show the dialog
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //leading: const Icon(Icons.newspaper),
          title: const Text('Aggregator'),
          actions: <Widget>[
            !isLoading
                ? IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: () => loadData(),
                  )
                : IconButton(
                    icon: AnimatedBuilder(
                      animation: _refreshIconController,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _refreshIconController.value * 4 * 3.1415,
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const EditSites()));
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
                    ? list.isEmpty
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
                                    itemCount: list.length,
                                    separatorBuilder: (context, index) {
                                      return const Divider();
                                    },
                                    itemBuilder: (BuildContext context, index) {
                                      final item = list[index];
                                      return InkWell(
                                        /*onTap: () async {
                                                  _launchInBrowser(Uri.parse(
                                                      (item.link.toString())));
                                                },*/
                                        onTap: () => _showBottomSheet(
                                            context, list[index]),
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
                                                  const EdgeInsets.only(top: 0),
                                              child: Text(
                                                (item.host.toString()),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  color: darkMode
                                                      ? const Color.fromARGB(
                                                          255, 150, 150, 150)
                                                      : const Color.fromARGB(
                                                          255, 120, 120, 120),
                                                ),
                                              ),
                                            ),
                                            isThreeLine: true,
                                            subtitle: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    SizedBox(
                                                      child: Text(
                                                        item.title.toString(),
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: darkMode
                                                              ? const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  210,
                                                                  210,
                                                                  210)
                                                              : const Color
                                                                      .fromARGB(
                                                                  255, 5, 5, 5),
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
                                                            style: TextStyle(
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
                                      );
                                    })),
                          )
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AnimatedOpacity(
                              opacity: isLoading ? opacity : 1.0,
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

class Elemento {
  var link = "";
  var title = "";
  var description = "";
  DateTime? pubDate;
  var iconUrl = "";
  var host = "";
  Elemento(
      {required this.link,
      required this.title,
      required this.pubDate,
      required this.iconUrl,
      required this.host,
      required this.description});
}

DateTime tryParse(String formattedString) {
  try {
    return DateTime.parse(formattedString).toLocal();
  } on FormatException {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day).toLocal();
  }
}
