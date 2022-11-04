import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
//import 'package:rss_aggregator_flutter/theme/theme_color.dart';

bool darkMode = false;

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    required this.title,
    required this.description,
    required this.widget,
    required this.darkMode,
    required this.progressLoading,
  });

  final String title;
  final String description;
  final Widget widget;
  final bool darkMode;
  final double progressLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget,
          const SizedBox(
            height: 15,
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
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
            child: LinearPercentIndicator(
              animation: true,
              progressColor: ThemeColor.dark3,
              lineHeight: 3.0,
              animateFromLastPercent: true,
              animationDuration: 500,
              percent: progressLoading,
              barRadius: const Radius.circular(16),
            ),
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
