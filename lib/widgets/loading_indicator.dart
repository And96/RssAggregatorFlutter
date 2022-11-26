import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
//import 'package:rss_aggregator_flutter/theme/theme_color.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.progressLoading == 0)
            Icon(
              Icons.feed,
              size: 80,
              color: darkMode ? ThemeColor.light4 : ThemeColor.dark3,
            ),
          if (widget.progressLoading > 0)
            Stack(
              alignment: Alignment.topRight,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 25, top: 12),
                  child: AnimatedBuilder(
                    animation: _refreshIconController,
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: _refreshIconController.value * 2 * 3.1415,
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.settings,
                      size: 70,
                      color: darkMode ? ThemeColor.light2 : ThemeColor.dark3,
                    ),
                  ),
                ),
                // Max Size
                AnimatedBuilder(
                  animation: _refreshIconController,
                  builder: (_, child) {
                    return Transform.rotate(
                      angle: _refreshIconController.value * 2 * 3.1415 * -1,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.settings,
                    size: 40,
                    color: darkMode ? ThemeColor.light2 : ThemeColor.dark3,
                  ),
                ),
              ],
            ),
          const SizedBox(
            height: 15,
          ),
          if (widget.progressLoading != 0)
            Align(
              alignment: Alignment.center,
              child: Text(
                widget.title,
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
          if (widget.progressLoading != 0)
            SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(1, 10, 1, 20),
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
          if (widget.progressLoading != 0)
            SizedBox(
                width: double.infinity,
                child: Text(widget.description,
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
