import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/settings.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
//import 'package:rss_aggregator_flutter/screens/sites_page.dart';
import 'package:rss_aggregator_flutter/screens/settings_page.dart';
import 'package:rss_aggregator_flutter/screens/categories_page.dart';
// ignore: depend_on_referenced_packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rss_aggregator_flutter/screens/sites_page.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/news_section.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Settings settings = Settings();

  late FeedsList feedsList = FeedsList(updateItemLoading: _updateItemLoading);
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

  int _selectedPageIndex = 0;

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

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  void pageChanged(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void bottomTapped(int index) {
    bottomTappedAnimation(index, 500);
  }

  void bottomTappedAnimation(int index, int timeAnimation) {
    setState(() {
      _selectedPageIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: timeAnimation), curve: Curves.ease);
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

      await feedsList.load();
    } catch (err) {
      //print('Caught error: $err');
    }
    setState(() {
      isLoading = false;
    });
  }

  void showOptionDialog(BuildContext context, Feed item) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: !isOnSearch
            ? AppBar(
                title: const Text("Aggregator"),
                actions: <Widget>[
                  if (!isLoading && feedsList.sites.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () {
                        sleep(const Duration(milliseconds: 200));
                        setState(() {
                          bottomTappedAnimation(0, 0);
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
                            angle: _refreshIconController.value * 4 * 3.1415,
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
                      leading: const Icon(Icons.toc_outlined),
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
                                builder: (context) => const CategoriesPage()))
                            .then((value) => Phoenix.rebirth(context));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.watch_later_outlined),
                      title: const Text("Read Later"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.star),
                      title: const Text("Starred"),
                      onTap: () {},
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
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10.0),
            ],
          ),
          child: BottomNavigationBar(
            selectedFontSize: 15,
            unselectedFontSize: 15,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt, size: 0),
                label: 'News Feed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.watch_later_outlined, size: 0),
                label: 'Read Later',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star, size: 0),
                label: 'Starred',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.travel_explore_rounded, size: 0),
                label: 'Discover',
              ),
            ],
            currentIndex: _selectedPageIndex,
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
            NewsSection(
              searchText: searchController.text,
              feedsList: feedsList,
              isLoading: isLoading,
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
