import 'dart:math';
import 'dart:ui';

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
  Color siteColor = ThemeColor.primaryColorLight;

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
    siteColor = (await ThemeColor().getMainColorFromUrl(f.iconUrl))!;
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
      /*appBar: AppBar(
        title: Text(f.host),
        elevation: 1,
        backgroundColor: siteColor,
        //backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              icon: const Icon(Icons.shuffle),
              tooltip: 'Random',
              onPressed: () => pageChanged(pageIndex)),
        ],
      ),*/
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
                      /*  margin: const EdgeInsets.only(
                          left: 0, right: 0, top: 0, bottom: 0),*/
                      // color: Colors.grey.withAlpha(50), //index
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image(
                                    // height: 100,
                                    //width: 100,
                                    image: CachedNetworkImageProvider(
                                        imageUrlMeta2.length > 10
                                            ? imageUrlMeta2
                                            : imageUrlMeta1))
                                .image),
                      ),
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 10.0),
                          child: Center(
                              child: SingleChildScrollView(
                                  padding: const EdgeInsets.only(
                                      left: 0, right: 0, top: 0, bottom: 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(
                                          width: 500,
                                          child: Card(
                                              margin: const EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                  top: 50,
                                                  bottom: 50),
                                              clipBehavior: Clip.antiAlias,
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                  color: Colors.white,
                                                  width: 4.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              elevation: 0,
                                              child: Container(
                                                  //   color: Colors.orange,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 0,
                                                          right: 0,
                                                          top: 0,
                                                          bottom: 0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Container(
                                                          //color: Colors.orange,
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 0,
                                                                  right: 0,
                                                                  top: 0,
                                                                  bottom: 0),
                                                          height: 210,
                                                          child: Stack(
                                                              fit: StackFit
                                                                  .expand,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  //    color: Colors
                                                                  //       .purple,
                                                                  margin: const EdgeInsets
                                                                          .only(
                                                                      left: 0,
                                                                      right: 0,
                                                                      top: 0,
                                                                      bottom:
                                                                          0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image: DecorationImage(
                                                                        fit: BoxFit.cover,
                                                                        image: Image(
                                                                                // height: 100,
                                                                                //width: 100,
                                                                                image: CachedNetworkImageProvider(imageUrlMeta2.length > 10 ? imageUrlMeta2 : imageUrlMeta1))
                                                                            .image),
                                                                  ),
                                                                  foregroundDecoration:
                                                                      BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                      colors: [
                                                                        Colors
                                                                            .transparent,
                                                                        Colors
                                                                            .black
                                                                            .withAlpha(195),
                                                                      ],
                                                                      begin: Alignment
                                                                          .topCenter,
                                                                      end: Alignment
                                                                          .bottomCenter,
                                                                      stops: const [
                                                                        0.3,
                                                                        0.9
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                    bottom: 0,
                                                                    left: 0,
                                                                    width: 350,
                                                                    child: Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                                20.0),
                                                                        child: Text(
                                                                            f.title,
                                                                            maxLines: 4,
                                                                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
                                                              ])),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 20,
                                                                right: 20,
                                                                top: 20,
                                                                bottom: 20),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20,
                                                                        top: 0,
                                                                        bottom:
                                                                            20),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    SiteLogo(
                                                                      //  color: colorCategory,
                                                                      iconUrl: f
                                                                          .iconUrl,
                                                                    ),
                                                                    Text(
                                                                      f.host,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Card(
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left: 0,
                                                                        right:
                                                                            0,
                                                                        top: 0,
                                                                        bottom:
                                                                            20),
                                                                clipBehavior:
                                                                    Clip.hardEdge,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  side:
                                                                      const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 0.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0),
                                                                ),
                                                                elevation: 0,
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 50,
                                                                  color: colorCategory
                                                                      .withAlpha(
                                                                          225),
                                                                  child: Center(
                                                                    child: CircleAvatar(
                                                                        radius: 23,
                                                                        backgroundColor: colorCategory.withAlpha(255),
                                                                        child: ClipRRect(
                                                                            child: Icon(
                                                                          Icons
                                                                              .newspaper,
                                                                          color: Colors
                                                                              .white
                                                                              .withAlpha(200),
                                                                          size:
                                                                              25,
                                                                        ))),
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                '${f.link.padRight(100).substring(0, 100)} \n\n${f.pubDate} $categoryName \n',
                                                              ),
                                                              Text(
                                                                '$descMeta1\n\n$imageUrlMeta1',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                '$descMeta2\n\n$imageUrlMeta2',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                            ]),
                                                      )
                                                    ],
                                                  ))))
                                    ],
                                  )))));
                });
          }),
    );
  }
}
