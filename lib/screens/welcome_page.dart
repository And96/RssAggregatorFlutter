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
        colorEnd: Color.fromARGB(255, 38, 50, 56),
        /* directionColorBegin: Alignment.center,
        directionColorEnd: Alignment.bottomCenter,*/
        marginDescription: EdgeInsets.all(2),
        widgetDescription: WelcomeSection(
          title: 'FastFeed',
          description:
              'Leggi le notizie dei tuoi siti preferiti in una unica applicazione.',
          icon: Icons.newspaper,
          color: Colors.white,
          centerAlign: true,
        ),
      ),
    );

    listContentConfig.add(
      const ContentConfig(
        colorBegin: Color.fromARGB(255, 16, 79, 175),
        colorEnd: Color.fromARGB(255, 16, 79, 175),
        /*directionColorBegin: Alignment.center,
        directionColorEnd: Alignment.center,*/
        marginDescription: EdgeInsets.all(2),
        widgetDescription: WelcomeSection(
          title: 'Configurazione',
          description:
              'Scegli le fonti di informazione.\nPuoi aggiungere i siti piu popolati o inserire manualmente i link da seguire.',
          icon: Icons.add_link,
          color: Colors.white,
          centerAlign: true,
        ),
      ),
    );

    listContentConfig.add(
      const ContentConfig(
        colorBegin: Color.fromARGB(255, 0, 77, 64),
        colorEnd: Color.fromARGB(255, 0, 77, 64),
        /* directionColorBegin: Alignment.center,
        directionColorEnd: Alignment.bottomCenter,*/
        marginDescription: EdgeInsets.all(2),
        widgetDescription: WelcomeSection(
          title: 'Funzionalita',
          description:
              'Troverai le notizie ordinate in elenco. Puoi aprirle nel browser, condividerle, salvarle nei preferiti, o leggerle piu tardi offline.',
          icon: Icons.local_activity,
          color: Colors.white,
          centerAlign: true,
        ),
      ),
    );

    listContentConfig.add(
      const ContentConfig(
        colorBegin: Color.fromARGB(255, 173, 20, 87),
        colorEnd: Color.fromARGB(255, 173, 20, 87),
        /*directionColorBegin: Alignment.center,
        directionColorEnd: Alignment.bottomCenter,*/
        marginDescription: EdgeInsets.all(2),
        widgetDescription: WelcomeSection(
          title: 'Personalizzabile',
          description:
              'Crea categorie, raggruppa notizie, personalizza colori, modalita scura e altre impostazioni.',
          icon: Icons.color_lens,
          color: Colors.white,
          centerAlign: true,
        ),
      ),
    );

    listContentConfig.add(
      const ContentConfig(
        colorBegin: Color.fromARGB(255, 38, 50, 56),
        colorEnd: Color.fromARGB(255, 38, 50, 56),
        /* directionColorBegin: Alignment.center,
        directionColorEnd: Alignment.bottomCenter,*/
        marginDescription: EdgeInsets.all(2),
        widgetDescription: WelcomeSection(
          title: 'Aggregator',
          description:
              '\n \u2023 Gratis\n \u2023 Senza pubblicità\n \u2023 Senza abbonamento',
          icon: Icons.newspaper,
          color: Colors.white,
          centerAlign: false,
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
            "",
            style: TextStyle(color: Colors.white),
          ),
          indicatorConfig: const IndicatorConfig(
            colorIndicator: Color.fromARGB(255, 255, 255, 255),
            typeIndicatorAnimation: TypeIndicatorAnimation.sizeTransition,
          ),
          isAutoScroll: false,
          isScrollable: true,
          isShowPrevBtn: true,
          scrollPhysics: const BouncingScrollPhysics(),
          isLoopAutoScroll: false,
          curveScroll: Curves.easeInCubic,
          backgroundColorAllTabs: Colors.black,
        ));
  }
}
