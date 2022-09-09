import 'package:favicon/favicon.dart' hide Icon;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MyApp());
}

class Elemento {
  var link = "";
  var title = "";
  DateTime? pubDate;
  //Image? icon;
  var iconUrl = "";
  var host = "";
  Elemento(
      {required this.link,
      required this.title,
      required this.pubDate,
      required this.iconUrl,
      required this.host});
}

DateTime tryParse(String formattedString) {
  try {
    return DateTime.parse(formattedString).toLocal();
  } on FormatException {
    return DateTime.parse(DateTime.now().toLocal().toString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  late List<Elemento> list = [];
  late List<Elemento> listUpdated = [];

  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  loadDataUrl(String url) async {
    try {
      final response = await get(Uri.parse(url));
      var channel = RssFeed.parse(response.body);
      String hostname = Uri.parse(url.toString()).host.toString();

      /* img dont load */
      /*List<String>? suffixesIcon;
      suffixesIcon?.add("png");*/
      var iconUrls = await Favicon.getAll(url /*, suffixes: suffixesIcon*/);
      var iconUrl = "";
      if (iconUrls.isNotEmpty) {
        iconUrl = iconUrls[0].url;
      }

      //Image img = ImageIcon(Icons.refresh).image;

/*
      if (iconUrls.isNotEmpty) {
        Image img = Image.network(
          iconUrls[0].url.toString(),
          height: 16,
          width: 16,
          alignment: Alignment.center,
        );
      }
*/
      channel.items?.forEach((element) {
        var p1 = Elemento(
            title: element.title.toString(),
            link: element.link.toString(),
            iconUrl: iconUrl,
            pubDate: element.pubDate,
            host: hostname);
        listUpdated.add(p1);
      });
    } on Exception catch (_) {}
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      listUpdated = [];

      await loadDataUrl("https://hano.it/feed");
      await loadDataUrl("https://www.open.online/rss");
      await loadDataUrl("https://myvalley.it/feed");

      setState(() {
        list = listUpdated;
        isLoading = false;
      });
    } catch (err) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.newspaper),
        title: const Text('Rss Feed Aggregator'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => loadData(),
          ), //IconButton
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Setting',
            onPressed: () {},
          ), //IconButton
        ], //<Widg
      ),
      body: Stack(
        children: [
          isLoading == false
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Scrollbar(
                      child: ListView.separated(
                          itemCount: list.length,
                          /*itemCount: rss.items!.length,*/
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, index) {
                            /*final item = rss.items![index];*/
                            final item = list[index];
                            return InkWell(
                              onTap: () async {
                                _launchInBrowser(
                                    Uri.parse((item.link.toString())));
                              },
                              child: ListTile(
                                  minLeadingWidth: 30,
                                  /*leading: const Icon(Icons.link),*/
                                  leading: /*Image(image: item.icon!.image),*/
                                      /*image: item.icon!.image,*/

                                      SizedBox(
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
                                      (item.host.toString()),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            Color.fromARGB(255, 120, 120, 120),
                                      ),
                                    ),
                                  ),
                                  isThreeLine: true,
                                  subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(
                                            child: Text(
                                              item.title.toString(),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                                color: Color.fromARGB(
                                                    255, 10, 10, 10),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Row(
                                              children: [
                                                Text(
                                                  (DateFormat(
                                                          'dd/MM/yyyy hh:mm')
                                                      .format(tryParse(item
                                                              .pubDate
                                                              .toString())
                                                          .toLocal())),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color.fromARGB(
                                                        255, 120, 120, 120),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ))),
                            );
                          })),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ],
      ),
    );
  }
}
