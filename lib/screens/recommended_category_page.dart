import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/recommended_category_list.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:flutter/services.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
// ignore: depend_on_referenced_packages
/*import 'dart:async';*/

class RecommendedCategoryPage extends StatefulWidget {
  const RecommendedCategoryPage({Key? key}) : super(key: key);

  @override
  State<RecommendedCategoryPage> createState() =>
      _RecommendedCategoryPageState();
}

class _RecommendedCategoryPageState extends State<RecommendedCategoryPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  double progressLoading = 0;
  late RecommendedCategoryList recommendedCategoryList =
      RecommendedCategoryList();
  bool darkMode = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
      await loadData();
    });
    super.initState();
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
              recommendedCategoryList.delete(item.link);
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
          recommendedCategoryList.delete(url);
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
      await recommendedCategoryList.load();
    } catch (err) {
      //print('Caught error: $err');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: recommendedCategoryList.items.isEmpty
              ? const Text('RecommendedCategory')
              : Text(
                  'RecommendedCategory (${recommendedCategoryList.items.length})'),
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
            if (recommendedCategoryList.items.isNotEmpty && !isLoading)
              IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete',
                  onPressed: () => showDeleteDialog(context, "*")),
          ],
        ),
        body: Stack(
          children: [
            isLoading == false
                ? GridView.count(
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this produces 2 rows.
                    crossAxisCount: 2,

                    // Generate 100 wiprimary: false,
                    padding: const EdgeInsets.all(1.5),
                    childAspectRatio: 0.80,
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 1.0,
                    shrinkWrap: true,
                    children: List.generate(100, (index) {
                      return Card(
                        elevation: 2.0,
                        color: Colors.primaries[
                            Random().nextInt(Colors.primaries.length)],
                        child: InkWell(
                          //highlightColor: Colors.white.withAlpha(30),
                          //splashColor: Colors.white.withAlpha(20),
                          child: GridTile(
                            // header section
                            //header: const Icon(Icons.favorite),
                            footer: GridTileBar(
                              backgroundColor: Colors.white.withAlpha(40),
                              title: Text(
                                'Categoria $index',
                                textAlign: TextAlign.center,
                              ),

                              /*trailing: const Icon(
                                Icons.bookmark_outline,
                                //color: Colors.black,
                              ),*/
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 75,
                            ),
                          ),

                          /*Center(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                verticalDirection: VerticalDirection.down,
                                children: <Widget>[
                                  const Icon(Icons.favorite),
                                  Center(
                                    child: Text('Item $index'),
                                  ),
                                ]),
                          ),*/
                          /*onTap: () {
                            _tappedCategoryCell(item.routeName);
                          },*/
                        ),
                      );

                      /*Center(
                        child: Text(
                          'Item $index',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      );*/
                    }),
                  )
                : Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: EmptySection(
                            title: 'Loading',
                            description: '...',
                            icon: Icons.query_stats,
                            darkMode: darkMode,
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ));
  }
}
