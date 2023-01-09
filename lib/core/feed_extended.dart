import 'dart:ui';

import 'package:rss_aggregator_flutter/core/cache.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/feed.dart';
import 'package:rss_aggregator_flutter/core/settings.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:any_link_preview/any_link_preview.dart' as any_link_preview;
import 'package:metadata_fetch/metadata_fetch.dart' as metadata_fetch;
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

  Settings settings = Settings();

  FeedExtended();

  Future<void> setFromFeed(Feed feed) async {
    try {
      FeedExtended();
      link = feed.link;
      title = feed.title;
      host = feed.host;
      icon = feed.iconUrl;
      date = feed.pubDate;
      siteID = feed.siteID;
      color = await ThemeColor().getMainColorFromUrl(icon);
      category = await SitesList().getCategory(siteID);
      categoryIcon = await CategoriesList().getIcon(category);
      categoryColor = await CategoriesList().getColor(category);
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  String cleanText(String? text) {
    try {
      // ignore: unnecessary_string_escapes
      return "${Utility().cleanText(text).replaceAll("[...]", "").replaceAll("[…]", "").replaceAll("...", "").replaceAll("..", "").replaceAll(RegExp('\\.\$'), " ").trim()}...";
    } catch (e) {
      //print('Caught error: $err');
    }
    return " ";
  }

  Future<void> setWebData(bool preCacheImg) async {
    try {
      await settings.init();

      //get value from cache
      image = await Cache().get(link, "img");
      description = await Cache().get(link, "desc");

      //if not cached
      if (description.length < 5) {
        try {
          any_link_preview.Metadata? metadata1 =
              await any_link_preview.AnyLinkPreview.getMetadata(
            link: link,
            cache: const Duration(days: 1),
          ).timeout(const Duration(milliseconds: 4000));
          description = cleanText(metadata1?.desc);
          image = metadata1?.image ?? "";
        } catch (err) {
          //print('Caught errorx: $err');
        }

        try {
          if (description.length < 10 ||
              description.contains("http") ||
              image.length < 10) {
            metadata_fetch.Metadata? metadata2 =
                await metadata_fetch.MetadataFetch.extract(link)
                    .timeout(const Duration(milliseconds: 4000));
            description = cleanText(metadata2?.description);
            image = metadata2?.image ?? image;
          }
        } catch (err) {
          //print('Caught error: $err');
        }

        //hdblog ad esempio nn funziona, nonostande whatsapp e siti internet riescono ad estrarre testo ed img
        //trovare alternative o fare fork per cercare in un ordine diverso

        if (description.length < 10 || description.contains("http")) {
          description = cleanText(title);
        }

        //save value to cache
        await Cache().save(link, "img", image);
        await Cache().save(link, "desc", description);
      }

      try {
        //cache network image (if not cached yet)
        if (settings.settingsLoadImages) {
          if (preCacheImg) {
            if (image.length > 10) {
              var obj = await DefaultCacheManager().getFileFromCache(image);
              if (obj?.originalUrl == null) {
                DefaultCacheManager()
                    .downloadFile(image)
                    .timeout(const Duration(milliseconds: 4000))
                    .then((_) {});
              }
            }
          }
        }
      } catch (err) {
        // print('Caught error: $err');
      }
    } catch (err) {
      // print('Caught error: $err');
    }
  }

  @override
  String toString() => '{link: $link title: $title host: $host}';
}
