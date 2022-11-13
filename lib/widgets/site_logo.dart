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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        iconUrl.toString().trim() == ""
            ? const Icon(Icons.link)
            : ClipOval(
                child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: CachedNetworkImage(
                    height: 19,
                    width: 19,
                    fit: BoxFit.cover,
                    imageUrl: iconUrl,
                    placeholder: (context, url) => const Icon(Icons.link),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.link_off),
                  ),
                ),
              ),
      ],
    );
  }
}
