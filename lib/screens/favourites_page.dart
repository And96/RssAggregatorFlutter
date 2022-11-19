import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/favourites_list.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:flutter/services.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/feed_tile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  double progressLoading = 0;
  late FavouritesList favouritesList = FavouritesList();
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
      await loadData();
    });
  }

  @override
  dispose() {
    _refreshIconController.stop(canceled: true);
    _refreshIconController.dispose();
    super.dispose();
  }

  late final AnimationController _refreshIconController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  void showOptionDialog(BuildContext context, Feed item) {
    var dialog = SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            "Options",
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
          leading: const Icon(Icons.open_in_new),
          title: const Text('Open site'),
          onTap: () async {
            Utility().launchInBrowser(Uri.parse(item.link));
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
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete link'),
          onTap: () {
            setState(() {
              favouritesList.delete(item.link);
            });
            Navigator.pop(context);
            const snackBar = SnackBar(
              duration: Duration(seconds: 1),
              content: Text('Deleted'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          //onTap: showDeleteAlertDialog(context, url),
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  showDeleteDialog(BuildContext context, String url) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        setState(() {
          favouritesList.delete(url);
        });
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      content: const Text("Delete all items?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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

  //Controller
  final ScrollController listviewController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: favouritesList.items.isEmpty
              ? const Text('Favourites')
              : Text('Favourites (${favouritesList.items.length})'),
          actions: <Widget>[
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
            if (favouritesList.items.isNotEmpty && !isLoading)
              IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete',
                  onPressed: () => showDeleteDialog(context, "*")),
          ],
        ),
        body: Container(
            color: darkMode
                ? ThemeColor.dark1.withAlpha(150)
                : ThemeColor.light1.withAlpha(255),
            padding:
                const EdgeInsets.only(top: 6, left: 6, right: 6, bottom: 0),
            child: Stack(children: [
              isLoading == false
                  ? favouritesList.items.isEmpty
                      ? Center(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            EmptySection(
                              title: 'Nessuna elemento presente',
                              description:
                                  'Le notizie che salverai nei preferiti verranno visualizzate qui',
                              icon: Icons.favorite,
                              darkMode: darkMode,
                            ),
                          ],
                        ))
                      : Padding(
                          padding: const EdgeInsets.only(
                              top: 5, left: 1, right: 1, bottom: 0),
                          child: Scrollbar(
                              controller: listviewController,
                              /*thickness: widget.searchText.isNotEmpty
                          ? 0
                          : 8,*/ //hide scrollbar wrong if something is hidden is ok to hide them
                              child: MediaQuery.of(context).size.width <
                                      MediaQuery.of(context).size.height
                                  ? ListView.builder(
                                      controller: listviewController,
                                      itemCount: favouritesList.items.length,
                                      itemBuilder:
                                          (BuildContext context, index) {
                                        final item =
                                            favouritesList.items[index];

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
                                      itemCount: favouritesList.items.length,
                                      itemBuilder:
                                          (BuildContext context, index) {
                                        final item =
                                            favouritesList.items[index];

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
                                              crossAxisCount:
                                                  MediaQuery.of(context)
                                                              .size
                                                              .width >
                                                          800
                                                      ? MediaQuery.of(context)
                                                                  .size
                                                                  .width >
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
                                                  ? MediaQuery.of(context)
                                                                  .size
                                                                  .width /
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
                            description: 'Caricamento in corso',
                            icon: Icons.query_stats,
                            darkMode: darkMode,
                          ),
                        ],
                      ),
                    ),
            ])));
  }
}
