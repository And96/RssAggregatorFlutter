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
            size: 100,
            color: darkMode ? ThemeColor.dark3 : ThemeColor.light2,
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.normal,
                color: darkMode ? ThemeColor.light3 : ThemeColor.dark3,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
              width: double.infinity,
              child: Text(description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: darkMode ? ThemeColor.light4 : ThemeColor.dark4,
                  ))),
        ],
      ),
    );
  }
}
