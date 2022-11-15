import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
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
  });

  final String title;
  final DateTime pubDate;
  final String link;
  final String host;
  final String iconUrl;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
        child: Card(
            margin: const EdgeInsets.only(left: 6, right: 6, top: 4, bottom: 4),
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: darkMode
                    ? ThemeColor.dark3.withAlpha(50)
                    : const Color.fromARGB(255, 255, 255, 255),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            elevation: 1,
            color: darkMode
                ? ThemeColor.dark2
                : const Color.fromARGB(255, 248, 248, 248),
            shadowColor: darkMode ? Colors.black : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 10, left: 0, right: 0),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 0),
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
                            DateFormat('dd/MM/yy HH:mm').format(
                              pubDate.toLocal(),
                            ),
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
                        padding: const EdgeInsets.only(top: 7, bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
            )));
  }
}
