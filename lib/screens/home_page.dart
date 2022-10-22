import 'dart:io';
//import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rss_aggregator_flutter/core/category.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/settings.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
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
  void _updateItemLoading(String itemLoading) {
    setState(() {});
  }

  //Loading indicator
  bool isLoading = false;

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
    load().then((value) => value == true
        ? Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const WelcomePage()))
            .then((value) => Phoenix.rebirth(context))
        : null);
  }

  Future<bool> load() async {
    bool firstRun = false;
    try {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        await ThemeColor.isDarkMode().then((value) => {
              darkMode = value,
            });
        await loadPackageInfo();
        await settings.init();
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getBool('first_run_app') == null) {
          categoriesList.add("News");
          prefs.setBool('first_run_app', true);
          firstRun = true;
        }
        await categoriesList.load(true);
        await setCategoryColor();
        setState(() {
          _tabController =
              TabController(length: categoriesList.tabs.length, vsync: this);
        });
        _tabController.addListener(() {
          setCategoryColor();
          setState(() {});
        });

        await loadData(false);
      });
    } catch (err) {
      //print('Caught error: $err');
    }
    return firstRun;
  }

  setCategoryColor() {
    try {
      colorCategory = Color(categoriesList.tabs[_tabController.index].color);
      // Colors.primaries[Random().nextInt(Colors.primaries.length)];//random color
    } catch (err) {
      colorCategory = ThemeColor.primaryColorLight;
    }
  }

  loadPackageInfo() {
    try {
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        appName = packageInfo.appName;
        appPackageName = packageInfo.packageName;
        appVersion = packageInfo.version;
        appBuildNumber = packageInfo.buildNumber;
      });
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  loadData(bool loadFromWeb) async {
    try {
      if (isLoading) {
        return;
      }
      isLoading = true;
      setState(() {});
      await feedsListUpdate.load(loadFromWeb, "*", "*");
      feedsList = [];
      for (Category c in categoriesList.tabs) {
        FeedsList f = FeedsList(updateItemLoading: null);
        await f.load(false, '*', c.name);
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

  void handleOptionsVertClick(int item) {
    switch (item) {
      case 0:
        break;
      case 1:
        break;
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
                      //elevation: 0,
                      backgroundColor:
                          darkMode ? Colors.black26 : colorCategory,
                      title: const Text("Aggregator"),

                      bottom: categoriesList.tabs.length <= 2
                          ? null
                          : TabBar(
                              controller: _tabController,
                              indicatorWeight: 5,
                              padding: categoriesList.tabs.length <= 2
                                  ? const EdgeInsets.only(right: 40, left: 40)
                                  : const EdgeInsets.only(right: 15, left: 15),
                              labelPadding: categoriesList.tabs.length <= 2
                                  ? const EdgeInsets.only(right: 30, left: 30)
                                  : const EdgeInsets.only(right: 20, left: 20),
                              indicatorPadding:
                                  const EdgeInsets.only(bottom: 10, top: 5),
                              unselectedLabelColor: Colors.white,
                              indicatorColor: colorCategory,
                              indicator: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorCategory,

                                      spreadRadius: 0,
                                      blurRadius: 0,
                                      offset: const Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(100),
                                    topRight: Radius.circular(100),
                                    bottomLeft: Radius.circular(100),
                                    bottomRight: Radius.circular(100),
                                  ),
                                  color: darkMode
                                      ? colorCategory
                                      : ThemeColor.light1),
                              labelColor:
                                  darkMode ? Colors.white : Colors.black87,
                              isScrollable:
                                  true, //categoriesList.tabs.length > 3? true: false,
                              tabs: List.generate(
                                categoriesList.tabs.length,
                                (index) => Tab(
                                  text: categoriesList.tabs[index].name == '*'
                                      ? 'Tutti'
                                      : categoriesList.tabs[index].name,
                                ),
                              )),

                      actions: <Widget>[
                        if (!isLoading && feedsListUpdate.sites.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.search),
                            tooltip: 'Search',
                            onPressed: () {
                              sleep(const Duration(milliseconds: 200));
                              setState(() {
                                isOnSearch = isOnSearch ? false : true;
                                searchController.text = '';
                              });
                              /*if (feedsList.items.isNotEmpty) {
                          listviewController.animateTo(
                              listviewController.position.minScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.fastOutSlowIn);
                        }*/
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
                          onSelected: (item) => handleOptionsVertClick(item),
                          itemBuilder: (context) => [
                            const PopupMenuItem<int>(
                                value: 1, child: Text('Filter site')),
                            const PopupMenuItem<int>(
                                value: 1, child: Text('Filter category')),
                          ],
                        ),
                      ],
                    )
                  : AppBar(
                      backgroundColor:
                          darkMode ? Colors.black26 : colorCategory,
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
                                    ? Colors.black26
                                    : colorCategory), //Theme.of(context).colorScheme.primary),
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
                          ListTile(
                            leading: const Icon(Icons.my_library_books_rounded),
                            title: const Text("Manage Sites"),
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => const SitesPage()))
                                  .then((value) => Phoenix.rebirth(context));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.sell),
                            title: const Text("Categories"),
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          const CategoriesPage()))
                                  .then((value) => Phoenix.rebirth(context));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.watch_later),
                            title: const Text("Read Later"),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const ReadlaterPage()));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.star),
                            title: const Text("Favourites"),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const FavouritesPage()));
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text("Settings"),
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage()))
                                  .then((value) => Phoenix.rebirth(context));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.help),
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
                            leading: const Icon(Icons.info),
                            title: const Text("Info"),
                            onTap: () {
                              Navigator.pop(context);
                              _showInfoDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
              bottomNavigationBar: categoriesList.tabs.length <= 2
                  ? null
                  : Container(
                      height: 58,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10.0),
                        ],
                      ),
                      child: Material(
                        elevation: 8,
                        color: darkMode ? Colors.black26 : Colors.white,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              TabBar(
                                  controller: _tabController,
                                  indicatorPadding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  padding: categoriesList.tabs.length <= 2
                                      ? const EdgeInsets.only(
                                          right: 40, left: 40)
                                      : const EdgeInsets.only(
                                          right: 15, left: 15),
                                  labelPadding: categoriesList.tabs.length <= 2
                                      ? const EdgeInsets.only(
                                          right: 30, left: 30)
                                      : const EdgeInsets.only(
                                          right: 20, left: 20),
                                  unselectedLabelColor:
                                      darkMode ? Colors.white : Colors.black87,

                                  //indicatorSize: TabBarIndicatorSize.label,
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
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                        bottomLeft: Radius.circular(100),
                                        bottomRight: Radius.circular(100),
                                      ),
                                      color: colorCategory),
                                  labelColor: Colors.white,
                                  isScrollable:
                                      true, //categoriesList.tabs.length > 3
                                  //? true
                                  //: false,
                                  tabs: List.generate(
                                    categoriesList.tabs.length,
                                    (index) => Tab(
                                      text:
                                          categoriesList.tabs[index].name == '*'
                                              ? 'Tutti'
                                              : categoriesList.tabs[index].name,
                                    ),
                                  )),
                            ]),
                      ),
                    ),
              body: TabBarView(
                  physics: const CustomPageViewScrollPhysics(),
                  controller: _tabController,
                  children: List.generate(
                      categoriesList.tabs.length,
                      (index) => Container(
                            alignment: Alignment.center,
                            //color: colorCategory, //colors[index],
                            /*color: Color(categoriesList
                                .tabs[_tabController.index].color),*/
                            child: NewsSection(
                              searchText: searchController.text,
                              feedsList: isLoading
                                  ? feedsListUpdate
                                  : feedsList[index],
                              isLoading: isLoading,
                            ), /*Text(
                              categoriesList.tabs[index].name,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),*/
                          ))));
        }));
  }
}

//custom page changing speed because by default on swiping _tabController.addListener(() { is fired later than on tap
class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 200,
        stiffness: 100,
        damping: 0.4,
      );
}
