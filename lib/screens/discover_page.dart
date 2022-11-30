import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/site_logo.dart';
import 'package:any_link_preview/any_link_preview.dart' as any_link_preview;
import 'package:metadata_fetch/metadata_fetch.dart' as metadata_fetch;

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key, required this.feedsList}) : super(key: key);

  final FeedsList feedsList;

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  bool darkMode = false;

  late SitesList sitesList = SitesList(updateItemLoading: (String value) {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
    });
    pageChanged(0);
  }

  Color colorCategory = ThemeColor.primaryColorLight;

  late CategoriesList categoriesList = CategoriesList();

  late Feed f;
  int feedIndex = 0;
  int pageIndex = 0;
  String categoryName = "";
  String descMeta1 = ""; //any_link_preview
  String imageUrlMeta1 = "";
  String descMeta2 = ""; //metadata_fetch
  String imageUrlMeta2 = "";
  void pageChanged(int value) async {
    pageIndex = value;
    var rng = Random();
    feedIndex = rng.nextInt(widget.feedsList.items.length - 1);
    f = widget.feedsList.items[feedIndex];
    Site? s = await sitesList.getSiteFromName(f.host);
    categoryName = "";
    if (s != null) {
      categoryName = s.category;
    }
    colorCategory = Color(categoriesList.getColor(categoryName));
    any_link_preview.Metadata? metadata =
        await any_link_preview.AnyLinkPreview.getMetadata(
      link: f.link,
      cache: const Duration(days: 3),
      //proxyUrl: "https://cors-anywhere.herokuapp.com/", // Needed for web app
    );
    descMeta1 = metadata?.desc ?? "";
    imageUrlMeta1 = metadata?.image ?? "";
    metadata_fetch.Metadata? metadata2 =
        await metadata_fetch.MetadataFetch.extract(f.link);

    descMeta2 = metadata2?.description ?? "";
    imageUrlMeta2 = metadata2?.image ?? "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(f.host),
        elevation: 1,
        backgroundColor: colorCategory,
        actions: [
          IconButton(
              icon: const Icon(Icons.shuffle),
              tooltip: 'Random',
              onPressed: () => pageChanged(pageIndex)),
        ],
      ),
      body: PageView.builder(

          //itemCount: 3,
          scrollDirection: Axis.vertical,
          onPageChanged: (value) => pageChanged(value),
          itemBuilder: (context, indexV) {
            return PageView.builder(

                //itemCount: 3,
                //scrollDirection: Axis.vertical,
                onPageChanged: (value) => pageChanged(value),
                itemBuilder: (context, indexH) {
                  return Container(
                    color: colorCategory.withAlpha(30), //index
                    child: Stack(
                      children: [
                        Center(
                            child: SingleChildScrollView(
                                child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                                width: 500,
                                child: Expanded(
                                    child: Card(
                                        margin: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 50,
                                            bottom: 50),
                                        clipBehavior: Clip.hardEdge,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: darkMode
                                                ? ThemeColor.dark3
                                                : Colors.white,
                                            width: 0.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        elevation: 0,
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 20,
                                              bottom: 20),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SiteLogo(
                                                      //  color: colorCategory,
                                                      iconUrl: f.iconUrl,
                                                    ),
                                                    Text(
                                                      f.host,
                                                    ),
                                                  ],
                                                ),
                                                Card(
                                                  margin: const EdgeInsets.only(
                                                      left: 0,
                                                      right: 0,
                                                      top: 0,
                                                      bottom: 20),
                                                  clipBehavior: Clip.hardEdge,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                      color: darkMode
                                                          ? ThemeColor.dark3
                                                          : Colors.white,
                                                      width: 0.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  elevation: 0,
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 50,
                                                    color: colorCategory
                                                        .withAlpha(225),
                                                    child: Center(
                                                      child: CircleAvatar(
                                                          radius: 23,
                                                          backgroundColor:
                                                              colorCategory
                                                                  .withAlpha(
                                                                      255),
                                                          child: ClipRRect(
                                                              child: Icon(
                                                            Icons.newspaper,
                                                            color: Colors.white
                                                                .withAlpha(200),
                                                            size: 25,
                                                          ))),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Random $feedIndex pagina $indexV-$indexH ${f.link.padRight(100).substring(0, 100)} ${f.pubDate} $categoryName ${f.title}',
                                                ),
                                                Text(
                                                  '$descMeta1\n\n$imageUrlMeta1',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '$descMeta2\n\n$imageUrlMeta2',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                CachedNetworkImage(
                                                  imageUrl: imageUrlMeta2,
                                                  placeholder: (context, url) =>
                                                      const Icon(Icons.link),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Icon(
                                                              Icons.link_off),
                                                ),
                                              ]),
                                        ))))
                          ],
                        )))
                      ],
                    ),
                  );
                });
          }),
    );
  }
}
