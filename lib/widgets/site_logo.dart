import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

bool darkMode = false;

class SiteLogo extends StatelessWidget {
  const SiteLogo({
    super.key,
    required this.iconUrl,
  });

  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 17,
      width: 17,
      child: iconUrl.toString().trim() == ""
          ? const Icon(Icons.link)
          : CachedNetworkImage(
              imageUrl: iconUrl,
              placeholder: (context, url) => const Icon(Icons.link),
              errorWidget: (context, url, error) => const Icon(Icons.link),
            ),
    );
  }
}
