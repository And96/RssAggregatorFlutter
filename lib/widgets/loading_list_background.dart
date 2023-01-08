import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';

class LoadingListBackground extends StatelessWidget {
  const LoadingListBackground({
    super.key,
    required this.darkMode,
  });

  final bool darkMode;

  CardLoadingTheme cardLoadingTheme() {
    return darkMode
        ? CardLoadingTheme(
            colorOne: ThemeColor.dark2.withAlpha(40),
            colorTwo: ThemeColor.dark2.withAlpha(60))
        : CardLoadingTheme(
            colorOne: ThemeColor.light2.withAlpha(30),
            colorTwo: ThemeColor.light2.withAlpha(50));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardLoading(
            height: 15,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            width: 150,
            margin: const EdgeInsets.only(top: 20),
          ),
          CardLoading(
            height: 50,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 10),
          ),
          CardLoading(
            height: 20,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 10),
          ),
          CardLoading(
            height: 20,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 10),
          ),
          CardLoading(
            height: 20,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 50),
          ),
          CardLoading(
            height: 15,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            width: 150,
            margin: const EdgeInsets.only(top: 10),
          ),
          CardLoading(
            height: 50,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 10),
          ),
          CardLoading(
            height: 20,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 10),
          ),
          CardLoading(
            height: 20,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 10),
          ),
          CardLoading(
            height: 20,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 10),
          ),
          CardLoading(
            height: 15,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            width: 150,
            margin: const EdgeInsets.only(top: 50),
          ),
          CardLoading(
            height: 50,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 10),
          ),
          CardLoading(
            height: 20,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 10),
          ),
          CardLoading(
            height: 20,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 10),
          ),
          CardLoading(
            height: 20,
            cardLoadingTheme: cardLoadingTheme(),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            margin: const EdgeInsets.only(top: 10),
          ),
        ],
      ),
    );
  }
}
