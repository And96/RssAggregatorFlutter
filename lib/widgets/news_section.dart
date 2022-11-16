import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/favourites_list.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/readlater_list.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
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
  final Color colorCategory;
  const NewsSection({
    Key? key,
    required this.isLoading,
    required this.feedsList,
    required this.searchText,
    required this.colorCategory,
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
        await loadData();
      } catch (err) {
        //print('Caught error: $err');
      }
    });
  }

  @override
  void didUpdateWidget(NewsSection oldWidget) {
    try {
      if (oldWidget.searchText != widget.searchText) {
        loadData();
      }
    } catch (err) {
      //print('Caught error: $err');
    }
    super.didUpdateWidget(oldWidget);
  }

  loadData() async {
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
          SizedBox(
            height: 20,
            width: 20,
            child: SiteLogo(iconUrl: item.iconUrl),
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
          child: SizedBox(
            width: 250,
            child: Text(
              item.link,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.left,
              maxLines: 3,
            ),
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
            readlaterList.add(item);
            Navigator.pop(context);
            const snackBar = SnackBar(
              duration: Duration(milliseconds: 500),
              content: Text('Added to read later'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        ),
        ListTile(
          leading: const Icon(Icons.favorite_border),
          title: const Text('Add to favourites'),
          onTap: () {
            favouritesList.add(item);
            Navigator.pop(context);
            const snackBar = SnackBar(
              duration: Duration(milliseconds: 500),
              content: Text('Added to favourites'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkMode
          ? ThemeColor.dark1.withAlpha(90)
          : ThemeColor.light2.withAlpha(90),
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
                      top: 5, left: 1, right: 1, bottom: 0),
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
