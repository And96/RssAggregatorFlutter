import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/favourites_list.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/readlater_list.dart';
import 'package:rss_aggregator_flutter/core/scroll_physics.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/screens/news_page.dart';
// ignore: depend_on_referenced_packages
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/button_feed_open.dart';
import 'package:rss_aggregator_flutter/widgets/button_feed_option.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
import 'package:rss_aggregator_flutter/widgets/feed_tile.dart';
import 'package:rss_aggregator_flutter/widgets/site_logo.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class NewsSection extends StatefulWidget {
  final int viewMode;
  final bool isLoading;
  final FeedsList feedsList;
  final String searchText;
  final Color mainColor;
  const NewsSection({
    Key? key,
    required this.viewMode,
    required this.isLoading,
    required this.feedsList,
    required this.searchText,
    required this.mainColor,
  }) : super(key: key);

  @override
  State<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection>
    with SingleTickerProviderStateMixin {
  //Loading indicator

  bool isLoading = false;

  late List<Feed> items = [];

  //Theme
  static bool darkMode = false;

  late FavouritesList favouritesList = FavouritesList();
  late ReadlaterList readlaterList = ReadlaterList();

  //Controller
  final ScrollController listviewController = ScrollController();

  @override
  void dispose() {
    /*_timerOpacityAnimation?.cancel();*/
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ThemeColor.isDarkMode().then((value) => {
              darkMode = value,
            });
        await loadData(false);
      } catch (err) {
        //print('Caught error: $err');
      }
    });
  }

  @override
  void didUpdateWidget(NewsSection oldWidget) {
    try {
      if (oldWidget.searchText != widget.searchText || items.isEmpty) {
        loadData(false);
      }
    } catch (err) {
      //print('Caught error: $err');
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> loadData(bool loadFromWeb) async {
    try {
      setState(() {
        isLoading = true;
      });
      await favouritesList.load();
      await readlaterList.load();
      items = widget.feedsList.items.map((e) => e).toList();
      if (widget.searchText.isNotEmpty) {
        items = items
            .where((item) => Utility().compareSearch(
                [item.title, item.link, item.host], widget.searchText))
            .toList();
      }
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
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NewsPage(
                        siteFilter: item.siteID,
                        categoryFilter: '*',
                      )));
            },
            child: SizedBox(
              height: 20,
              width: 20,
              child: SiteLogo(iconUrl: item.iconUrl),
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
        Container(
            padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
            width: 300,
            child: SingleChildScrollView(
              //MUST TO ADDED
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Text(
                      item.link,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                      maxLines: 3,
                    ),
                  ),
                  const Divider(),
                  FutureBuilder<Color?>(
                    future: ThemeColor()
                        .getMainColorFromUrl(item.iconUrl), // async work
                    builder:
                        (BuildContext context, AsyncSnapshot<Color?> snapshot) {
                      Color paletteColor = snapshot.data == null
                          ? Color(ThemeColor().defaultCategoryColor)
                          : snapshot.data!;
                      return ButtonFeedOpen(
                          text: "Leggi sul sito",
                          function: () {
                            Utility().launchInBrowser(Uri.parse(item.link));
                            Navigator.pop(context);
                          },
                          icon: Icons.public,
                          color1: Colors.transparent,
                          color2: paletteColor);
                    },
                  ),
                  const Divider(),
                  GridView(
                      shrinkWrap: true, //MUST TO ADDED

                      physics:
                          const NeverScrollableScrollPhysics(), //MUST TO ADDED
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 3,
                              crossAxisSpacing: 3,
                              childAspectRatio: 2.0),
                      children: [
                        ButtonFeedOption(
                          text: "Leggi\npiu tardi",
                          icon: Icons.watch_later_outlined,
                          function: () {
                            readlaterList.add(item);
                            Navigator.pop(context);
                            const snackBar = SnackBar(
                              duration: Duration(milliseconds: 500),
                              content: Text('Added to read later'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                        ),
                        ButtonFeedOption(
                          text: "Salva\nin preferiti",
                          icon: Icons.favorite_border,
                          function: () {
                            favouritesList.add(item);
                            Navigator.pop(context);
                            const snackBar = SnackBar(
                              duration: Duration(milliseconds: 500),
                              content: Text('Added to favourites'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                        ),
                        ButtonFeedOption(
                          text: "Copia\nLink",
                          icon: Icons.copy,
                          function: () {
                            Clipboard.setData(ClipboardData(text: item.link));
                            Navigator.pop(context);
                            const snackBar = SnackBar(
                              duration: Duration(milliseconds: 500),
                              content: Text('Link copied to clipboard'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                        ),
                        ButtonFeedOption(
                          text: "Condividi\nLink",
                          icon: Icons.share,
                          function: () {
                            Share.share(item.link);
                            Navigator.pop(context);
                          },
                        ),
                      ]),
                ],
              ),
            ))
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  PageController pageController = PageController();
  int pageIndex = 0;

  Widget pageView(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
        child: PageView.builder(
            physics: const PageNewsScrollPhysics(),
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.feedsList.items.length,
            onPageChanged: (i) {
              setState(() {
                pageIndex = i;
              });
            },
            itemBuilder: (context, position) {
              return Container(
                  color: darkMode
                      ? ThemeColor.dark1.withAlpha(50)
                      : widget.mainColor.withAlpha(30),
                  child: Container(
                    margin: const EdgeInsets.only(
                        top: 16, bottom: 16, left: 12, right: 12),
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        color: darkMode ? ThemeColor.dark2 : Colors.white,
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15))),
                    child: InkWell(
                        onTap: () => showOptionDialog(
                            context, widget.feedsList.items[pageIndex]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //const Divider(),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 0, right: 0, top: 18, bottom: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Chip(
                                    backgroundColor: darkMode
                                        ? ThemeColor.dark2
                                        : Colors.white,
                                    avatar: SiteLogo(
                                      //  color: colorCategory,
                                      iconUrl: widget
                                          .feedsList.items[pageIndex].iconUrl,
                                    ),
                                    label: Text(
                                      (widget.feedsList.items[pageIndex].host),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                    Utility().dateFormat(
                                      context,
                                      widget.feedsList.items[pageIndex].pubDate,
                                    ),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 220, //senza img 120
                              margin: const EdgeInsets.only(
                                  bottom: 7, top: 0, left: 0, right: 0),
                              padding: const EdgeInsets.only(
                                  bottom: 0, top: 0, left: 0, right: 0),
                              decoration: BoxDecoration(
                                  color: widget.mainColor.withAlpha(8),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(0))),
                              child: Stack(children: <Widget>[
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.01,
                                    child: Container(color: Colors.black),
                                  ),
                                ),
                                Center(
                                  child: Positioned(
                                      bottom: 0,
                                      left: 0,
                                      width: 365,
                                      child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                              widget.feedsList.items[pageIndex]
                                                  .title,
                                              maxLines: 5,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: darkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.normal)))),
                                )
                              ]),
                            ),

                            Container(
                              padding: const EdgeInsets.only(
                                  left: 0, right: 0, top: 7, bottom: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Chip(
                                    backgroundColor: darkMode
                                        ? ThemeColor.dark2
                                        : Colors.white,
                                    avatar: Icon(
                                      Icons.label,
                                      color: darkMode
                                          ? Colors.blueGrey[200]
                                          : Colors.blueGrey[800],
                                    ),
                                    label: const Text(
                                      "Tecnologia",
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.share_outlined,
                                    color: darkMode
                                        ? Colors.blueGrey[200]
                                        : Colors.blueGrey[800],
                                  ),
                                  Icon(
                                    Icons.copy,
                                    color: darkMode
                                        ? Colors.blueGrey[200]
                                        : Colors.blueGrey[800],
                                  ),
                                  Icon(
                                    Icons.watch_later_outlined,
                                    color: darkMode
                                        ? Colors.blueGrey[200]
                                        : Colors.blueGrey[800],
                                  ),
                                  Icon(
                                    Icons.favorite_outline,
                                    color: darkMode
                                        ? Colors.blueGrey[200]
                                        : Colors.blueGrey[800],
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),

                            /* Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                widget.feedsList.items[pageIndex].title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),*/
                            Expanded(
                              child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                  child: Text(
                                    "${widget.feedsList.items[pageIndex].title} ${widget.feedsList.items[pageIndex].title} ${widget.feedsList.items[pageIndex].title} ${widget.feedsList.items[pageIndex].title} ${widget.feedsList.items[pageIndex].title} ",
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  )),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 0, bottom: 10),
                              child: Text(
                                widget.feedsList.items[pageIndex].link,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: darkMode
                                      ? ThemeColor.light3
                                      : ThemeColor.dark4,
                                ),
                              ),
                            ),
                            /* FloatingActionButton(
                              child: Text(pageIndex.toString()),
                              onPressed: () {
                                pageController.jumpToPage(pageIndex + 1);
                              })*/
                          ],
                        )),
                  ));
            }));
  }

  Widget listView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4, right: 4, bottom: 0),
      child: Scrollbar(
          controller: listviewController,
          thickness: widget.searchText.isNotEmpty
              ? 0
              : 8, //hide scrollbar wrong if something is hidden is ok to hide them
          child: MediaQuery.of(context).size.width <
                  MediaQuery.of(context).size.height
              ? ListView.builder(
                  controller: listviewController,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, index) {
                    final item = items[index];

                    return FeedTile(
                      darkMode: darkMode,
                      title: item.title,
                      link: item.link,
                      host: item.host,
                      pubDate: item.pubDate,
                      iconUrl: item.iconUrl,
                      function: () => showOptionDialog(context, item),
                      mainColor: widget.mainColor,
                    );
                  })
              : GridView.builder(
                  controller: listviewController,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, index) {
                    final item = items[index];

                    return FeedTile(
                      darkMode: darkMode,
                      title: item.title,
                      link: item.link,
                      host: item.host,
                      pubDate: item.pubDate,
                      iconUrl: item.iconUrl,
                      function: () => showOptionDialog(context, item),
                      mainColor: widget.mainColor,
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 800
                          ? MediaQuery.of(context).size.width > 1150
                              ? 4
                              : 3
                          : 2,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: MediaQuery.of(context).size.width /
                                  MediaQuery.of(context).size.height <
                              1.9
                          ? MediaQuery.of(context).size.width /
                                      MediaQuery.of(context).size.height <
                                  1.6
                              ? MediaQuery.of(context).size.width /
                                          MediaQuery.of(context).size.height <
                                      1.4
                                  ? 2.0
                                  : 2.0
                              : 2.1
                          : 2.9),
                )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkMode
          ? ThemeColor.dark1.withAlpha(120)
          : widget.feedsList.items.isEmpty
              ? ThemeColor.light1
              : Color.alphaBlend(widget.mainColor.withAlpha(50),
                      Colors.blueGrey.withAlpha(50))
                  .withAlpha(15), //.withOpacity(0.1),
      child: widget.isLoading == false
          ? widget.feedsList.items.isEmpty
              ? Center(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    EmptySection(
                      title: 'Nessuna notizia presente',
                      description:
                          'Premi aggiorna o aggiungi altri siti da seguire',
                      icon: Icons.space_dashboard,
                      darkMode: darkMode,
                    ),
                  ],
                ))
              : widget.viewMode == 0
                  ? listView(context)
                  : pageView(context)
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  EmptySection(
                    title: '...',
                    description: widget.feedsList.itemLoading,
                    icon: Icons.query_stats,
                    darkMode: darkMode,
                  ),
                ],
              ),
            ),
    );
  }
}
