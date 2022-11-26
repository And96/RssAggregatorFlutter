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
            : (widget.color.blue / 2 + widget.color.green + widget.color.red <
                    170)
                ? widget.color.withAlpha(150)
                : widget.color.withAlpha(200),
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
                    color: (0.299 * widget.color.red) +
                                (0.587 * widget.color.green) +
                                (0.114 * widget.color.blue) >
                            (Theme.of(context).brightness == Brightness.dark
                                ? 160
                                : 145)
                        ? Colors.black
                        : Colors.white,
                    size: 28.0,
                  ),
                ),
                Text(
                  widget.text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: (0.299 * widget.color.red) +
                                  (0.587 * widget.color.green) +
                                  (0.114 * widget.color.blue) >
                              (Theme.of(context).brightness == Brightness.dark
                                  ? 160
                                  : 145)
                          ? Colors.black
                          : Colors.white),
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
