import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/favourites_list.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/readlater_list.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/screens/news_page.dart';
// ignore: depend_on_referenced_packages
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
import 'package:rss_aggregator_flutter/widgets/feed_tile.dart';
import 'package:rss_aggregator_flutter/widgets/site_logo.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class NewsSection extends StatefulWidget {
  final bool isLoading;
  final FeedsList feedsList;
  final String searchText;
  final Color mainColor;
  const NewsSection({
    Key? key,
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
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            width: 250,
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
                  GridView(
                      shrinkWrap: true, //MUST TO ADDED

                      physics:
                          const NeverScrollableScrollPhysics(), //MUST TO ADDED
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                              childAspectRatio: 1.6),
                      children: [
                        InkWell(
                          onTap: () {
                            readlaterList.add(item);
                            Navigator.pop(context);
                            const snackBar = SnackBar(
                              duration: Duration(milliseconds: 500),
                              content: Text('Added to read later'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Expanded(
                                    child: Icon(
                                  Icons.watch_later_outlined,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                  size: 27.0,
                                )),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Text('Leggi piu tardi'),
                                ),
                              ]),
                        ),
                        InkWell(
                          onTap: () {
                            favouritesList.add(item);
                            Navigator.pop(context);
                            const snackBar = SnackBar(
                              duration: Duration(milliseconds: 500),
                              content: Text('Added to favourites'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Expanded(
                                    child: Icon(
                                  Icons.favorite_border,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                  size: 27.0,
                                )),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Text('Salva nei preferiti'),
                                ),
                              ]),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: item.link));
                            Navigator.pop(context);
                            const snackBar = SnackBar(
                              duration: Duration(milliseconds: 500),
                              content: Text('Link copied to clipboard'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                    child: Icon(
                                  Icons.copy,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                  size: 27.0,
                                )),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Text('Copia Link'),
                                ),
                              ]),
                        ),
                        InkWell(
                          onTap: () {
                            Share.share(item.link);
                            Navigator.pop(context);
                          },
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                    child: Icon(
                                  Icons.share,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                  size: 27.0,
                                )),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Text('Condividi Link'),
                                ),
                              ]),
                        ),
                      ]),
                  const Divider(),
                  FutureBuilder<Color?>(
                    future: ThemeColor()
                        .getMainColorFromUrl(item.iconUrl), // async work
                    builder:
                        (BuildContext context, AsyncSnapshot<Color?> snapshot) {
                      Color paletteColor = snapshot.data == null
                          ? Color(ThemeColor().defaultCategoryColor)
                          : snapshot.data!;
                      return Container(
                        padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                        width: double.infinity,
                        height: 55,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: darkMode
                                  ? ThemeColor.dark3.withAlpha(0)
                                  : Colors.black.withAlpha(10),
                              width: 0.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 0.0,
                          //color: Color(recommendedList.items[index].color),
                          //color: Color.fromARGB(255, 236, 236, 236),
                          color: darkMode ||
                                  (paletteColor.blue / 2 +
                                          paletteColor.green +
                                          paletteColor.red <
                                      170)
                              ? paletteColor.withAlpha(150)
                              : paletteColor.withAlpha(190),
                          //padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          /* width: double.infinity,
                        height: double.infinity,*/

                          child: InkWell(
                            splashColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[900]
                                    : Colors.white,
                            onTap: () async {
                              Utility().launchInBrowser(Uri.parse(item.link));
                              Navigator.pop(context);
                            },
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 15, 0),
                                    child: Icon(
                                      Icons.open_in_browser,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[300]
                                          : Colors.black.withAlpha(200),
                                      size: 27.0,
                                    ),
                                  ),
                                  Text(
                                    'Leggi sul sito',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                /*ListTile(
          leading: const Icon(Icons.open_in_new),
          title: const Text('Open site'),
          onTap: () async {
            Utility().launchInBrowser(Uri.parse(item.link));
            Navigator.pop(context);
          },
        ),*/
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkMode
          ? ThemeColor.dark1.withAlpha(120)
          : widget.feedsList.items.isEmpty
              ? ThemeColor.light1
              : Color.alphaBlend(widget.mainColor.withAlpha(100),
                      Colors.blueGrey.withAlpha(100))
                  .withAlpha(25), //.withOpacity(0.1),
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
              : Padding(
                  padding: const EdgeInsets.only(
                      top: 6, left: 6, right: 6, bottom: 0),
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

                                return InkWell(
                                    onTap: () =>
                                        showOptionDialog(context, item),
                                    child: FeedTile(
                                        darkMode: darkMode,
                                        title: item.title,
                                        link: item.link,
                                        host: item.host,
                                        pubDate: item.pubDate,
                                        iconUrl: item.iconUrl));
                              })
                          : GridView.builder(
                              controller: listviewController,
                              itemCount: items.length,
                              itemBuilder: (BuildContext context, index) {
                                final item = items[index];

                                return InkWell(
                                    onTap: () =>
                                        showOptionDialog(context, item),
                                    child: FeedTile(
                                        darkMode: darkMode,
                                        title: item.title,
                                        link: item.link,
                                        host: item.host,
                                        pubDate: item.pubDate,
                                        iconUrl: item.iconUrl));
                              },
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              800
                                          ? MediaQuery.of(context).size.width >
                                                  1150
                                              ? 4
                                              : 3
                                          : 2,
                                      crossAxisSpacing: 0,
                                      mainAxisSpacing: 0,
                                      childAspectRatio: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height <
                                              1.9
                                          ? MediaQuery.of(context).size.width /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height <
                                                  1.6
                                              ? MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height <
                                                      1.4
                                                  ? 2.0
                                                  : 2.0
                                              : 2.1
                                          : 2.9),
                            )),
                )
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
