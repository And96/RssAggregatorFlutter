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
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 0.0,
      color: Theme.of(context).brightness == Brightness.dark
          ? ThemeColor.dark3.withAlpha(50)
          : ThemeColor.light1.withAlpha(230),
      child: InkWell(
          onTap: () {
            function.call();
          },
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Icon(
                  icon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[800],
                  size: 27.0,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text(
                    text,
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
