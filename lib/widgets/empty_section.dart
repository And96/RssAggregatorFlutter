import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
//import 'package:rss_aggregator_flutter/theme/theme_color.dart';

bool darkMode = false;

class EmptySection extends StatelessWidget {
  const EmptySection({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.darkMode,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 120,
            color: darkMode
                ? ThemeColor.dark3.withAlpha(150)
                : ThemeColor.light2.withAlpha(150),
          ),
          const SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: darkMode ? ThemeColor.light3 : ThemeColor.dark3,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
              width: double.infinity,
              child: Text(description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: darkMode ? ThemeColor.light4 : ThemeColor.dark4,
                  ))),
        ],
      ),
    );
  }
}
