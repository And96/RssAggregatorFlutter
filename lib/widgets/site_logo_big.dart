import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
                side: const BorderSide(width: 2, color: Colors.black87),
              ),
            ),
            child: CircleAvatar(
                //radius: 30,
                backgroundColor: Colors.white,
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
                              const Icon(Icons.link_off),
                        ),
                )))),
        Positioned(
            top: 27,
            left: 27,
            child: CircleAvatar(
                radius: 9,
                backgroundColor: Colors.black.withAlpha(200),
                child:
                    const Icon(Icons.rss_feed, size: 13, color: Colors.white))),
      ],
    );
  }
}
