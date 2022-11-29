import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/feeds_list.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(f.host),
        elevation: 1,
        backgroundColor: colorCategory,
      ),
      body: PageView.builder(

          //itemCount: 3,
          scrollDirection: Axis.vertical,
          onPageChanged: (value) => pageChanged(value),
          itemBuilder: (context, index) {
            return Container(
              color: colorCategory.withAlpha(225), //index
              child: Stack(
                children: [
                  Center(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      EmptySection(
                        title: f.title,
                        description:
                            'Random $feedIndex \n\npagina $index \n\n link ${f.link}\n\n${f.pubDate}\n\n$categoryName',
                        icon: Icons.explore,
                        darkMode: darkMode,
                      ),
                    ],
                  ))
                ],
              ),
            );
          }),
    );
  }
}
