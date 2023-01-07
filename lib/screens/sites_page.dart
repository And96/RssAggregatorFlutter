import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/screens/news_page.dart';
import 'package:rss_aggregator_flutter/screens/recommended_categories_page.dart';
import 'package:rss_aggregator_flutter/screens/site_url_page.dart';
import 'package:flutter/services.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/site_logo_big.dart';
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
  late SitesList sitesList = SitesList();
  late CategoriesList categoriesList = CategoriesList();
  bool darkMode = false;
  double opacityAnimation = 1.0;

  //Search indicator
  bool isOnSearch = false;
  bool isOnAdded = false;

  String sort = "category";
  bool hideFab = false;

  //Controller
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
      await loadData();
      if (sitesList.items.isEmpty) {
        await Future.delayed(
            const Duration(milliseconds: 500), () => _showNewDialog(context));
      }
    });
  }

  @override
  dispose() {
    _refreshIconController.stop(canceled: true);
    _refreshIconController.dispose();
    searchController.dispose();
    super.dispose();
  }

  late final AnimationController _refreshIconController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

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
          onTap: () async {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NewsPage(
                      siteFilter: site.siteID,
                      categoryFilter: '*',
                    )));
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
              if (selected.value != site.category) {
                SnackBar snackBar = SnackBar(
                  duration: const Duration(milliseconds: 1500),
                  content: Text('Changed category to ${selected.value}'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.pop(context);
                sitesList
                    .setCategory(site.siteLink, selected.value)
                    .then((value) => setState(() {}));
              }
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
            await sitesList
                .delete(site.siteLink, site.siteName, site.siteID)
                .then((value) => setState(() {
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

  showDeleteAllDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        setState(() {
          sitesList.delete("*", "", 0);
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
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RecommendedCategoriesPage(),
          ));
      await loadData();
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  void export() async {
    try {
      String text = "";
      for (Site site in sitesList.items) {
        text += """,{
         "siteName": "${site.siteName}",
         "siteLink": "${site.siteLink}",
         "iconUrl": "${site.iconUrl}"
         }""";
      }

      // start the SecondScreen and wait for it to finish with a result
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiteUrlPage(textInput: text),
          ));
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  Future<List<String>> _awaitEditSite(
      BuildContext context, Site? siteUpdated) async {
    List<String> siteAgg = [];
    try {
      String siteLink = '';
      String category = '';
      String siteName = '';
      int siteID = 0;
      if (siteUpdated != null) {
        siteLink = siteUpdated.siteLink;
        category = siteUpdated.category;
        siteName = siteUpdated.siteName;
        siteID = siteUpdated.siteID;
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
          isOnAdded = false;
          isOnSearch = false;
          searchController.text = '';
        });

        setState(() {
          isLoading = true;
        });

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
              siteAgg.addAll(await sitesList.add(item, advancedSearch));
            }
          }
        } else {
          setState(() {
            progressLoading = 0.90;
          });
          siteAgg.addAll(await sitesList.add(
              inputText.toString().replaceAll(" ", "").replaceAll("\n", ""),
              true,
              category,
              siteName,
              siteID));
        }
        setState(() {
          progressLoading = 0.99;
        });
        setState(() {
          isLoading = false;
        });

        if (siteAgg.isNotEmpty) {
          sleep(const Duration(milliseconds: 300));
          setState(() {
            sitesList.load('name').then((value) => {
                  if (sitesList.items.length > 1)
                    {
                      isOnSearch = false,
                      isOnAdded = true,
                      searchController.text = siteAgg.join(';')
                    }
                });
          });
        }
      }
    } catch (err) {
      //print('Caught error: $err');
    }
    return siteAgg;
  }

  _showNewDialog(BuildContext context) async {
    hideFab = true;
    setState(() {});
    var dialog = SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Aggiungi siti da seguire',
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
            title: const Text('Inserisci link'),
            isThreeLine: true,
            subtitle: const Text(
              'Inserisci indirizzo link del sito da aggiungere',
            ),
            onTap: (() => {
                  Navigator.pop(context),
                  _awaitEditSite(context, null).then((siteAgg) => {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 2),
                            content: Text(
                                'Search completed. ${siteAgg.length} link found'),
                          ),
                        ),
                      })
                })),
        ListTile(
            minLeadingWidth: 30,
            leading: const Icon(Icons.auto_graph),
            title: const Text('Siti popolati'),
            isThreeLine: true,
            subtitle: const Text(
              'Scegli tra i siti piu famosi da seguire',
            ),
            onTap: (() =>
                {Navigator.pop(context), _awaitRecommendedSite(context)})),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        }).then((value) => setState(() {
          hideFab = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !isOnSearch && !isOnAdded
          ? AppBar(
              title: isLoading
                  ? const Text("Searching")
                  : sitesList.items.isEmpty
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
                          isOnAdded = false;
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
                      icon: const Icon(Icons.upload_file),
                      tooltip: 'Export',
                      onPressed: () => export()),
                if (sitesList.items.isNotEmpty && !isLoading)
                  IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                      onPressed: () => showDeleteAllDialog(context)),
              ],
            )
          : isOnSearch
              ? AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                    onPressed: () {
                      setState(() {
                        sleep(const Duration(milliseconds: 200));
                        isOnSearch = false;
                        isOnAdded = false;
                        searchController.text = '';
                        loadData();
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
                )
              : AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                    onPressed: () {
                      setState(() {
                        sleep(const Duration(milliseconds: 200));
                        isOnSearch = false;
                        isOnAdded = false;
                        searchController.text = '';
                        loadData();
                      });
                    },
                  ), //
                  title: const Text('Sites Added'),
                ),
      body: Stack(
        children: [
          isLoading == false
              ? Container(
                  color: darkMode
                      ? ThemeColor.dark1.withAlpha(120)
                      : ThemeColor.light1,
                  padding: const EdgeInsets.only(top: 9),
                  child: ListView.builder(
                      itemCount: sitesList.items.length,
                      /*separatorBuilder: (context, index) {
                        return Visibility(
                            visible: searchController.text.isEmpty ||
                                (isOnAdded
                                    ? Utility().compareSearch([
                                        sitesList.items[index].siteLink,
                                      ], searchController.text, true)
                                    : Utility().compareSearch([
                                        sitesList.items[index].siteName,
                                        sitesList.items[index].siteLink,
                                      ], searchController.text, false)),
                            child: const Divider());
                      },*/
                      itemBuilder: (BuildContext context, index) {
                        final item = sitesList.items[index];
                        return Visibility(
                            visible: searchController.text.isEmpty ||
                                (isOnAdded
                                    ? Utility().compareSearch([
                                        sitesList.items[index].siteLink,
                                      ], searchController.text, true)
                                    : Utility().compareSearch([
                                        sitesList.items[index].siteName,
                                        sitesList.items[index].siteLink,
                                      ], searchController.text, false)),
                            child: Card(
                              margin: const EdgeInsets.only(
                                  left: 12, right: 12, top: 7, bottom: 7),
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Colors.transparent,
                                  width: 0.0,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 0,
                              color:
                                  darkMode ? Colors.transparent : Colors.white,
                              shadowColor:
                                  darkMode ? Colors.black : Colors.white,
                              child: InkWell(
                                child: ListTile(
                                    contentPadding: const EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        top: 10,
                                        bottom: 10),
                                    minLeadingWidth: 50,
                                    leading: SiteLogoBig(
                                      iconUrl: item.iconUrl,
                                      color: categoriesList
                                          .getColorSync(item.category),
                                    ),
                                    title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 0),
                                              child: Text(
                                                (item.siteName.toString()),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: darkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (item.category.trim() != "")
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 0),
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    top: 1,
                                                    left: 8,
                                                    right: 8,
                                                    bottom: 1),
                                                decoration: BoxDecoration(
                                                    color: categoriesList
                                                        .getColorSync(
                                                            item.category),
                                                    border: Border.all(
                                                      color: categoriesList
                                                          .getColorSync(
                                                              item.category),
                                                    ),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                50))),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      (item.category
                                                          .toString()),
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
                                    /*trailing: const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.warning,
                                    color: Colors.red,
                                  ),
                                ),*/
                                    isThreeLine: item.siteLink.length > 40
                                        ? true
                                        : false,
                                    onTap: () {
                                      showOptionDialog(context, item);
                                    },
                                    subtitle: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, right: 25),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            SizedBox(
                                              child: Text(
                                                item.siteLink.toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            /*Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Chip(
                                            backgroundColor: darkMode
                                                ? ThemeColor.dark2
                                                : ThemeColor.light1,
                                            label: const Text(
                                              "Ultimo aggiornamento 01/01/2022",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            avatar: const Icon(
                                              Icons.warning,
                                              color: Colors.red,
                                              size: 15,
                                            ),
                                          ),
                                        ),*/
                                          ],
                                        ))),
                              ),
                            ));
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
      floatingActionButton: isLoading || hideFab
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
