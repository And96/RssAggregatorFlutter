import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/loading_indicator.dart';
import 'package:rss_aggregator_flutter/widgets/news_section.dart';

class NewsPage extends StatefulWidget {
  const NewsPage(
      {Key? key, required this.siteFilter, required this.categoryFilter})
      : super(key: key);

  final String siteFilter;
  final String categoryFilter;

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with SingleTickerProviderStateMixin {
  late FeedsList feedList = FeedsList(updateItemLoading: _updateItemLoading);
  late CategoriesList categoriesList = CategoriesList();
  late SitesList sitesList = SitesList(updateItemLoading: (String value) {});
  void _updateItemLoading(String itemLoading) {
    setState(() {});
  }

//Loading indicator
  bool isLoading = false;

  //Search indicator
  bool isOnSearch = false;

  //Theme
  static bool darkMode = false;

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

  Color colorCategory = ThemeColor.primaryColorLight;

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
      await categoriesList.load(true);

      await feedList.load(
          loadFromWeb, widget.siteFilter, widget.categoryFilter);

      if (widget.siteFilter.trim().length > 1) {
      } else {
        colorCategory = Color(categoriesList.getColor(widget.categoryFilter));
      }
    } catch (err) {
      //print('Caught error: $err');
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: !isOnSearch
            ? AppBar(
                elevation: 0,
                backgroundColor: darkMode ? ThemeColor.dark2 : colorCategory,
                title: widget.siteFilter.trim().length > 1
                    ? Text(widget.siteFilter)
                    : Text(widget.categoryFilter),
                actions: <Widget>[
                  if (!isLoading && feedList.sites.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () {
                        sleep(const Duration(milliseconds: 200));
                        setState(() {
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
                backgroundColor: darkMode ? ThemeColor.dark2 : colorCategory,
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
                child: LoadingIndicator(
                  title: 'Aggiornamento in corso',
                  description: feedList.itemLoading,
                  darkMode: darkMode,
                  progressLoading: feedList.progressLoading,
                ),
              )
            : Container(
                alignment: Alignment.center,
                child: NewsSection(
                  searchText: searchController.text,
                  feedsList: feedList,
                  colorCategory: colorCategory,
                  isLoading: isLoading,
                ),
              ));
  }
}
