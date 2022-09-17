import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/site_list.dart';
// ignore: depend_on_referenced_packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rss_aggregator_flutter/screens/add_site.dart';

class EditSites extends StatefulWidget {
  const EditSites({Key? key}) : super(key: key);

  @override
  State<EditSites> createState() => _EditSitesState();
}

class _EditSitesState extends State<EditSites> {
  bool isLoading = false;
  late SiteList siteList = SiteList();

  @override
  void initState() {
    loadData();
    super.initState();
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
      content: const Text("Confirm delete?"),
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

  void _awaitReturnValueFromSecondScreen(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddSite(),
        ));

    // after the SecondScreen result comes back update the Text widget with it

    setState(() {
      isLoading = true;
    });

    if (result != null) {
      if (result.toString().contains("<") ||
          result.toString().contains(";") ||
          result.toString().contains(" ")) {
        List<String> listUrl = getUrlsFromText(result);
        if (listUrl.length > 1) {
          bool advancedSearch = !result.toString().contains("opml");
          for (String item in listUrl) {
            await siteList.addSite(item, advancedSearch);
          }
          setState(() {
            isLoading = false;
          });
          return;
        }
      }
      await siteList.addSite(
          result.toString().trim().replaceAll("\n", ""), true);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: siteList.items.isEmpty
            ? const Text('Sites')
            : Text('Sites (${siteList.items.length})'),
        actions: <Widget>[
          /* IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add feed',
              onPressed: () => _awaitReturnValueFromSecondScreen(context)
              ),*/
          /*IconButton(
            icon: const Icon(Icons.model_training_outlined),
            tooltip: 'Default',
            onPressed: () async => {
              [await siteList.addDefaultSites(), setState(() {})]
            },
          ),*/

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
                              /*onTap: () async {
                                _launchInBrowser(
                                    Uri.parse((item.link.toString())));
                              },*/
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
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            Color.fromARGB(255, 120, 120, 120),
                                      ),
                                    ),
                                  ),
                                  isThreeLine: false,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Default',
                                    onPressed: () => showDeleteAlertDialog(
                                        context, item.siteLink),
                                  ),
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
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                                color: Color.fromARGB(
                                                    255, 10, 10, 10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))),
                            );
                          })),
                )
              : Center(
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
                _awaitReturnValueFromSecondScreen(context);
              },
            ),
    );
  }
}
