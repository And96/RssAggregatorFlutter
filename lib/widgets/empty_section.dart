import 'package:flutter/material.dart';
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
            color: darkMode
                ? const Color.fromARGB(30, 235, 235, 235)
                : const Color.fromARGB(255, 235, 235, 235),
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
                color: darkMode
                    ? const Color.fromARGB(255, 190, 190, 190)
                    : const Color.fromARGB(255, 75, 75, 75),
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
                    color: darkMode
                        ? const Color.fromARGB(255, 130, 130, 130)
                        : const Color.fromARGB(255, 130, 130, 130),
                  ))),
        ],
      ),
    );
  }
}
