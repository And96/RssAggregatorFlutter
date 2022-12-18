import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';

bool darkMode = false;

class SiteLogoBig extends StatelessWidget {
  const SiteLogoBig({
    super.key,
    required this.iconUrl,
    required this.color,
  });

  final String iconUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
                side: const BorderSide(
                  width: 0,
                  color: Colors.transparent,
                ),
              ),
              //color: color,
            ),
            child: CircleAvatar(
                radius: 21,
                backgroundColor: ThemeColor.light1,
                child: ClipOval(
                    child: SizedBox(
                  child: iconUrl.toString().trim() == ""
                      ? const Icon(Icons.link)
                      : CachedNetworkImage(
                          height: 100,
                          width: 100,
                          imageUrl: iconUrl,
                          placeholder: (context, url) => const Icon(Icons.link),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.link),
                        ),
                )))),
        FutureBuilder<Color?>(
          future: ThemeColor().getMainColorFromUrl(iconUrl), // async work
          builder: (BuildContext context, AsyncSnapshot<Color?> snapshot) {
            Color paletteColor = snapshot.data == null
                ? Color(ThemeColor().defaultCategoryColor)
                : snapshot.data!;
            return Positioned(
                top: 27,
                left: 27,
                child: CircleAvatar(
                    radius: 9,
                    backgroundColor: paletteColor.withAlpha(
                        175), //ThemeColor().getMainColorFromUrl(iconUrl),
                    child: const Icon(Icons.rss_feed,
                        size: 13, color: Colors.white)));
          },
        ),
      ],
    );
  }
}
