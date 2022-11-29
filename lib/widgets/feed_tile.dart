import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
// ignore: depend_on_referenced_packages
import 'package:rss_aggregator_flutter/widgets/site_logo.dart';

bool darkMode = false;

class FeedTile extends StatelessWidget {
  const FeedTile({
    super.key,
    required this.title,
    required this.link,
    required this.host,
    required this.pubDate,
    required this.iconUrl,
    required this.darkMode,
    required this.function,
    required this.mainColor,
  });

  final String title;
  final DateTime pubDate;
  final String link;
  final String host;
  final String iconUrl;
  final Function function;
  final bool darkMode;
  final Color mainColor;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Color?>(
        future: ThemeColor().getMainColorFromUrl(iconUrl), // async work
        builder: (BuildContext context, AsyncSnapshot<Color?> snapshot) {
          Color paletteColor = snapshot.data == null
              ? Color(ThemeColor().defaultCategoryColor)
              : snapshot.data!;
          return Padding(
              padding:
                  const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
              child: Card(
                  margin: const EdgeInsets.only(
                      left: 8, right: 8, top: 8, bottom: 5),
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: darkMode
                          ? ThemeColor.dark3.withAlpha(0)
                          : const Color.fromARGB(255, 255, 255, 255),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 0,
                  color: darkMode
                      ? ThemeColor.dark2
                      : const Color.fromARGB(255, 255, 255, 255),
                  shadowColor: darkMode ? Colors.black : Colors.white,
                  child: InkWell(
                      hoverColor: darkMode
                          ? ThemeColor.dark3.withAlpha(50)
                          : ThemeColor.light1.withAlpha(50),
                      highlightColor: darkMode
                          ? ThemeColor.dark3.withAlpha(150)
                          : paletteColor.withAlpha(30),
                      splashColor: darkMode
                          ? ThemeColor.dark1
                          : paletteColor.withAlpha(50),
                      onTap: () async => {
                            await Future.delayed(
                                const Duration(milliseconds: 100)),
                            function.call()
                          },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 10, left: 0, right: 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              /* contentPadding:    const EdgeInsets.all(5),*/
                              minLeadingWidth: 25,
                              leading: SiteLogo(
                                iconUrl: iconUrl,
                              ),
                              title: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 0),
                                            child: Text(
                                              (host.toString()),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: darkMode
                                                    ? ThemeColor.light3
                                                    : ThemeColor.dark4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      Utility().dateFormat(context, pubDate),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: darkMode
                                            ? ThemeColor.light3
                                            : ThemeColor.dark4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //isThreeLine: true,
                              subtitle: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 7, bottom: 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(
                                        child: Text(
                                          title.toString(),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            //but instead of 300 it's 350
                                            color: darkMode
                                                ? ThemeColor.light1
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ))));
        });
  }
}
