import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
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
    pageChanged(-1);
  }

  Color colorCategory = ThemeColor.primaryColorLight;
  Color siteColor = ThemeColor.primaryColorLight;

  late CategoriesList categoriesList = CategoriesList();

  late Feed f;
  int feedIndex = 0;
  int pageIndex = 0;
  String categoryName = "";
  int categoryIcon = 0;
  String descMeta1 = ""; //any_link_preview
  String imageUrlMeta1 = "";
  String descMeta2 = ""; //metadata_fetch
  String imageUrlMeta2 = "";
  void pageChanged(int value) async {
    pageIndex = value;
    //generate random numer
    var rng = Random();
    feedIndex = rng.nextInt(widget.feedsList.items.length - 1);
    if (value < widget.feedsList.items.length - 1) {
      feedIndex = value + 1;
    } else {
      feedIndex = 0;
    }
    f = widget.feedsList.items[feedIndex];
    Site? s = await sitesList.getSiteFromName(f.host);
    categoryName = "";
    if (s != null) {
      categoryName = s.category;
    }
    colorCategory = Color(categoriesList.getColor(categoryName));
    categoryIcon = categoriesList.getIcon(categoryName);
    descMeta1 = ""; //any_link_preview
    imageUrlMeta1 = "";
    descMeta2 = ""; //metadata_fetch
    imageUrlMeta2 = "";
    setState(() {});
    siteColor = (await ThemeColor().getMainColorFromUrl(f.iconUrl))!;
    setState(() {});
    any_link_preview.Metadata? metadata =
        await any_link_preview.AnyLinkPreview.getMetadata(
      link: f.link,
      cache: const Duration(days: 1),
    );
    descMeta1 = Utility().cleanText(metadata?.desc).replaceAll('\n', ". ");
    imageUrlMeta1 = metadata?.image ?? "";
    metadata_fetch.Metadata? metadata2 =
        await metadata_fetch.MetadataFetch.extract(f.link);
    descMeta2 = Utility().cleanText(metadata2?.description);
    imageUrlMeta2 = metadata2?.image ?? "";
    setState(() {});
  }

  final FocusNode _focusNode = FocusNode();

  void _handleKeyPressed(FocusNode f, RawKeyEvent e) {
    if (e.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      pageChanged(pageIndex);
    }
    if (e.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      pageChanged(pageIndex);
    }
    if (e.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      pageChanged(pageIndex);
    }
    if (e.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      pageChanged(pageIndex);
    }
    if (e.isKeyPressed(LogicalKeyboardKey.escape)) {
      Navigator.pop(context);
    }
    if (e.isKeyPressed(LogicalKeyboardKey.delete)) {
      Navigator.pop(context);
    }
    if (e.isKeyPressed(LogicalKeyboardKey.backspace)) {
      Navigator.pop(context);
    }
  }

  bool _showMoreOptions = false;

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);
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
        body: RawKeyboardListener(
      autofocus: true,
      onKey: (RawKeyEvent event) => {
        if (event is RawKeyDownEvent)
          {
            _handleKeyPressed(_focusNode, event),
          }
      },
      focusNode: _focusNode,
      child: PageView.builder(

          //itemCount: 3,
          scrollDirection: Axis.vertical,
          onPageChanged: (value) => pageChanged(value),
          itemBuilder: (context, indexV) {
            return PageView.builder(

                //itemCount: 3,
                scrollDirection: Axis.horizontal,
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
                                  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Container(
                                  color: darkMode
                                      ? ThemeColor.dark1.withAlpha(240)
                                      : Colors.grey.withAlpha(190),
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
                                              /* Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                      onPressed: (null),
                                                      icon: Icon(
                                                        Icons.arrow_back,
                                                        color: Colors.white,
                                                      ))
                                                ],
                                              ),*/
                                              SizedBox(
                                                  width: 500,
                                                  child: Card(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 20,
                                                              top: 25,
                                                              bottom: 25),
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
                                                                  height: 230,
                                                                  child: Stack(
                                                                      fit: StackFit
                                                                          .expand,
                                                                      children: <
                                                                          Widget>[
                                                                        Stack(children: <
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
                                                                              gradient: LinearGradient(
                                                                                colors: [
                                                                                  Colors.transparent,
                                                                                  Colors.black.withAlpha(220),
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
                                                                          Positioned
                                                                              .fill(
                                                                            child:
                                                                                Opacity(
                                                                              opacity: 0.1,
                                                                              child: Container(
                                                                                color: const Color(0xFF000000),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                        Positioned(
                                                                            top:
                                                                                0,
                                                                            right:
                                                                                0,
                                                                            child: Padding(
                                                                                padding: const EdgeInsets.all(13.0),
                                                                                child: Wrap(
                                                                                  direction: Axis.vertical,
                                                                                  spacing: 2.5, // gap between adjacent chips
                                                                                  runSpacing: 2.5, // gap between lines
                                                                                  children: <Widget>[
                                                                                    IconButton(
                                                                                      padding: EdgeInsets.zero,
                                                                                      icon: const Icon(
                                                                                        Icons.more_vert_rounded,
                                                                                        size: 27,
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                      tooltip: 'Options',
                                                                                      onPressed: () {
                                                                                        setState(() {
                                                                                          _showMoreOptions = !_showMoreOptions;
                                                                                        });
                                                                                      },
                                                                                    ),
                                                                                    if (_showMoreOptions)
                                                                                      IconButton(
                                                                                        padding: EdgeInsets.zero,
                                                                                        icon: const Icon(
                                                                                          Icons.favorite_outline,
                                                                                          size: 27,
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        tooltip: 'Favourite',
                                                                                        onPressed: () {
                                                                                          pageChanged(pageIndex);
                                                                                        },
                                                                                      ),
                                                                                    if (_showMoreOptions)
                                                                                      IconButton(
                                                                                        padding: EdgeInsets.zero,
                                                                                        icon: const Icon(
                                                                                          Icons.watch_later_outlined,
                                                                                          size: 27,
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        tooltip: 'Read Later',
                                                                                        onPressed: () {
                                                                                          pageChanged(pageIndex);
                                                                                        },
                                                                                      ),
                                                                                    if (_showMoreOptions)
                                                                                      IconButton(
                                                                                        padding: EdgeInsets.zero,
                                                                                        icon: const Icon(
                                                                                          Icons.copy,
                                                                                          size: 27,
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        tooltip: 'Copy link',
                                                                                        onPressed: () {
                                                                                          pageChanged(pageIndex);
                                                                                        },
                                                                                      ),
                                                                                  ],
                                                                                ))),
                                                                        Positioned(
                                                                            top:
                                                                                0,
                                                                            right:
                                                                                0,
                                                                            child: Padding(
                                                                                padding: const EdgeInsets.only(top: 13.0, right: 60),
                                                                                child: Wrap(
                                                                                  direction: Axis.vertical,
                                                                                  spacing: 2.5, // gap between adjacent chips
                                                                                  runSpacing: 2.5, // gap between lines
                                                                                  children: <Widget>[
                                                                                    if (_showMoreOptions)
                                                                                      IconButton(
                                                                                        padding: EdgeInsets.zero,
                                                                                        icon: const Icon(
                                                                                          Icons.share,
                                                                                          size: 27,
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        tooltip: 'Share',
                                                                                        onPressed: () {
                                                                                          pageChanged(pageIndex);
                                                                                        },
                                                                                      ),
                                                                                  ],
                                                                                ))),
                                                                        Positioned(
                                                                            top:
                                                                                0,
                                                                            left:
                                                                                0,
                                                                            child: Padding(
                                                                                padding: const EdgeInsets.all(20.0),
                                                                                child: Wrap(
                                                                                    direction: Axis.horizontal,
                                                                                    spacing: 4.0, // gap between adjacent chips
                                                                                    runSpacing: 240, // gap between lines
                                                                                    children: <Widget>[
                                                                                      Chip(
                                                                                          /*avatar: Icon(
                                                                                            IconData(categoryIcon, fontFamily: 'MaterialIcons'),
                                                                                            size: 18,
                                                                                          ),*/
                                                                                          backgroundColor: darkMode ? ThemeColor.dark2 : Colors.white,
                                                                                          label: Text(
                                                                                            Utility().dateFormat(context, f.pubDate),
                                                                                          ))
                                                                                    ]))),
                                                                        Positioned(
                                                                            bottom:
                                                                                0,
                                                                            left:
                                                                                0,
                                                                            width:
                                                                                320,
                                                                            child:
                                                                                Padding(padding: const EdgeInsets.all(20.0), child: Text(f.title, maxLines: 4, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)))),
                                                                      ])),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left: 7,
                                                                        right:
                                                                            7,
                                                                        top: 13,
                                                                        bottom:
                                                                            2),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    Chip(
                                                                      backgroundColor: darkMode
                                                                          ? ThemeColor
                                                                              .dark2
                                                                          : Colors
                                                                              .white,
                                                                      avatar:
                                                                          SiteLogo(
                                                                        //  color: colorCategory,
                                                                        iconUrl:
                                                                            f.iconUrl,
                                                                      ),
                                                                      label:
                                                                          Text(
                                                                        (f.host),
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 16
                                                                            /*color:
                                                                              Colors.white,*/
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    Chip(
                                                                      backgroundColor:
                                                                          colorCategory,
                                                                      avatar: ClipRRect(
                                                                          child: Icon(
                                                                        IconData(
                                                                            categoryIcon,
                                                                            fontFamily:
                                                                                'MaterialIcons'),
                                                                        color: Colors
                                                                            .white
                                                                            .withAlpha(200),
                                                                        size:
                                                                            15,
                                                                      )),
                                                                      label:
                                                                          Text(
                                                                        (categoryName
                                                                            .toString()),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const Divider(),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            15,
                                                                        right:
                                                                            15,
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
                                                                      Text(
                                                                        descMeta1.length > 10 &&
                                                                                !descMeta1.contains("http")
                                                                            ? descMeta1
                                                                            : descMeta1.length > 10 && !descMeta1.contains("http")
                                                                                ? descMeta2
                                                                                : f.title,
                                                                        maxLines:
                                                                            7,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                        ),
                                                                      ),
                                                                      const Divider(),
                                                                      Text(
                                                                        '${f.link.padRight(100).substring(0, 100).trim()}\n',
                                                                        maxLines:
                                                                            2,
                                                                      ),
                                                                      const Divider(),
                                                                      /*ButtonFeedOpen(
                                                                          text:
                                                                              "Leggi sul sito",
                                                                          function:
                                                                              () {
                                                                            Utility().launchInBrowser(Uri.parse(f.link));
                                                                          },
                                                                          icon: Icons
                                                                              .public,
                                                                          color1:
                                                                              siteColor,
                                                                          color2:
                                                                              siteColor),*/

                                                                      /*const Divider(),
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
                                                                    */
                                                                    ]),
                                                              ),
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                height: 65,
                                                                /*  color: siteColor
                                                                    .withAlpha(
                                                                        170),*/
                                                                color: darkMode
                                                                    ? ThemeColor
                                                                        .dark1
                                                                        .withAlpha(
                                                                            100)
                                                                    : ThemeColor
                                                                        .light1
                                                                        .withAlpha(
                                                                            200),
                                                                child: InkWell(
                                                                  customBorder:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                  ),
                                                                  //DONT WORKS
                                                                  /* highlightColor: Theme.of(context)
                                                                              .brightness ==
                                                                          Brightness
                                                                              .dark
                                                                      ? siteColor
                                                                          .withAlpha(
                                                                              50)
                                                                      : siteColor
                                                                          .withAlpha(
                                                                              50),
                                                                  hoverColor: Theme.of(context)
                                                                              .brightness ==
                                                                          Brightness
                                                                              .dark
                                                                      ? siteColor
                                                                          .withAlpha(
                                                                              50)
                                                                      : siteColor
                                                                          .withAlpha(
                                                                              50),
                                                                  splashColor: Theme.of(context)
                                                                              .brightness ==
                                                                          Brightness
                                                                              .dark
                                                                      ? siteColor
                                                                      : siteColor,*/
                                                                  onTap:
                                                                      () async {
                                                                    /*await Future.delayed(const Duration(
                                                                        milliseconds:
                                                                            150));*/
                                                                    Utility().launchInBrowser(
                                                                        Uri.parse(
                                                                            f.link));
                                                                  },
                                                                  child: Center(
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: <
                                                                          Widget>[
                                                                        Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              0,
                                                                              0,
                                                                              15,
                                                                              0),
                                                                          child:
                                                                              Icon(
                                                                            Icons.public,
                                                                            /*   color: ThemeColor().isColorDark(siteColor)
                                                                                ? Colors.white
                                                                                : Colors.black,*/

                                                                            color: darkMode
                                                                                ? Colors.white
                                                                                : Colors.black,
                                                                            size:
                                                                                28.0,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Leggi sul sito',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                15,
                                                                            /*   color: ThemeColor().isColorDark(siteColor)
                                                                                ? Colors.white
                                                                                : Colors.black,*/

                                                                            color: darkMode
                                                                                ? Colors.white
                                                                                : Colors.black,
                                                                          ),
                                                                          maxLines:
                                                                              1,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )))),
                                              if (pageIndex < 1)
                                                Chip(
                                                    backgroundColor: darkMode
                                                        ? ThemeColor.dark1
                                                        : ThemeColor.light1,
                                                    avatar:
                                                        const Icon(Icons.info),
                                                    label: const Text(
                                                        " Swipe up to load another article"))
                                            ],
                                          )))))));
                });
          }),
    ));
  }
}
