import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:rss_aggregator_flutter/widgets/welcome_section.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: OverBoard(
        pages: pages,
        showBullets: true,
        skipCallback: () {
          Navigator.pop(context);
        },
        finishCallback: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  final pages = [
    PageModel.withChild(
        child: const WelcomeSection(
          title: 'FastFeed',
          description: 'App per leggere le notizie',
          icon: Icons.newspaper,
          color: Colors.white,
        ),
        color: const Color.fromARGB(255, 49, 67, 96),
        doAnimateChild: true),
    PageModel.withChild(
        child: const WelcomeSection(
          title: 'Siti',
          description: 'See the increase in productivity & output',
          icon: Icons.add_link,
          color: Colors.white,
        ),
        color: const Color.fromARGB(255, 43, 75, 255),
        doAnimateChild: false),
    PageModel.withChild(
        child: const WelcomeSection(
          title: 'Categorie',
          description: 'Connect with the people from different places',
          icon: Icons.sell,
          color: Colors.white,
        ),
        color: const Color.fromARGB(255, 0, 85, 95),
        doAnimateChild: false),
    PageModel.withChild(
        child: const WelcomeSection(
          title: 'Personalizzabile',
          description: 'Imposta colori, preferiti e leggi piu tardi',
          icon: Icons.color_lens,
          color: Colors.white,
        ),
        color: const Color.fromARGB(255, 228, 95, 0),
        doAnimateChild: false),
    PageModel.withChild(
        child: const WelcomeSection(
          title: 'Pronti!',
          description: 'Premi fine per iniziare ad usare la applicazione',
          icon: Icons.factory_sharp,
          color: Colors.white,
        ),
        color: const Color.fromARGB(255, 49, 67, 96),
        doAnimateChild: true),
  ];
}
