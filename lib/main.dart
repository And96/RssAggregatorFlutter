import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class Elemento {
  var link = "";
  var title = "";
  DateTime? pubDate;
  var icon = "";
  var host = "";
  Elemento(
      {required this.link,
      required this.title,
      required this.pubDate,
      required this.icon,
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

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<Elemento> listUpdated = [];
      var p1 = Elemento(
          title: "titolo",
          link: "https://www.open.online/rss",
          icon: "icona",
          pubDate: DateTime.parse('2020-01-02 03:04:05'),
          host: "https://www.open.online/rss");
      listUpdated.add(p1);
      listUpdated.add(p1);

      const api = 'https://www.open.online/rss';
      final response = await get(Uri.parse(api));
      var channel = RssFeed.parse(response.body);

      channel.items?.forEach((element) {
        var p1 = Elemento(
            title: element.title.toString(),
            link: element.link.toString(),
            icon: "",
            pubDate: element.pubDate,
            host: Uri.parse(element.link.toString()).host.toString());
        listUpdated.add(p1);
      });

      /*channel.items?.add(p1);*/

      setState(() {
        /*rss = channel;*/
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
                                  leading: const Icon(Icons.rss_feed),
                                  title: Padding(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Text(
                                      (item.host.toString()),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            Color.fromARGB(255, 110, 110, 110),
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
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                                color: Color.fromARGB(
                                                    255, 20, 20, 20),
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
                                                          .toString()))),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color.fromARGB(
                                                        255, 110, 110, 110),
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
