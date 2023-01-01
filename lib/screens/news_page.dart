import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/settings.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/loading_indicator.dart';
import 'package:rss_aggregator_flutter/widgets/news_section.dart';

class NewsPage extends StatefulWidget {
  const NewsPage(
      {Key? key, required this.siteFilter, required this.categoryFilter})
      : super(key: key);

  final int siteFilter;
  final String categoryFilter;

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with SingleTickerProviderStateMixin {
  late FeedsList feedList = FeedsList(updateItemLoading: _updateItemLoading);
  late CategoriesList categoriesList = CategoriesList();
  late SitesList sitesList =
      SitesList.withIndicator(updateItemLoading: (String value) {});
  void _updateItemLoading(String itemLoading) {
    setState(() {});
  }

//Loading indicator
  bool isLoading = false;

  //Search indicator
  bool isOnSearch = false;

  //Theme
  static bool darkMode = false;

  String siteName = "";

  int viewMode = 0;

  //Controller
  TextEditingController searchController = TextEditingController();

  late final AnimationController _refreshIconController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _refreshIconController.stop(canceled: true);
    _refreshIconController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Color mainColor = ThemeColor.primaryColorLight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
      await loadData(false);
    });
  }

  Future<void> loadData(bool loadFromWeb) async {
    try {
      if (isLoading) {
        return;
      }
      isLoading = true;
      setState(() {});

//read news layout
      viewMode = await Settings().getNewsLayout();

      await categoriesList.load(true);

      await sitesList.load();

      await feedList.load(
          loadFromWeb, widget.siteFilter, widget.categoryFilter);

      //reload if 1 site only and no item
      if (widget.siteFilter > 0) {
        if (feedList.items.isEmpty) {
          await feedList.load(true, widget.siteFilter, widget.categoryFilter);
        }
      }

      if (widget.siteFilter > 0) {
        //get color from icon
        siteName = sitesList.items
                .where((e) => e.siteID == widget.siteFilter)
                .isNotEmpty
            ? sitesList.items
                .where((e) => e.siteID == widget.siteFilter)
                .first
                .siteName
            : "Not found";

        if (!darkMode) {
          mainColor = (await ThemeColor().getMainColorFromUrl(sitesList.items
              .where((e) => e.siteID == widget.siteFilter)
              .first
              .iconUrl));
          if (mainColor.blue + mainColor.red + mainColor.green > 400) {
            mainColor = Color.fromARGB(
                255,
                mainColor.red < 30 ? 0 : mainColor.red - 30,
                mainColor.green < 30 ? 0 : mainColor.green - 30,
                mainColor.blue < 30 ? 0 : mainColor.blue - 30);
          }
        }
      } else {
        mainColor = categoriesList.getColorSync(widget.categoryFilter);
      }
    } catch (err) {
      // print('Caught error: $err');
    }
    isLoading = false;
    setState(() {});
  }

  void handleOptionsVertClick(String value) {
    if (value == "viewmode") {
      setState(() {
        viewMode = viewMode == 0 ? 1 : 0;
        Settings().setNewsLayout(viewMode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: !isOnSearch
            ? AppBar(
                elevation: 0,
                backgroundColor: darkMode ? ThemeColor.dark2 : mainColor,
                title: widget.siteFilter > 0
                    ? Text(siteName)
                    : Text(widget.categoryFilter),
                actions: <Widget>[
                  if (!isLoading && feedList.sites.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () {
                        sleep(const Duration(milliseconds: 200));
                        setState(() {
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

                  PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                          value: 1,
                          onTap: () {
                            handleOptionsVertClick("viewmode");
                          },
                          child: const Text('Change View')),
                    ],
                  ),

                  if (isLoading)
                    IconButton(
                      icon: AnimatedBuilder(
                        animation: _refreshIconController,
                        builder: (_, child) {
                          return Transform.rotate(
                            angle: _refreshIconController.value * 3 * 3.1415,
                            child: child,
                          );
                        },
                        child: const Icon(Icons.autorenew),
                      ),
                      onPressed: () => {},
                    ),
                ],
              )
            : AppBar(
                elevation: 0,
                backgroundColor: darkMode ? ThemeColor.dark2 : mainColor,
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
                        feedList = feedList;
                        FocusManager.instance.primaryFocus?.unfocus();
                        WidgetsBinding.instance.focusManager.primaryFocus
                            ?.unfocus();
                      });
                    },
                  ), //
                ],
              ),
        body: isLoading
            ? Container(
                alignment: Alignment.center,
                color: darkMode
                    ? ThemeColor.dark1.withAlpha(100)
                    : ThemeColor.light1,
                child: LoadingIndicator(
                  title: 'Aggiornamento in corso',
                  description: feedList.itemLoading,
                  darkMode: darkMode,
                  progressLoading: feedList.progressLoading,
                  progressAll: feedList.progressAll,
                  progressCompleted: feedList.progressCompleted,
                  progressRemaining: feedList.progressRemaining,
                ),
              )
            : Container(
                alignment: Alignment.center,
                child: NewsSection(
                  viewMode: viewMode,
                  searchText: searchController.text,
                  feedsList: feedList,
                  mainColor: mainColor,
                  isLoading: isLoading,
                ),
              ));
  }
}
