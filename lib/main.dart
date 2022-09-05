import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        primarySwatch: Colors.blue,
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

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // This is an open REST API endpoint for testing purposes
      const api = 'https://adeptosdebancada.com/rssfeed?content=articles';
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
        title: const Text('Rss Feed Aggregator'),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () => loadData(),
              child: Row(
                children: const [Icon(Icons.refresh)],
              ))
        ],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          isLoading == false
              ? ListView.builder(
                  itemCount: rss.items!.length,
                  itemBuilder: (BuildContext context, index) {
                    final item = rss.items![index];
                    final feedItems = {
                      'title': item.title,
                      'content': item.content!.value,
                      'creator': item.dc!.creator,
                      'image': item.media!.contents![0].url,
                      'link': item.link,
                      'pubDate': item.pubDate,
                      'author': item.dc!.creator
                    };
                    return InkWell(
                        /* onTap:() => Navigator.pushReplacement(context,
                                     MaterialPageRoute(builder:
                                         (context) => ViewRssScreen(RssFeed: feedItems)
                                     )
                                 ),*/
                        child: ListTile(
                      leading: Image(
                          image: CachedNetworkImageProvider(
                              item.media!.contents![0].url.toString())),
                      title: Text(item.title.toString()),
                      subtitle: Row(
                        children: [
                          Text(DateFormat('dd/MM/yyyy hh:mm')
                              .format(DateTime.parse(item.pubDate.toString()))),
                          const Spacer(),
                          const Icon(Icons.person),
                          Text(item.dc!.creator.toString())
                        ],
                      ),
                    ));
                  })
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ],
      ),
    );
  }
}
