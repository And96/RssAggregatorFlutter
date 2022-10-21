import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/favourites_list.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/readlater_list.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
import 'package:rss_aggregator_flutter/widgets/site_logo.dart';
/*import 'dart:async';*/
import 'package:share_plus/share_plus.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/services.dart';

class NewsSection extends StatefulWidget {
  final bool isLoading;
  final FeedsList feedsList;
  final String searchText;
  const NewsSection(
      {Key? key,
      required this.isLoading,
      required this.feedsList,
      required this.searchText})
      : super(key: key);

  @override
  State<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection>
    with SingleTickerProviderStateMixin {
  //Loading indicator

  bool isLoading = false;

  //Theme
  static bool darkMode = false;
  double opacityAnimation = 1.0;

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      /*await setOpacityAnimation();*/
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
      await loadData();
    });
    super.initState();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await favouritesList.load();
    } catch (err) {
      //print('Caught error: $err');
    }
    setState(() {
      isLoading = false;
    });
  }

  /*Timer? _timerOpacityAnimation;
  setOpacityAnimation() {
    if (mounted) {
      _timerOpacityAnimation = Timer(const Duration(milliseconds: 800), () {
        setState(() {
          opacityAnimation = opacityAnimation <= 0.5 ? 1.0 : 0.5;
          setOpacityAnimation();
        });
      });
    }
  }*/

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
          leading: const Icon(Icons.star_border),
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
    return Stack(
      children: [
        widget.isLoading == false
            ? widget.feedsList.items.isEmpty
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
                        thickness: widget.searchText.isNotEmpty
                            ? 0
                            : 3, //hide scrollbar wrong if something is hidden is ok to hide them
                        child: ListView.separated(
                            controller: listviewController,
                            itemCount: widget.feedsList.items.length,
                            separatorBuilder: (context, index) {
                              return Visibility(
                                  visible: widget.searchText.isEmpty ||
                                      Utility().compareSearch([
                                        widget.feedsList.items[index].title,
                                        widget.feedsList.items[index].link,
                                        widget.feedsList.items[index].host
                                      ], widget.searchText),
                                  child: const Divider());
                            },
                            itemBuilder: (BuildContext context, index) {
                              final item = widget.feedsList.items[index];

                              return Visibility(
                                  visible: widget.searchText.isEmpty ||
                                      Utility().compareSearch(
                                          [item.title, item.link, item.host],
                                          widget.searchText),
                                  child: InkWell(
                                    onTap: () =>
                                        showOptionDialog(context, item),
                                    child: ListTile(
                                        minLeadingWidth: 30,
                                        leading: SiteLogo(
                                          iconUrl: item.iconUrl,
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
                                                  ? ThemeColor.light3
                                                  : ThemeColor.dark4,
                                            ),
                                          ),
                                        ),
                                        isThreeLine: true,
                                        subtitle: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                SizedBox(
                                                  child: Text(
                                                    item.title.toString(),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: darkMode
                                                          ? ThemeColor.light2
                                                          : ThemeColor.dark1,
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
                                                            .format(Utility()
                                                                .tryParse(item
                                                                    .pubDate
                                                                    .toString())
                                                                .toLocal())),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: darkMode
                                                              ? ThemeColor
                                                                  .light3
                                                              : ThemeColor
                                                                  .dark4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ))),
                                  ));
                            })),
                  )
            : Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AnimatedOpacity(
                      opacity: widget.isLoading ? opacityAnimation : 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: EmptySection(
                        title: 'Ricerca notizie in corso',
                        description: widget.feedsList.itemLoading,
                        icon: Icons.query_stats,
                        darkMode: darkMode,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(100, 18, 100, 0),
                      child: LinearPercentIndicator(
                        animation: true,
                        progressColor: Theme.of(context).colorScheme.primary,
                        lineHeight: 3.0,
                        animateFromLastPercent: true,
                        animationDuration: 2000,
                        percent: widget.feedsList.progressLoading,
                        barRadius: const Radius.circular(16),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}
