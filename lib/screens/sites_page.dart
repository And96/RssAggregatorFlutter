import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/screens/recommended_categories_page.dart';
import 'package:rss_aggregator_flutter/screens/site_url_page.dart';
import 'package:flutter/services.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/site_logo.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
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

  //Search indicator
  bool isOnSearch = false;

  //Controller
  TextEditingController searchController = TextEditingController();

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
    searchController.dispose();
    super.dispose();
  }

  late final AnimationController _refreshIconController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  Timer? _timerOpacityAnimation;
  setOpacityAnimation() {
    if (mounted) {
      _timerOpacityAnimation = Timer(const Duration(milliseconds: 1000), () {
        setState(() {
          opacityAnimation = opacityAnimation <= 0.01 ? 1.0 : 0.01;
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
              _awaitEditSite(context, site);
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
              sitesList
                  .setCategory(site.siteLink, selected.value)
                  .then((value) => setState(() {}));
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
          onTap: () async {
            await sitesList.delete(site.siteLink).then((value) => setState(() {
                  Navigator.pop(context);
                  const snackBar = SnackBar(
                    duration: Duration(seconds: 1),
                    content: Text('Deleted'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }));
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

  String sort = "category";

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await sitesList.load(sort);
      await categoriesList.load();
    } catch (err) {
      //print('Caught error: $err');
    }
    setState(() {
      isLoading = false;
    });
  }

  void _awaitRecommendedSite(BuildContext context) async {
    try {
      // start the SecondScreen and wait for it to finish with a result
      // final resultTextInput =
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RecommendedCategoriesPage(),
          ));

      loadData();
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  void _awaitEditSite(BuildContext context, Site? siteUpdated) async {
    try {
      String siteLink = '';
      String category = '';
      String siteName = '';
      if (siteUpdated != null) {
        siteLink = siteUpdated.siteLink;
        category = siteUpdated.category;
        siteName = siteUpdated.siteName;
      }

      // start the SecondScreen and wait for it to finish with a result
      final resultTextInput = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiteUrlPage(textInput: siteLink),
          ));

      // after the SecondScreen result comes back update the Text widget with it
      if (resultTextInput != null) {
        setState(() {
          isLoading = true;
        });

        await sitesList.delete(siteLink);
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
              true,
              category,
              siteName);
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

  _showNewDialog(BuildContext context) async {
    var dialog = SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Options',
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
        ListTile(
            minLeadingWidth: 30,
            leading: const Icon(Icons.add_link_outlined),
            title: const Text('Add new site'),
            isThreeLine: true,
            subtitle: const Text(
              'Inserisci indirizzo manualmente',
            ),
            onTap: (() =>
                {Navigator.pop(context), _awaitEditSite(context, null)})),
        ListTile(
            minLeadingWidth: 30,
            leading: const Icon(Icons.article_outlined),
            title: const Text('Add site list'),
            isThreeLine: true,
            subtitle: const Text(
              'Add multiple sites or import from OPML',
            ),
            onTap: (() =>
                {Navigator.pop(context), _awaitEditSite(context, null)})),
        ListTile(
            minLeadingWidth: 30,
            leading: const Icon(Icons.auto_graph),
            title: const Text('Recommended sites'),
            isThreeLine: true,
            subtitle: const Text(
              'Choose from most popular website',
            ),
            onTap: (() =>
                {Navigator.pop(context), _awaitRecommendedSite(context)})),
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
    return Scaffold(
      appBar: !isOnSearch
          ? AppBar(
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
                          angle: _refreshIconController.value * 3 * 3.1415,
                          child: child,
                        );
                      },
                      child: const Icon(Icons.autorenew),
                    ),
                    onPressed: () => {},
                  ),
                if (sitesList.items.isNotEmpty && !isLoading)
                  IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () {
                        sleep(const Duration(milliseconds: 200));
                        setState(() {
                          isOnSearch = isOnSearch ? false : true;
                          searchController.text = '';
                        });
                      }),
                if (sitesList.items.isNotEmpty && !isLoading)
                  IconButton(
                      icon: Icon(
                          sort == "name" ? Icons.sort : Icons.sort_by_alpha),
                      tooltip:
                          'Sort by ${sort == "name" ? "category" : "name"}',
                      onPressed: () async => {
                            sort = sort == "name" ? "category" : "name",
                            loadData().then((value) => setState(() {}))
                          }),
                if (sitesList.items.isNotEmpty && !isLoading)
                  IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                      onPressed: () => showDeleteDialog(context, "*")),
              ],
            )
          : AppBar(
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
                      sitesList = sitesList;
                      FocusManager.instance.primaryFocus?.unfocus();
                      WidgetsBinding.instance.focusManager.primaryFocus
                          ?.unfocus();
                    });
                  },
                ), //
              ],
            ),
      body: Stack(
        children: [
          isLoading == false
              ? Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: ListView.separated(
                      itemCount: sitesList.items.length,
                      separatorBuilder: (context, index) {
                        return Visibility(
                            visible: searchController.text.isEmpty ||
                                Utility().compareSearch([
                                  sitesList.items[index].siteName,
                                  sitesList.items[index].siteLink,
                                ], searchController.text),
                            child: const Divider());
                      },
                      itemBuilder: (BuildContext context, index) {
                        final item = sitesList.items[index];
                        return Visibility(
                          visible: searchController.text.isEmpty ||
                              Utility().compareSearch(
                                  [item.siteLink, item.siteName],
                                  searchController.text),
                          child: InkWell(
                            child: ListTile(
                                minLeadingWidth: 30,
                                leading: SiteLogo(iconUrl: item.iconUrl),
                                title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0),
                                        child: Text(
                                          (item.siteName.toString()),
                                          /*style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: darkMode
                                              ? ThemeColor.light1
                                              : ThemeColor.dark1,
                                        ),*/
                                        ),
                                      ),
                                      if (item.category.trim() != "")
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0),
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                top: 0,
                                                left: 7,
                                                right: 7,
                                                bottom: 0),
                                            decoration: BoxDecoration(
                                                color: Color(categoriesList
                                                    .getColor(item.category)),
                                                border: Border.all(
                                                  color: Color(categoriesList
                                                      .getColor(item.category)),
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(50))),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  (item.category.toString()),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ]),
                                /* trailing: const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.more_vert),
                              ),*/
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
                                            /*style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: darkMode
                                                ? ThemeColor.light3
                                                : ThemeColor.dark3,
                                          ),*/
                                          ),
                                        ),
                                      ],
                                    ))),
                          ),
                        );
                      }))
              : Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      /*AnimatedOpacity(
                        opacity: isLoading ? opacityAnimation : 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: */
                      EmptySection(
                        title: 'Searching...',
                        description: sitesList.itemLoading,
                        icon: Icons.manage_search,
                        darkMode: darkMode,
                      ),
                      /*  ),*/
                      Container(
                        width: 175,
                        height: 3,
                        margin: const EdgeInsets.only(top: 22),
                        child: const LinearProgressIndicator(
                          backgroundColor: Colors.blueGrey,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black54),
                        ),
                      )
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
                _showNewDialog(context);
              },
            ),
    );
  }
}
