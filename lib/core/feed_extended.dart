import 'dart:ui';

import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:any_link_preview/any_link_preview.dart' as any_link_preview;
import 'package:metadata_fetch/metadata_fetch.dart' as metadata_fetch;

class FeedExtended {
  String link = "";
  String title = "";
  String host = "";
  String icon = "";
  DateTime date = DateTime(1900, 1, 1);
  int siteID = 0;
  Color color = ThemeColor.primaryColorLight;
  String description = "";
  String image = "";
  String category = "";
  int categoryIcon = 0;
  Color categoryColor = Color(ThemeColor().defaultCategoryColor);

  FeedExtended();

  Future<FeedExtended> getFromFeed(Feed feed) async {
    FeedExtended f = FeedExtended();
    try {
      f.link = feed.link;
      f.title = feed.title;
      f.host = feed.host;
      f.icon = feed.iconUrl;
      f.date = feed.pubDate;
      f.siteID = feed.siteID;
      f.color = await ThemeColor().getMainColorFromUrl(f.icon);
      f.category = await SitesList().getCategory(f.siteID);
      f.categoryIcon = CategoriesList().getIcon(f.category);
      f.categoryColor = Color(CategoriesList().getColor(f.category));
      //  refresh.call();
      any_link_preview.Metadata? metadata1 =
          await any_link_preview.AnyLinkPreview.getMetadata(
        link: f.link,
        cache: const Duration(days: 1),
      );
      f.description = Utility().cleanText(metadata1?.desc);
      f.image = metadata1?.image ?? "";
      if (f.description.length < 10 ||
          f.description.contains("http") ||
          f.image.length < 10) {
        metadata_fetch.Metadata? metadata2 =
            await metadata_fetch.MetadataFetch.extract(f.link);
        f.description = Utility().cleanText(metadata2?.description);
        f.image = metadata2?.image ?? f.image;
      }
      if (f.description.length < 10 || f.description.contains("http")) {
        f.description = f.title;
      }

      //hdblog ad esempio nn funziona, nonostande whatsapp e siti internet riescono ad estrarre testo ed img

    } catch (err) {
      //print('Caught error: $err');
    }
    return f;
  }

  /* FeedExtended.fromUrl(String url) {
    link = url;
    Feed feed = getFeedFromDB(url);
    FeedExtended.fromFeed(feed);
  }*/

  /*Feed getFeedFromDB(String url) {
    return Feed(
        link: url,
        title: "title",
        pubDate: DateTime(1900),
        iconUrl: "iconUrl",
        host: "host",
        siteID: 0);
  }*/

  @override
  String toString() => '{link: $link title: $title host: $host}';
}
