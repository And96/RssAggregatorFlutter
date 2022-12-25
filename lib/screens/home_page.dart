import 'dart:io';
//import 'dart:math';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:rss_aggregator_flutter/core/category.dart';
import 'package:rss_aggregator_flutter/core/favourites_list.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/readlater_list.dart';
import 'package:rss_aggregator_flutter/core/scroll_physics.dart';
import 'package:rss_aggregator_flutter/core/settings.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/screens/discover_page.dart';
import 'package:rss_aggregator_flutter/screens/favourites_page.dart';
import 'package:rss_aggregator_flutter/screens/readlater_page.dart';
//import 'package:rss_aggregator_flutter/screens/sites_page.dart';
import 'package:rss_aggregator_flutter/screens/settings_page.dart';
import 'package:rss_aggregator_flutter/screens/categories_page.dart';
// ignore: depend_on_referenced_packages
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rss_aggregator_flutter/screens/sites_page.dart';
import 'package:rss_aggregator_flutter/screens/welcome_page.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/loading_indicator.dart';
import 'package:rss_aggregator_flutter/widgets/news_section.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Settings settings = Settings();

  late FeedsList feedsListUpdate =
      FeedsList(updateItemLoading: _updateItemLoading);
  late List<FeedsList> feedsList = [];
  late CategoriesList categoriesList = CategoriesList();
  late SitesList sitesList =
      SitesList.withIndicator(updateItemLoading: (String value) {});
  void _updateItemLoading(String itemLoading) {
    setState(() {});
  }

  //Loading indicator
  bool isLoading = true;

  //Search indicator
  bool isOnSearch = false;

  //Theme
  static bool darkMode = false;

  //package info
  String appName = "";
  String appPackageName = "";
  String appVersion = "";
  String appBuildNumber = "";

  //Controller
  TextEditingController searchController = TextEditingController();

  //int _selectedIndex = 0;

  int nReadLaterItems = 0;
  int nFavouriteItems = 0;

  //Theme
  void pageRouterVerticalAnimation(StatefulWidget page) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        }));
  }

  /*void _onBottomItemTap(int index) {
    switch (index) {
      case 1:
        pageRouterVerticalAnimation(const ReadlaterPage());
        break;

      case 2:
        pageRouterVerticalAnimation(const FavouritesPage());
        break;
      case 3:
        pageRouterVerticalAnimation(DiscoverPage(feedsList: feedsList[0]));
        break;
    }
    //in homepage there is only newspage
    setState(() {
      _selectedIndex = 0;
    });
  }*/

  late final AnimationController _refreshIconController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _refreshIconController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Color colorCategory = ThemeColor.primaryColorLight;
  late TabController _tabController =
      TabController(length: categoriesList.tabs.length, vsync: this);

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load().then((value) =>
        value == true
            ? Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => const WelcomePage()))
                .then((value) => Phoenix.rebirth(context))
            : sitesList.items.isEmpty
                ? Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => const SitesPage()))
                    .then((value) => Phoenix.rebirth(context))
                : null));
  }

  Future<bool> load() async {
    bool firstRun = false;
    bool loadFromWeb = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await ThemeColor.isDarkMode().then((value) async => {
            darkMode = value,
            await loadPackageInfo(),
            await settings.init(),
            //read news layout
            viewMode = await settings.getNewsLayout(),
            await sitesList.load(),
            if (prefs.getBool('first_run_app') == null)
              {
                categoriesList.add("News"),
                await prefs.setBool('first_run_app', true),
                firstRun = true,
              },
            loadFromWeb = await feedsListUpdate.isUpdateFeedsRequired(),
            await categoriesList.load(true),
            await setCategoryColor(),
            setState(() {
              _tabController = TabController(
                  length: categoriesList.tabs.length, vsync: this);
            }),
            _tabController.addListener(() {
              setCategoryColor();
              setState(() {});
            }),
            isLoading = false,
            await loadData(loadFromWeb),
          });
    } catch (err) {
      //print('Caught error: $err');
    }
    return firstRun;
  }

  setCategoryColor() {
    try {
      colorCategory = Color(categoriesList.tabs[_tabController.index].color);
      /*SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: colorCategory,
      ));*/
      // Colors.primaries[Random().nextInt(Colors.primaries.length)];//random color
    } catch (err) {
      colorCategory = ThemeColor.primaryColorLight;
    }
  }

  loadPackageInfo() async {
    try {
      await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        appName = packageInfo.appName;
        appPackageName = packageInfo.packageName;
        appVersion = packageInfo.version;
        appBuildNumber = packageInfo.buildNumber;
      });
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<void> loadData(bool loadFromWeb) async {
    try {
      if (isLoading) {
        return;
      }
      isLoading = true;
      setState(() {});

      await feedsListUpdate.load(loadFromWeb, 0, "*");
      feedsList = [];
      for (Category c in categoriesList.tabs) {
        FeedsList f = FeedsList(updateItemLoading: null);
        await f.load(false, 0, c.name);
        feedsList.add(f);
      }
    } catch (err) {
      //print('Caught error: $err');
    }
    isLoading = false;
    setState(() {});
  }

  _showInfoDialog(BuildContext context) async {
    var dialog = SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Release information',
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
        ListTile(
          minLeadingWidth: 30,
          leading: const Icon(Icons.tag),
          title: const Text('Version'),
          subtitle: Text(
            'v.$appVersion build.$appBuildNumber',
          ),
        ),
        ListTile(
          minLeadingWidth: 30,
          leading: const Icon(Icons.developer_board),
          title: const Text('Package Name'),
          subtitle: Text(
            appPackageName,
          ),
        ),
        const ListTile(
          minLeadingWidth: 30,
          leading: Icon(Icons.android),
          title: Text('Developer'),
          subtitle: Text(
            'Andrea',
          ),
        ),
        const Divider(),
        ListTile(
          minLeadingWidth: 30,
          leading: const Icon(Icons.shop),
          trailing: const Icon(Icons.arrow_forward),
          title: const Text('Google Play'),
          subtitle: const Text(
            'Tap to open store',
          ),
          onTap: () {
            Utility().launchInBrowser(Uri.parse(
                "https://play.google.com/store/apps/details?id=$appPackageName"));
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

  int viewMode = 0;

  void handleOptionsVertClick(String value) {
    if (value == "settings") {
      Future(
        () => Navigator.of(context)
            .push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            )
            .then((value) => Phoenix.rebirth(context)),
      );
    }

    if (value == "viewmode") {
      setState(() {
        viewMode = viewMode == 0 ? 1 : 0;
        settings.setNewsLayout(viewMode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: categoriesList.tabs.length,
        child: Builder(builder: (BuildContext context) {
          return Scaffold(
              appBar: !isOnSearch
                  ? AppBar(
                      elevation: 0,
                      backgroundColor:
                          darkMode ? ThemeColor.dark2 : colorCategory,
                      title: const Text("Aggregator"),
                      bottom: categoriesList.tabs.length <= 2
                          ? null
                          : PreferredSize(
                              preferredSize: const Size.fromHeight(
                                  55.0), // here the desired height
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    //  color: Colors.blue,
                                    alignment: Alignment.center,

                                    height: 55,
                                    //width: 10000,
                                    child: TabBar(
                                        controller: _tabController,
                                        indicatorWeight: 5,
                                        padding: categoriesList.tabs.length <= 2
                                            ? const EdgeInsets.only(
                                                right: 40, left: 40)
                                            : const EdgeInsets.only(
                                                right: 15, left: 15),
                                        labelPadding:
                                            categoriesList.tabs.length <= 2
                                                ? const EdgeInsets.only(
                                                    right: 30, left: 30)
                                                : const EdgeInsets.only(
                                                    right: 20, left: 20),
                                        indicatorPadding: const EdgeInsets.only(
                                            bottom: 10, top: 5),
                                        unselectedLabelColor: Colors.white,
                                        indicatorColor: colorCategory,
                                        indicator: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: colorCategory,

                                                spreadRadius: 0,
                                                blurRadius: 0,
                                                offset: const Offset(0,
                                                    0), // changes position of shadow
                                              ),
                                            ],
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(100),
                                              topRight: Radius.circular(100),
                                              bottomLeft: Radius.circular(100),
                                              bottomRight: Radius.circular(100),
                                            ),
                                            color: darkMode
                                                ? colorCategory
                                                : ThemeColor.light1),
                                        labelColor: darkMode
                                            ? Colors.white
                                            : Colors.black87,
                                        isScrollable:
                                            categoriesList.tabs.length <= 3 &&
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                ? false
                                                : true,
                                        tabs: List.generate(
                                          categoriesList.tabs.length,
                                          (index) => Tab(
                                            text: categoriesList
                                                        .tabs[index].name ==
                                                    '*'
                                                ? 'Tutti'
                                                : categoriesList
                                                    .tabs[index].name,
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                      actions: <Widget>[
                        if (!isLoading && feedsListUpdate.sites.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.search),
                            tooltip: 'Search',
                            onPressed: () {
                              sleep(const Duration(milliseconds: 200));
                              setState(() {
                                _tabController.index = 0;
                                viewMode = 0;
                                isOnSearch = isOnSearch ? false : true;
                                searchController.text = '';
                              });
                            },
                          ), //
                        if (!isLoading)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh',
                            onPressed: () => {
                              sleep(const Duration(milliseconds: 200)),
                              loadData(true)
                            },
                          ),

                        if (isLoading)
                          IconButton(
                            icon: AnimatedBuilder(
                              animation: _refreshIconController,
                              builder: (_, child) {
                                return Transform.rotate(
                                  angle:
                                      _refreshIconController.value * 3 * 3.1415,
                                  child: child,
                                );
                              },
                              child: const Icon(Icons.autorenew),
                            ),
                            onPressed: () => {},
                          ),

                        PopupMenuButton<int>(
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                                value: 1,
                                onTap: () {
                                  handleOptionsVertClick("settings");
                                },
                                child: const Text('Settings')),
                            PopupMenuItem<int>(
                                value: 1,
                                onTap: () {
                                  handleOptionsVertClick("viewmode");
                                },
                                child: const Text('Change View')),
                          ],
                        ),
                      ],
                    )
                  : AppBar(
                      backgroundColor:
                          darkMode ? ThemeColor.dark2 : colorCategory,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Back',
                        onPressed: () {
                          setState(() {
                            sleep(const Duration(milliseconds: 200));
                            isOnSearch = false;
                            searchController.text = '';
                          });
                        },
                      ), //
                      title: TextField(
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        onSubmitted: (value) {
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                      actions: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: 'Search',
                          onPressed: () {
                            setState(() {
                              feedsList = feedsList;
                              FocusManager.instance.primaryFocus?.unfocus();
                              WidgetsBinding.instance.focusManager.primaryFocus
                                  ?.unfocus();
                            });
                          },
                        ), //
                      ],
                    ),
              drawer: isOnSearch
                  ? null
                  : Drawer(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          UserAccountsDrawerHeader(
                            decoration: BoxDecoration(
                                color: darkMode
                                    ? const Color.fromARGB(255, 27, 28, 35)
                                    : colorCategory), //Theme.of(context).colorScheme.primary),
                            accountName: const Text("Aggregator RSS"),
                            accountEmail: const Text("News Feed Reader"),
                            currentAccountPicture: const CircleAvatar(
                              //radius: 30,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              child: Icon(
                                Icons.rss_feed_rounded,
                                size: 32,
                              ),
                            ),
                          ),
                          /*ListTile(
                            leading: const Icon(
                              Icons.notes_sharp,
                            ),
                            title: const Text("Read News"),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          const Divider(),*/
                          ListTile(
                            leading: Icon(
                              Icons.explore,
                              color: darkMode
                                  ? ThemeColor.light1
                                  : Colors.grey[700],
                            ),
                            title: const Text("Scopri notizie"),
                            trailing: Chip(
                                label: Text(
                                    feedsListUpdate.items.length.toString())),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      DiscoverPage(feedsList: feedsList[0])));
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(
                              Icons.public,
                              color: darkMode
                                  ? ThemeColor.light1
                                  : Colors.grey[700],
                            ),
                            title: const Text("Gestisci siti"),
                            trailing: Chip(
                                label: Text(sitesList.items.length.toString())),
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => const SitesPage()))
                                  .then((value) => Phoenix.rebirth(context));
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.swap_horizontal_circle,
                              color: darkMode
                                  ? ThemeColor.light1
                                  : Colors.grey[700],
                            ),
                            title: const Text("Categorie"),
                            trailing: Chip(
                                label: Text(
                                    categoriesList.items.length.toString())),
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          const CategoriesPage()))
                                  .then((value) => Phoenix.rebirth(context));
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.watch_later,
                              color: darkMode
                                  ? ThemeColor.light1
                                  : Colors.grey[700],
                            ),
                            title: const Text("Leggi piu tardi"),
                            trailing: Chip(label: Text("$nReadLaterItems")),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const ReadlaterPage()));
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.favorite,
                              color: darkMode
                                  ? ThemeColor.light1
                                  : Colors.grey[700],
                            ),
                            title: const Text("Preferiti"),
                            trailing: Chip(label: Text("$nFavouriteItems")),
                            onTap: () {
                              Navigator.pop(context);

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const FavouritesPage()));
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(
                              Icons.settings,
                              color: darkMode
                                  ? ThemeColor.light1
                                  : Colors.grey[700],
                            ),
                            title: const Text("Settings"),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage()))
                                  .then((value) => Phoenix.rebirth(context));
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.help,
                              color: darkMode
                                  ? ThemeColor.light1
                                  : Colors.grey[700],
                            ),
                            title: const Text("Help"),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          const WelcomePage()))
                                  .then((value) => Phoenix.rebirth(context));
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.info,
                              color: darkMode
                                  ? ThemeColor.light1
                                  : Colors.grey[700],
                            ),
                            title: const Text("Info"),
                            //trailing: Chip(label: Text("v$appVersion")),
                            onTap: () {
                              Navigator.pop(context);
                              _showInfoDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
              /*bottomNavigationBar: isLoading
                  ? null
                  : BottomNavigationBar(
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Icon(Icons.notes_sharp), //line_style
                          label: 'News',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.watch_later),
                          label: 'Read Later',
                        ),
                        /* BottomNavigationBarItem(
                                tooltip: "Refresh",
                                label: "",
                                icon: Container(
                                  alignment: Alignment.bottomCenter,
                                  decoration: BoxDecoration(
                                      color: colorCategory,
                                      shape: BoxShape.circle),
                                  padding: const EdgeInsets.all(14),
                                  child: const Icon(
                                    Icons.sync,
                                    color: Colors.white,
                                  ),
                                ),
                                //title: const Text("", style: TextStyle(fontSize: 0)),
                              ),*/
                        BottomNavigationBarItem(
                          icon: Icon(Icons.favorite),
                          label: 'Favourites',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.explore),
                          label: 'Discover',
                        ),
                      ],
                      //elevation: 4,
                      currentIndex: _selectedIndex,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? ThemeColor.dark2
                              : Colors.white,
                      selectedItemColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : colorCategory,
                      unselectedItemColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.bluegrey[700],
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      selectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.bold),
                      type: BottomNavigationBarType.fixed, // Fixed
                      onTap: _onBottomItemTap,
                    ),*/
              onDrawerChanged: (isOpened) {
                nReadLaterItems = 0;
                nFavouriteItems = 0;
                ReadlaterList()
                    .get()
                    .then((value) => nReadLaterItems = value.length);
                FavouritesList()
                    .get()
                    .then((value) => nFavouriteItems = value.length);
                setState(() {});
              },
              body: isLoading
                  ? Container(
                      color: darkMode
                          ? ThemeColor.dark1.withAlpha(100)
                          : ThemeColor.light1,
                      alignment: Alignment.center,
                      child: LoadingIndicator(
                        title: 'Aggiornamento in corso',
                        description: feedsListUpdate.itemLoading,
                        darkMode: darkMode,
                        progressLoading: feedsListUpdate.progressLoading,
                        progressAll: feedsListUpdate.progressAll,
                        progressCompleted: feedsListUpdate.progressCompleted,
                        progressRemaining: feedsListUpdate.progressRemaining,
                      ),
                    )
                  : TabBarView(
                      physics: const TabBarScrollPhysics(),
                      controller: _tabController,
                      children: List.generate(
                          categoriesList.tabs.length,
                          (index) => Container(
                                alignment: Alignment.center,
                                child: NewsSection(
                                  viewMode: viewMode,
                                  searchText: searchController.text,
                                  feedsList: isLoading
                                      ? feedsListUpdate
                                      : feedsList[index],
                                  mainColor: colorCategory,
                                  isLoading: isLoading,
                                ),
                              ))));
        }));
  }
}
