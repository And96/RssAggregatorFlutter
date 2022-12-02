import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/button_feed_open.dart';
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
      cache: const Duration(days: 1),
    );
    descMeta1 = metadata?.desc.toString().replaceAll('\n', " ") ?? "";
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
                      color: darkMode
                          ? ThemeColor.dark1
                          : Color.alphaBlend(siteColor.withAlpha(50),
                                  Colors.blueGrey.withAlpha(50))
                              .withAlpha(100),
                      child: Container(
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
                              filter:
                                  ImageFilter.blur(sigmaX: 50.0, sigmaY: 10.0),
                              child: Container(
                                  color: darkMode
                                      ? Colors.black.withAlpha(210)
                                      : Colors.transparent,
                                  child: Center(
                                      child: SingleChildScrollView(
                                          padding: const EdgeInsets.only(
                                              left: 0,
                                              right: 0,
                                              top: 0,
                                              bottom: 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              SizedBox(
                                                  width: 500,
                                                  child: Card(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 20,
                                                              top: 50,
                                                              bottom: 50),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          color: darkMode
                                                              ? ThemeColor.dark2
                                                              : Colors.white,
                                                          width: 4.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      elevation: 0,
                                                      child: Container(
                                                          color: darkMode
                                                              ? ThemeColor.dark2
                                                              : Colors.white,
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 0,
                                                                  right: 0,
                                                                  top: 0,
                                                                  bottom: 0),
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
                                                                  color: darkMode
                                                                      ? ThemeColor
                                                                          .dark2
                                                                      : siteColor,
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 0,
                                                                      right: 0,
                                                                      top: 0,
                                                                      bottom:
                                                                          0),
                                                                  height: 210,
                                                                  child: Stack(
                                                                      fit: StackFit
                                                                          .expand,
                                                                      children: <
                                                                          Widget>[
                                                                        Container(
                                                                          //    color: Colors
                                                                          //       .purple,
                                                                          margin: const EdgeInsets.only(
                                                                              left: 0,
                                                                              right: 0,
                                                                              top: 0,
                                                                              bottom: 0),
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
                                                                                Colors.transparent,
                                                                                Colors.black.withAlpha(210),
                                                                              ],
                                                                              begin: Alignment.topCenter,
                                                                              end: Alignment.bottomCenter,
                                                                              stops: const [
                                                                                0.2,
                                                                                0.9
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                            bottom:
                                                                                0,
                                                                            left:
                                                                                0,
                                                                            width:
                                                                                350,
                                                                            child:
                                                                                Padding(padding: const EdgeInsets.all(20.0), child: Text(f.title, maxLines: 4, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
                                                                      ])),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        top: 13,
                                                                        bottom:
                                                                            2),
                                                                child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceAround,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(
                                                                                top: 0,
                                                                                left: 0,
                                                                                right: 10,
                                                                                bottom: 0),
                                                                            child:
                                                                                SiteLogo(
                                                                              //  color: colorCategory,
                                                                              iconUrl: f.iconUrl,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            f.host,
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      if (categoryName
                                                                              .trim() !=
                                                                          "")
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(top: 0),
                                                                          child:
                                                                              Container(
                                                                            padding: const EdgeInsets.only(
                                                                                top: 1,
                                                                                left: 8,
                                                                                right: 8,
                                                                                bottom: 1),
                                                                            decoration: BoxDecoration(
                                                                                color: colorCategory,
                                                                                border: Border.all(
                                                                                  color: colorCategory,
                                                                                ),
                                                                                borderRadius: const BorderRadius.all(Radius.circular(15))),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 0, left: 1, right: 6, bottom: 0),
                                                                                  child: ClipRRect(
                                                                                      child: Icon(
                                                                                    Icons.newspaper,
                                                                                    color: Colors.white.withAlpha(200),
                                                                                    size: 15,
                                                                                  )),
                                                                                ),
                                                                                Text(
                                                                                  (categoryName.toString()),
                                                                                  style: const TextStyle(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.normal,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                    ]),
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20,
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      const Divider(),
                                                                      Text(
                                                                        descMeta1.length >
                                                                                5
                                                                            ? descMeta1
                                                                            : descMeta2,
                                                                        maxLines:
                                                                            7,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                      const Divider(),
                                                                      Text(
                                                                        '${f.link.padRight(100).substring(0, 100).trim()}\n',
                                                                        maxLines:
                                                                            3,
                                                                      ),
                                                                      const Divider(),
                                                                      ButtonFeedOpen(
                                                                          text:
                                                                              "Leggi sul sito",
                                                                          function:
                                                                              () {
                                                                            Utility().launchInBrowser(Uri.parse(f.link));
                                                                            Navigator.pop(context);
                                                                          },
                                                                          icon: Icons
                                                                              .public,
                                                                          color:
                                                                              siteColor),
                                                                      const Divider(),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            left:
                                                                                0,
                                                                            right:
                                                                                0,
                                                                            top:
                                                                                0,
                                                                            bottom:
                                                                                5),
                                                                        child:
                                                                            Text(
                                                                          Utility().dateFormat(
                                                                              context,
                                                                              f.pubDate),
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            color: darkMode
                                                                                ? ThemeColor.light3
                                                                                : ThemeColor.dark4,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ]),
                                                              )
                                                            ],
                                                          ))))
                                            ],
                                          )))))));
                });
          }),
    );
  }
}
