import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/readlater_list.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
// ignore: depend_on_referenced_packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:flutter/services.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
/*import 'dart:async';*/

class ReadlaterPage extends StatefulWidget {
  const ReadlaterPage({Key? key}) : super(key: key);

  @override
  State<ReadlaterPage> createState() => _ReadlaterPageState();
}

class _ReadlaterPageState extends State<ReadlaterPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  double progressLoading = 0;
  late ReadlaterList readlaterList = ReadlaterList();
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
              readlaterList.delete(item.link);
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
          readlaterList.delete(url);
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
      await readlaterList.load();
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
          title: readlaterList.items.isEmpty
              ? const Text('Read Later')
              : Text('Read Later (${readlaterList.items.length})'),
          actions: <Widget>[
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
            if (readlaterList.items.isNotEmpty && !isLoading)
              IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete',
                  onPressed: () => showDeleteDialog(context, "*")),
          ],
        ),
        body: Stack(
          children: [
            isLoading == false
                ? readlaterList.items.isEmpty
                    ? Center(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          EmptySection(
                            title: 'Nessuna notizia presente',
                            description: 'Aggiungi i tuoi siti da seguire',
                            icon: Icons.watch_later,
                            darkMode: darkMode,
                          ),
                        ],
                      ))
                    : Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Scrollbar(
                            child: ListView.separated(
                                itemCount: readlaterList.items.length,
                                separatorBuilder: (context, index) {
                                  return const Divider();
                                },
                                itemBuilder: (BuildContext context, index) {
                                  final item = readlaterList.items[index];

                                  return InkWell(
                                      onTap: () =>
                                          showOptionDialog(context, item),
                                      child: ListTile(
                                        minLeadingWidth: 30,
                                        leading: SizedBox(
                                          height: double.infinity,
                                          width: 17,
                                          child: item.iconUrl
                                                      .toString()
                                                      .trim() ==
                                                  ""
                                              ? const Icon(Icons.link)
                                              : CachedNetworkImage(
                                                  imageUrl: item.iconUrl,
                                                  placeholder: (context, url) =>
                                                      const Icon(Icons.link),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.link),
                                                ),
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
                                                            : ThemeColor.dark1),
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
                                                                FontWeight
                                                                    .normal,
                                                            color: darkMode
                                                                ? ThemeColor
                                                                    .light3
                                                                : ThemeColor
                                                                    .dark4),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
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
