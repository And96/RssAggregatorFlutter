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
          description:
              'Leggi le notizie dei tuoi siti preferiti in una unica applicazione',
          icon: Icons.newspaper,
          color: Colors.white,
        ),
        color: Colors.blueGrey[900],
        doAnimateChild: false),
    PageModel.withChild(
        child: const WelcomeSection(
          title: 'Scegli siti',
          description:
              'Impostati i siti da seguire, troverai in automatico le notizie ordinate',
          icon: Icons.add_link,
          color: Colors.white,
        ),
        color: Colors.lightBlue[900],
        doAnimateChild: false),
    PageModel.withChild(
        child: const WelcomeSection(
          title: 'Funzionalita',
          description:
              'Apri nel browser, salva preferiti, leggi piu tardi, condividi, lettura offline.',
          icon: Icons.local_activity,
          color: Colors.white,
        ),
        color: Colors.teal[900],
        doAnimateChild: false),
    PageModel.withChild(
        child: const WelcomeSection(
          title: 'Personalizzabile',
          description:
              'Crea categorie, raggruppa notizie, personalizza colori, modalita scura e altre impostazioni avanzate',
          icon: Icons.color_lens,
          color: Colors.white,
        ),
        color: Colors.pink[800],
        doAnimateChild: false),
    PageModel.withChild(
        child: const WelcomeSection(
          title: 'Pronti. Ci siamo!',
          description: '\nGratis!\n\n Senza pubblicita!\n\n Senza abbonamento!',
          icon: Icons.public,
          color: Colors.white,
        ),
        color: Colors.blueGrey[900],
        doAnimateChild: true),
  ];
}
