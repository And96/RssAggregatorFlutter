import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/loading_list_background.dart';

bool darkMode = false;

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator(
      {Key? key,
      required this.title,
      required this.description,
      required this.darkMode,
      required this.progressLoading})
      : super(key: key);

  final String title;
  final String description;
  final bool darkMode;
  final double progressLoading;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _refreshIconController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
    });
  }

  @override
  void dispose() {
    _refreshIconController.stop(canceled: true);
    _refreshIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        color: darkMode ? ThemeColor.dark1 : Colors.grey[200],
        child: Stack(alignment: Alignment.center,
            //padding: const EdgeInsets.only(bottom: 20),
            children: [
              LoadingListBackground(
                darkMode: darkMode,
              ),
              if (widget.progressLoading == 0)
                Icon(
                  Icons.bolt,
                  size: 70,
                  color: darkMode ? ThemeColor.light4 : ThemeColor.dark3,
                ),
              if (widget.progressLoading > 0)
                BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                    child: Container(
                        height: 235,
                        width: 275,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        decoration: BoxDecoration(
                            color: darkMode
                                ? ThemeColor.dark2.withAlpha(255)
                                : Colors.grey[100],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 25, top: 12),
                                    child: AnimatedBuilder(
                                      animation: _refreshIconController,
                                      builder: (_, child) {
                                        return Transform.rotate(
                                          angle: _refreshIconController.value *
                                              2 *
                                              3.1415,
                                          child: child,
                                        );
                                      },
                                      child: Icon(
                                        Icons.settings,
                                        size: 70,
                                        color: darkMode
                                            ? ThemeColor.light2
                                            : ThemeColor.dark3,
                                      ),
                                    ),
                                  ),
                                  // Max Size
                                  AnimatedBuilder(
                                    animation: _refreshIconController,
                                    builder: (_, child) {
                                      return Transform.rotate(
                                        angle: _refreshIconController.value *
                                            2 *
                                            3.1415 *
                                            -1,
                                        child: child,
                                      );
                                    },
                                    child: Icon(
                                      Icons.settings,
                                      size: 40,
                                      color: darkMode
                                          ? ThemeColor.light2
                                          : ThemeColor.dark3,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        widget.title,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.normal,
                                          color: darkMode
                                              ? ThemeColor.light3
                                              : ThemeColor.dark3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    SizedBox(
                                      width: 250,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            1, 10, 1, 20),
                                        child: LinearPercentIndicator(
                                          animation: true,
                                          progressColor: ThemeColor.dark3,
                                          lineHeight: 3.0,
                                          animateFromLastPercent: true,
                                          animationDuration: 500,
                                          percent: widget.progressLoading,
                                          barRadius: const Radius.circular(16),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width: double.infinity,
                                        child: Text(widget.description,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: darkMode
                                                  ? ThemeColor.light4
                                                  : ThemeColor.dark4,
                                            ))),
                                  ]),
                            ])))
            ]));
  }
}
