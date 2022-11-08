import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/widgets/welcome_section.dart';
import 'package:intro_slider/intro_slider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  List<ContentConfig> listContentConfig = [];

  @override
  void initState() {
    super.initState();

    listContentConfig.add(
      const ContentConfig(
        colorBegin: Color.fromARGB(255, 38, 50, 56),
        colorEnd: Color.fromARGB(255, 0, 0, 0),
        marginDescription: EdgeInsets.all(2),
        widgetDescription: WelcomeSection(
          title: 'FastFeed',
          description:
              'Leggi le notizie dei tuoi siti preferiti in una unica applicazione',
          icon: Icons.newspaper,
          color: Colors.white,
        ),
      ),
    );

    listContentConfig.add(
      const ContentConfig(
        colorBegin: Color.fromARGB(255, 1, 87, 155),
        colorEnd: Color.fromARGB(255, 0, 0, 0),
        marginDescription: EdgeInsets.all(2),
        widgetDescription: WelcomeSection(
          title: 'Scegli siti',
          description:
              'Impostati i siti da seguire, troverai in automatico le notizie ordinate',
          icon: Icons.add_link,
          color: Colors.white,
        ),
      ),
    );

    listContentConfig.add(
      const ContentConfig(
        colorBegin: Color.fromARGB(255, 0, 77, 64),
        colorEnd: Color.fromARGB(255, 0, 0, 0),
        marginDescription: EdgeInsets.all(2),
        widgetDescription: WelcomeSection(
          title: 'Funzionalita',
          description:
              'Apri nel browser, salva preferiti, leggi piu tardi, condividi, lettura offline.',
          icon: Icons.local_activity,
          color: Colors.white,
        ),
      ),
    );

    listContentConfig.add(
      const ContentConfig(
        colorBegin: Color.fromARGB(255, 123, 0, 255),
        colorEnd: Color.fromARGB(255, 0, 0, 0),
        marginDescription: EdgeInsets.all(2),
        widgetDescription: WelcomeSection(
          title: 'Personalizzabile',
          description:
              'Crea categorie, raggruppa notizie, personalizza colori, modalita scura e altre impostazioni avanzate',
          icon: Icons.color_lens,
          color: Colors.white,
        ),
      ),
    );

    listContentConfig.add(
      const ContentConfig(
        colorBegin: Color.fromARGB(255, 38, 50, 56),
        colorEnd: Color.fromARGB(255, 0, 0, 0),
        marginDescription: EdgeInsets.all(2),
        widgetDescription: WelcomeSection(
          title: 'Aggregator',
          description: '\nGratis!\nSenza pubblicita!\nSenza abbonamento!',
          icon: Icons.newspaper,
          color: Colors.white,
        ),
      ),
    );
  }

  void onDonePress() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _globalKey,
        body: IntroSlider(
          key: UniqueKey(),
          listContentConfig: listContentConfig,
          onDonePress: onDonePress,
          renderNextBtn: const Text(
            "AVANTI",
            style: TextStyle(color: Colors.white),
          ),
          renderPrevBtn: const Text(
            "INDIETRO",
            style: TextStyle(color: Colors.white),
          ),
          renderDoneBtn: const Text(
            "FINE",
            style: TextStyle(color: Colors.white),
          ),
          renderSkipBtn: const Text(
            "SALTA",
            style: TextStyle(color: Colors.white),
          ),
          indicatorConfig: const IndicatorConfig(
            colorIndicator: Color.fromARGB(255, 255, 255, 255),
            typeIndicatorAnimation: TypeIndicatorAnimation.sizeTransition,
          ),
          isAutoScroll: false,
          isScrollable: true,
          scrollPhysics: const BouncingScrollPhysics(),
          isLoopAutoScroll: false,
          curveScroll: Curves.easeInCubic,
          backgroundColorAllTabs: Colors.black,
        ));
  }
}
