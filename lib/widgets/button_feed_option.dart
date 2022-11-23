import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';

class ButtonFeedOption extends StatelessWidget {
  const ButtonFeedOption({
    super.key,
    required this.text,
    required this.function,
    required this.icon,
  });

  final String text;
  final Function function;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black.withAlpha(0),
          width: 0.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      color: Theme.of(context).brightness == Brightness.dark
          ? ThemeColor.dark3.withAlpha(90)
          : ThemeColor.light1.withAlpha(170),
      child: InkWell(
        onTap: () {
          function;
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                    child: Icon(
                  icon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[800],
                  size: 27.0,
                )),
                Text(text),
              ]),
        ),
      ),
    );
  }
}
