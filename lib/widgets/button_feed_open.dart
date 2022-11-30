import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';

class ButtonFeedOpen extends StatefulWidget {
  const ButtonFeedOpen({
    Key? key,
    required this.text,
    required this.function,
    required this.icon,
    required this.color,
  }) : super(key: key);

  final String text;
  final Function function;
  final IconData icon;
  final Color color;

  @override
  State<ButtonFeedOpen> createState() => _ButtonFeedOpenState();
}

class _ButtonFeedOpenState extends State<ButtonFeedOpen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      width: double.infinity,
      height: 70,
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: ThemeColor.dark3.withAlpha(0),
            width: 0.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 0.0,
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeColor.dark3.withAlpha(50)
            : ThemeColor.light1.withAlpha(230),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          highlightColor: Theme.of(context).brightness == Brightness.dark
              ? widget.color.withAlpha(50)
              : widget.color.withAlpha(50),
          hoverColor: Theme.of(context).brightness == Brightness.dark
              ? widget.color.withAlpha(50)
              : widget.color.withAlpha(50),
          splashColor: Theme.of(context).brightness == Brightness.dark
              ? widget.color
              : widget.color,
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 150));
            widget.function.call();
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Icon(
                    widget.icon,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[800],
                    size: 28.0,
                  ),
                ),
                Text(
                  widget.text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[800],
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
