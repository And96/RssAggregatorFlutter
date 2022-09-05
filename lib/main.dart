import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
/*import 'package:posts/screens/view_rss_feed.dart';*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  late RssFeed rss = RssFeed();

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

      // This is an open REST API endpoint for testing purposes
      const api = 'https://www.open.online/rss';
      final response = await get(Uri.parse(api));
      var channel = RssFeed.parse(response.body);
      setState(() {
        rss = channel;
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
              ? Scrollbar(
                  child: ListView.separated(
                      itemCount: rss.items!.length,
                      separatorBuilder: (context, index) {
                        // <-- SEE HERE
                        return const Divider();
                      },
                      itemBuilder: (BuildContext context, index) {
                        final item = rss.items![index];

                        return InkWell(
                            onTap: () async {
                              _launchInBrowser(
                                  Uri.parse((item.link.toString())));
                            },
                            child: ListTile(
                                /*leading: Image(
                          image: CachedNetworkImageProvider(
                              item.media!.contents![0].url.toString())),*/
                                leading: const Icon(Icons.rss_feed),
                                title: Text(Uri.parse(item.link.toString())
                                    .host
                                    .toString()),
                                isThreeLine: true,
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SizedBox(
                                      child: Text(
                                        item.title.toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(DateFormat('dd/MM/yyyy hh:mm')
                                            .format(DateTime.parse(
                                                item.pubDate.toString()))),
                                      ],
                                    ),
                                  ],
                                )));
                      }))
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ],
      ),
    );
  }
}
