import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/news_section.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'dart:math' as math;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Settings settings = Settings();

  late FeedsList feedsList = FeedsList(updateItemLoading: _updateItemLoading);
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

  @override
  initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
      await loadPackageInfo();
      await settings.init();
      await loadData();
    });
  }

  loadPackageInfo() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appName = packageInfo.appName;
      appPackageName = packageInfo.packageName;
      appVersion = packageInfo.version;
      appBuildNumber = packageInfo.buildNumber;
    });
  }

  loadData() async {
    try {
      if (isLoading) {
        return;
      }

      setState(() {
        isLoading = true;
      });
      await categoriesList.load();
      await feedsList.load();
    } catch (err) {
      //print('Caught error: $err');
    }
    setState(() {
      isLoading = false;
    });
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

  /*void _awaitReturnValueFromSecondScreen(
      BuildContext context, String urlInput) async {
    try {
      // start the SecondScreen and wait for it to finish with a result
      final resultTextInput = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SitesPage(),
          ));

      // after the SecondScreen result comes back update the Text widget with it
      if (resultTextInput != null) {
        if (mounted) {
          setState(() {
            bottomTappedAnimation(0, 0);
            searchController.text = resultTextInput.toString();
            isOnSearch = true;
            isOnSearchReadOnly = true;
            FocusScope.of(context).unfocus();
          });
          FocusManager.instance.primaryFocus?.unfocus();
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        }
      }
    } catch (err) {
      // print('Caught error: $err');
    }
  }*/

  Color colorAppBar = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: categoriesList.items.length,
        child: Scaffold(
            appBar: !isOnSearch
                ? AppBar(
                    backgroundColor: colorAppBar,
                    title: const Text("Aggregator"),
                    bottom: TabBar(
                        onTap: (index) {
                          setState(() {
                            colorAppBar = Colors.primaries[
                                Random().nextInt(Colors.primaries.length)];
                          });
                        },
                        /*indicatorWeight: 2,
                    indicatorPadding: const EdgeInsets.symmetric(vertical: 8),*/
                        unselectedLabelColor: Colors.white,
                        indicatorColor: Colors.white,
                        indicator: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            color: Color.fromARGB(255, 239, 239, 239)),
                        labelColor: Colors.black87,
                        isScrollable:
                            categoriesList.items.length > 3 ? true : false,
                        tabs: List.generate(
                          categoriesList.items.length,
                          (index) => Tab(
                            text: categoriesList.items[index].name,
                          ),
                        )),

                    // bottom:
                    actions: <Widget>[
                      if (!isLoading && feedsList.sites.isNotEmpty)
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
                            loadData()
                          },
                        ),

                      if (isLoading)
                        IconButton(
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
                                builder: (context) => const FavouritesPage()));
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
                            _showInfoDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
            bottomNavigationBar: Container(
              height: categoriesList.items.length > 1 ? 58 : 0,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10.0),
                ],
              ),
              child: Material(
                elevation: 8,
                child: TabBar(
                    /*indicatorWeight: 2,
                    indicatorPadding: const EdgeInsets.symmetric(vertical: 8),*/
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: Colors.black87,
                    isScrollable:
                        categoriesList.items.length > 3 ? true : false,
                    tabs: List.generate(
                      categoriesList.items.length,
                      (index) => Tab(
                        text: categoriesList.items[index].name,
                      ),
                    )),
              ),
            ),
            body: TabBarView(
                children: List.generate(
              categoriesList.items.length,
              (index) => NewsSection(
                searchText: searchController.text,
                feedsList: feedsList,
                isLoading: isLoading,
              ),
            ))));
  }
}
