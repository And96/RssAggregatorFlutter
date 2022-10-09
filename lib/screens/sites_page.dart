import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
// ignore: depend_on_referenced_packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/screens/site_url_page.dart';
import 'package:flutter/services.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';

class SitesPage extends StatefulWidget {
  const SitesPage({Key? key}) : super(key: key);

  @override
  State<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  double progressLoading = 0;
  late SitesList sitesList = SitesList(updateItemLoading: _updateItemLoading);
  late CategoriesList categoriesList = CategoriesList();
  bool darkMode = false;
  double opacityAnimation = 1.0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setOpacityAnimation();
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
      await loadData();
    });
    super.initState();
  }

  @override
  dispose() {
    _timerOpacityAnimation?.cancel();
    _refreshIconController.stop(canceled: true);
    _refreshIconController.dispose();
    super.dispose();
  }

  late final AnimationController _refreshIconController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  Timer? _timerOpacityAnimation;
  setOpacityAnimation() {
    if (mounted) {
      _timerOpacityAnimation = Timer(const Duration(milliseconds: 800), () {
        setState(() {
          opacityAnimation = opacityAnimation <= 0.5 ? 1.0 : 0.5;
          setOpacityAnimation();
        });
      });
    }
  }

  void _updateItemLoading(String itemLoading) {
    setState(() {});
  }

  void showOptionDialog(BuildContext context, Site site) {
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
          leading: const Icon(Icons.newspaper),
          title: const Text('Open news'),
          onTap: () {
            Navigator.pop(context, site.siteName);
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit link'),
          onTap: () {
            Navigator.pop(context);
            setState(() {
              _awaitEditSite(context, site.siteLink);
            });
          },
        ),
        SmartSelect<String>.single(
            title: 'Category',
            selectedValue: site.category,
            modalType: S2ModalType.fullPage,
            choiceItems: S2Choice.listFrom<String, String>(
              source: categoriesList.toList(),
              value: (index, item) => item,
              title: (index, item) => item,
            ),
            onChange: (selected) async {
              SnackBar snackBar = SnackBar(
                duration: const Duration(milliseconds: 1500),
                content: Text('Changed category to ${selected.value}'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Navigator.pop(context);
              setState(() {
                sitesList.setCategory(site.siteName, selected.value);
              });
            },
            tileBuilder: (context, state) {
              return S2Tile.fromState(
                state,
                isTwoLine: false,
                leading: const Icon(Icons.sell),
                trailing: const Icon(
                  Icons.sell,
                  size: 0,
                ),
                title: const Text("Category"),
              );
            }),
        ListTile(
          leading: const Icon(Icons.open_in_new),
          title: const Text('Open site'),
          onTap: () async {
            Utility().launchInBrowser(
                Uri.parse((Site.getHostName(site.siteLink, true))));
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.copy),
          title: const Text('Copy link'),
          onTap: () {
            Clipboard.setData(ClipboardData(text: site.siteLink));
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
            Share.share(site.siteLink);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete site'),
          onTap: () {
            setState(() {
              sitesList.delete(site.siteLink);
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
          sitesList.delete(url);
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
      content: const Text("Delete all sites?"),
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
      await sitesList.load();
      await categoriesList.load();
    } catch (err) {
      //print('Caught error: $err');
    }
    setState(() {
      isLoading = false;
    });
  }

  void _awaitEditSite(BuildContext context, String urlInput) async {
    try {
      // start the SecondScreen and wait for it to finish with a result
      final resultTextInput = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiteUrlPage(textInput: urlInput),
          ));

      // after the SecondScreen result comes back update the Text widget with it
      if (resultTextInput != null) {
        setState(() {
          isLoading = true;
        });

        sitesList.delete(urlInput);
        String inputText = resultTextInput.toString().replaceAll("amp;", "");
        if (Utility().isMultipleLink(inputText)) {
          List<String> listUrl = Utility().getUrlsFromText(inputText);
          if (listUrl.isNotEmpty) {
            bool advancedSearch = !inputText.toString().contains("opml");
            for (var i = 0; i < listUrl.length; i++) {
              String item = listUrl[i];
              setState(() {
                progressLoading = (i + 1) / listUrl.length;
              });
              await sitesList.add(item, advancedSearch);
            }
          }
        } else {
          setState(() {
            progressLoading = 0.90;
          });
          await sitesList.add(
              inputText.toString().replaceAll(" ", "").replaceAll("\n", ""),
              true);
        }
        setState(() {
          progressLoading = 0.99;
        });
        setState(() {
          isLoading = false;
        });
        const snackBar = SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Search completed'),
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: sitesList.items.isEmpty
            ? const Text('Sites')
            : Text('Sites (${sitesList.items.length})'),
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
          if (sitesList.items.isNotEmpty && !isLoading)
            IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
                onPressed: () => showDeleteDialog(context, "*")),
        ],
      ),
      body: Stack(
        children: [
          isLoading == false
              ? Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Scrollbar(
                      child: ListView.separated(
                          itemCount: sitesList.items.length,
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, index) {
                            final item = sitesList.items[index];
                            return InkWell(
                              child: ListTile(
                                  minLeadingWidth: 30,
                                  leading: SizedBox(
                                    height: double.infinity,
                                    width: 17,
                                    child: item.iconUrl.toString().trim() == ""
                                        ? const Icon(Icons.link)
                                        : CachedNetworkImage(
                                            imageUrl: item.iconUrl,
                                            placeholder: (context, url) =>
                                                const Icon(Icons.link),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.link),
                                          ),
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Text(
                                      (item.siteName.toString()),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: darkMode
                                            ? const Color.fromARGB(
                                                255, 210, 210, 210)
                                            : const Color.fromARGB(
                                                255, 5, 5, 5),
                                      ),
                                    ),
                                  ),
                                  isThreeLine: false,
                                  onTap: () {
                                    showOptionDialog(context, item);
                                  },
                                  subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(
                                            child: Text(
                                              item.siteLink.toString(),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: darkMode
                                                    ? const Color.fromARGB(
                                                        255, 150, 150, 150)
                                                    : const Color.fromARGB(
                                                        255, 80, 80, 80),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))),
                            );
                          })),
                )
              : Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedOpacity(
                        opacity: isLoading ? opacityAnimation : 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: EmptySection(
                          title: 'Searching...',
                          description: sitesList.itemLoading,
                          icon: Icons.manage_search,
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
                          animationDuration: 12000,
                          percent: progressLoading,
                          barRadius: const Radius.circular(16),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add Site'),
              onPressed: () {
                _awaitEditSite(context, "");
              },
            ),
    );
  }
}
