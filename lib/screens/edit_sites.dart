import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/site_list.dart';
// ignore: depend_on_referenced_packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rss_aggregator_flutter/screens/add_site.dart';
import 'package:flutter/services.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
//import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';

class EditSites extends StatefulWidget {
  const EditSites({Key? key}) : super(key: key);

  @override
  State<EditSites> createState() => _EditSitesState();
}

class _EditSitesState extends State<EditSites>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late SiteList siteList = SiteList(updateItemLoading: _updateItemLoading);

//da implementare anche qua se va nel main
  bool darkMode = false;

  @override
  void initState() {
    loadData();
    ThemeColor.isDarkMode()
        .then((value) => {darkMode = value, super.initState()});
  }

  // Pass this method to the child page.
  void _updateItemLoading(String itemLoading) {
    setState(() {});
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  void showOptionDialog(BuildContext context, String url) {
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
            tooltip: 'Refresh',
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
          leading: const Icon(Icons.edit),
          title: const Text('Edit site'),
          onTap: () {
            Navigator.pop(context);
            setState(() {
              _awaitReturnValueFromSecondScreen(context, url);
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.open_in_new),
          title: const Text('Open site'),
          onTap: () async {
            _launchInBrowser(Uri.parse((Site.getHostName(url, true))));
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.copy),
          title: const Text('Copy link'),
          onTap: () {
            Clipboard.setData(ClipboardData(text: url));
            Navigator.pop(context);
            const snackBar = SnackBar(
              duration: Duration(seconds: 1),
              content: Text('Link copied to clipboard'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share link'),
          onTap: () {
            Share.share(url);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete site'),
          onTap: () {
            setState(() {
              siteList.deleteSite(url);
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

  showDeleteAlertDialog(BuildContext context, String url) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        setState(() {
          siteList.deleteSite(url);
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

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: const Text("Delete all sites?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
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
      await siteList.load();
    } catch (err) {
      //print('Caught error: $err');
    }
    setState(() {
      isLoading = false;
    });
  }

  List<String> getUrlsFromText(String text) {
    try {
      RegExp exp =
          RegExp(r'(?:(?:https?|http):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
      Iterable<RegExpMatch> matches = exp.allMatches(text);
      List<String> listUrl = [];
      for (var match in matches) {
        if (match.toString().length > 6) {
          listUrl.add(text.substring(match.start, match.end));
        }
      }
      return listUrl;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }

  void _awaitReturnValueFromSecondScreen(
      BuildContext context, String urlInput) async {
    try {
      // start the SecondScreen and wait for it to finish with a result
      final resultTextInput = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddSite(textInput: urlInput),
          ));

      // after the SecondScreen result comes back update the Text widget with it

      setState(() {
        isLoading = true;
      });

      siteList.deleteSite(urlInput);
      String inputText = resultTextInput.toString().replaceAll("amp;", "");
      if (inputText.toString().contains("<") ||
          inputText.toString().contains(";") ||
          inputText.toString().contains(" ")) {
        List<String> listUrl = getUrlsFromText(inputText);
        if (listUrl.isNotEmpty) {
          bool advancedSearch = !inputText.toString().contains("opml");
          for (String item in listUrl) {
            await siteList.addSite(item, advancedSearch);
          }

          setState(() {
            isLoading = false;
          });
        }
      } else {
        await siteList.addSite(
            inputText.toString().replaceAll(" ", "").replaceAll("\n", ""),
            true);
      }

      setState(() {
        isLoading = false;
      });

      const snackBar = SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Search completed'),
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  late final AnimationController _refreshIconController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: siteList.items.isEmpty
            ? const Text('Sites')
            : Text('Sites (${siteList.items.length})'),
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
          if (siteList.items.isNotEmpty && !isLoading)
            IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
                onPressed: () => showDeleteAlertDialog(context, "*")),
        ],
      ),
      body: Stack(
        children: [
          isLoading == false
              ? Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Scrollbar(
                      child: ListView.separated(
                          itemCount: siteList.items.length,
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, index) {
                            final item = siteList.items[index];
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
                                        fontSize: 14,
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
                                    showOptionDialog(context, item.siteLink);
                                  },
                                  /*trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Default',
                                    onPressed: () => showDeleteAlertDialog(
                                        context, item.siteLink),
                                  ),*/
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
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                                color: darkMode
                                                    ? const Color.fromARGB(
                                                        255, 150, 150, 150)
                                                    : const Color.fromARGB(
                                                        255, 120, 120, 120),
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
                      EmptySection(
                        title: 'Ricerca in corso',
                        description: siteList.itemLoading,
                        icon: Icons.manage_search,
                        darkMode: darkMode,
                      ),
                    ],
                  ), /*Center(
                  child: SizedBox(
                    height: 175,
                    width: 275,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text('Loading'),
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                        Text(siteList.itemLoading),  
                      ],  
                    ),  
                  ),  */
                ),
        ],
      ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add Site'),
              onPressed: () {
                _awaitReturnValueFromSecondScreen(context, "");
              },
            ),
    );
  }
}
