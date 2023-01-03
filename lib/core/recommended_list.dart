import 'dart:convert';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendedCategory {
  RecommendedCategory(
      this.name, this.color, this.iconData, this.language, this.sites);
  final String name;
  final int color;
  final int iconData;
  final String language;
  final List<RecommendedSite> sites;

  factory RecommendedCategory.fromJson(Map<String, dynamic> data) {
    final name = data['name'] as String;
    final color = data['color'] as int;
    final iconData = data['iconData'] as int;
    final language = data['language'] as String;
    final sitesData = data['sites'] as List<dynamic>?;
    final sites = sitesData != null
        ? sitesData
            .map((reviewData) => RecommendedSite.fromJson(reviewData))
            .toList()
        : <RecommendedSite>[];
    return RecommendedCategory(name, color, iconData, language, sites);
  }
}

class RecommendedSite {
  RecommendedSite(this.siteName, this.siteLink, this.iconUrl);
  final String siteName;
  final String siteLink;
  final String iconUrl;
  bool added = false;

  factory RecommendedSite.fromJson(Map<String, dynamic> data) {
    final siteName = data['siteName'] as String;
    final siteLink = data['siteLink'] as String;
    final iconUrl = data['iconUrl'] as String;
    return RecommendedSite(siteName, siteLink, iconUrl);
  }
}

class RecommendedList {
  late List<RecommendedCategory> items = [];

//validate json with https://jsonlint.com/
//for icons
//https://api.flutter.dev/flutter/material/Icons-class.html
//0xe50c icon must be converted to integer using online hex to convert https://www.binaryhexconverter.com/hex-to-decimal-converter

  String json = """[
  {
    "name": "News",
    "color": 4280693304,
    "iconData": 984385,
    "language": "italiano",
    "sites": [
      {
        "siteName": "ansa.it",
        "siteLink": "https://www.ansa.it/sito/ansait_rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ansa.it"
      },
      {
        "siteName": "ilpost.it",
        "siteLink": "https://www.ilpost.it/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilpost.it"
      },
      {
        "siteName": "open.online",
        "siteLink": "https://www.open.online/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=open.online"
      },
      {
        "siteName": "tg24.sky.it",
        "siteLink": "https://tg24.sky.it/rss/tg24_flipboard.cronaca.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tg24.sky.it"
      },
      {
        "siteName": "agi.it",
        "siteLink": "https://www.agi.it/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=agi.it"
      },
      {
        "siteName": "adnkronos.com",
        "siteLink": "https://adnkronos.com/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=adnkronos.com"
      },
      {
        "siteName": "tgcom24.mediaset.it",
        "siteLink": "https://tgcom24.mediaset.it/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tgcom24.mediaset.it"
      },
      {
        "siteName": "www.internazionale.it",
        "siteLink": "https://www.internazionale.it/sitemaps/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=www.internazionale.it"
      },
      {
        "siteName": "panorama.it",
        "siteLink": "https://www.panorama.it/feeds/news.rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=panorama.it"
      },
      {
        "siteName": "startmag.it",
        "siteLink": "https://www.startmag.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=startmag.it"
      },
      {
        "siteName": "termometropolitico.it",
        "siteLink": "https://www.termometropolitico.it/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=termometropolitico.it"
      },
      {
        "siteName": "la7.it",
        "siteLink": "https://news.google.com/rss/search?q=site:la7.it+when:2d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=la7.it"
      },
      {
        "siteName": "rainews.it",
        "siteLink": "https://www.rainews.it/rss/cronaca",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rainews.it"
      },
      {
        "siteName": "servizitelevideo.rai.it",
        "siteLink": "https://www.servizitelevideo.rai.it/televideo/pub/rss101.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rai.it"
      },
      {
        "siteName": "metronews.it",
        "siteLink": "https://metronews.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=metronews.it"
      },
      {
        "siteName": "miur.gov.it",
        "siteLink": "https://www.miur.gov.it/documents/20182/0/news-mi-rss.xml/2354a985-3d0c-f2df-1945-713c198bb8ad?t=1657029242222",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=miur.gov.it"
      },
      {
        "siteName": "ilsole24ore.com",
        "siteLink": "https://www.ilsole24ore.com/rss/italia--attualita.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilsole24ore.com"
      },
      {
        "siteName": "ilfattoquotidiano.it",
        "siteLink": "https://www.ilfattoquotidiano.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilfattoquotidiano.it"
      },
      {
        "siteName": "repubblica.it",
        "siteLink": "http://www.repubblica.it/rss/cronaca/rss2.0.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=repubblica.it"
      },
      {
        "siteName": "tpi.it",
        "siteLink": "https://tpi.it/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tpi.it"
      },
      {
        "siteName": "ilgiorno.it",
        "siteLink": "https://news.google.com/rss/search?q=site:ilgiorno.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilgiorno.it"
      }
    ]
  },
  {
    "name": "Curiosita",
    "color": 4289533015,
    "iconData": 984461,
    "language": "italiano",
    "sites": [
      {
        "siteName": "geopop.it",
        "siteLink": "https://www.geopop.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=geopop.it"
      },
      {
        "siteName": "thewom.it",
        "siteLink": "https://www.thewom.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=thewom.it"
      },
      {
        "siteName": "thevision.com",
        "siteLink": "https://thevision.com/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=thevision.com"
      },
      {
        "siteName": "wired.it",
        "siteLink": "https://www.wired.it/feed/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=wired.it"
      },
      {
        "siteName": "vice.com",
        "siteLink": "https://www.vice.com/it/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=vice.com"
      },
      {
        "siteName": "focus.it",
        "siteLink": "https://www.focus.it/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=focus.it"
      },
      {
        "siteName": "www.lescienze.it",
        "siteLink": "https://www.lescienze.it/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=www.lescienze.it"
      },
      {
        "siteName": "www.galileonet.it",
        "siteLink": "https://www.galileonet.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=www.galileonet.it"
      },
      {
        "siteName": "nationalgeographic.it",
        "siteLink": "https://news.google.com/rss/search?q=nationalgeographic.it+when:4d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=nationalgeographic.it"
      },
      {
        "siteName": "gqitalia.it",
        "siteLink": "https://www.gqitalia.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=gqitalia.it"
      },
      {
        "siteName": "rollingstone.it",
        "siteLink": "https://www.rollingstone.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rollingstone.it"
      },
      {
        "siteName": "ecoblog.it",
        "siteLink": "https://www.ecoblog.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ecoblog.it"
      },
      {
        "siteName": "attivissimo.blogspot.com",
        "siteLink": "https://feeds.feedburner.com/Disinformatico",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=attivissimo.blogspot.com"
      },
      {
        "siteName": "lescienze.it",
        "siteLink": "http://www.lescienze.it/rss/all/rss2.0.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lescienze.it"
      },
      {
        "siteName": "my-personaltrainer.it",
        "siteLink": "https://feeds.feedburner.com/My-personaltrainer/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=my-personaltrainer.it"
      },
      {
        "siteName": "stateofmind.it",
        "siteLink": "https://www.stateofmind.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=stateofmind.it"
      },
      {
        "siteName": "tantasalute.it",
        "siteLink": "https://www.tantasalute.it/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tantasalute.it"
      },
      {
        "siteName": "benessereblog.it",
        "siteLink": "https://www.benessereblog.it/rss2.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=benessereblog.it"
      },
      {
        "siteName": "efficacemente.com",
        "siteLink": "https://feeds2.feedburner.com/EfficaceMente",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=efficacemente.com"
      },
      {
        "siteName": "wikihow.it",
        "siteLink": "https://www.wikihow.it/feed.rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=wikihow.it"
      },
      {
        "siteName": "lamenteemeravigliosa.it",
        "siteLink": "https://lamenteemeravigliosa.it/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lamenteemeravigliosa.it"
      },
      {
        "siteName": "ninjamarketing.it",
        "siteLink": "https://www.ninjamarketing.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ninjamarketing.it"
      },
      {
        "siteName": "skuola.net",
        "siteLink": "https://www.skuola.net/rss.php",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=skuola.net"
      },
      {
        "siteName": "prevenzioneatavola.it",
        "siteLink": "https://blog.prevenzioneatavola.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=prevenzioneatavola.it"
      }
    ]
  },
  {
    "name": "Tecnologia",
    "color": 4283215696,
    "iconData": 58169,
    "language": "italiano",
    "sites": [
      {
        "siteName": "telefonino.net",
        "siteLink": "https://www.telefonino.net/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=telefonino.net"
      },
      {
        "siteName": "andreagaleazzi.com",
        "siteLink": "https://andreagaleazzi.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=andreagaleazzi.com"
      },
      {
        "siteName": "hdblog.it",
        "siteLink": "https://www.hdblog.it/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=hdblog.it/"
      },
      {
        "siteName": "tuttoandroid.net",
        "siteLink": "https://www.tuttoandroid.net/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tuttoandroid.net"
      },
      {
        "siteName": "androidworld.it",
        "siteLink": "https://www.androidworld.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=androidworld.it"
      },{
         "siteName": "xiaomitoday.it",
         "siteLink": "https://xiaomitoday.it/feed/",
         "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=xiaomitoday.it"
         },
      {
        "siteName": "batista70phone.com",
        "siteLink": "https://www.batista70phone.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=batista70phone.com"
      },
      {
        "siteName": "html.it",
        "siteLink": "https://www.html.it/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=html.it"
      },
      {
        "siteName": "ispazio.net",
        "siteLink": "https://feeds.feedburner.com/Ispazio",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ispazio.net"
      },
      {
        "siteName": "chimerarevo.com",
        "siteLink": "https://www.chimerarevo.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=chimerarevo.com"
      },
      {
        "siteName": "iphoneitalia.com",
        "siteLink": "https://www.iphoneitalia.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=iphoneitalia.com"
      },
      {
        "siteName": "multiplayer.it",
        "siteLink": "https://multiplayer.it/feed/rss/homepage/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=multiplayer.it"
      },
      {
        "siteName": "tomshw.it",
        "siteLink": "https://www.tomshw.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tomshw.it"
      },
      {
        "siteName": "zeusnews.it",
        "siteLink": "https://feeds.feedburner.com/ZeusNews",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=zeusnews.it"
      },
      {
        "siteName": "punto-informatico.it",
        "siteLink": "https://www.punto-informatico.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=punto-informatico.it"
      },
      {
        "siteName": "scubidu.eu",
        "siteLink": "https://scubidu.eu/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=scubidu.eu"
      },
      {
        "siteName": "mondo3.com",
        "siteLink": "https://mondo3.com/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mondo3.com"
      },
      {
        "siteName": "mondomobileweb.it",
        "siteLink": "https://www.mondomobileweb.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mondomobileweb.it"
      },
      {
        "siteName": "tariffando.it",
        "siteLink": "https://feeds.feedburner.com/Tariffando",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tariffando.it"
      },
      {
        "siteName": "universofree.com",
        "siteLink": "https://www.universofree.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=universofree.com"
      },
      {
        "siteName": "mvnonews.com",
        "siteLink": "https://www.mvnonews.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mvnonews.com"
      },
      {
        "siteName": "psbprivacyesicurezza.it",
        "siteLink": "https://www.psbprivacyesicurezza.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=psbprivacyesicurezza.it"
      },
      {
        "siteName": "amcomputers.org",
        "siteLink": "https://www.amcomputers.org/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=amcomputers.org"
      },
      {
        "siteName": "cryptonomist.ch",
        "siteLink": "https://cryptonomist.ch",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=cryptonomist.ch"
      },
      {
        "siteName": "socializziamo.net",
        "siteLink": "https://www.socializziamo.net/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=socializziamo.net"
      },
      {
        "siteName": "turbolab.it",
        "siteLink": "http://turbolab.it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=turbolab.it"
      },
      {
        "siteName": "italiancoders.it",
        "siteLink": "https://italiancoders.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=italiancoders.it"
      },
      {
        "siteName": "hackerjournal.it",
        "siteLink": "https://hackerjournal.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=hackerjournal.it"
      },
      {
        "siteName": "blog.kaspersky.it",
        "siteLink": "https://blog.kaspersky.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=blog.kaspersky.it"
      },
      {
        "siteName": "lffl.org",
        "siteLink": "https://www.lffl.org/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lffl.org"
      },
      {
        "siteName": "miamammausalinux.org",
        "siteLink": "https://www.miamammausalinux.org/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=miamammausalinux.org"
      },
      {
        "siteName": "ilsoftware.it",
        "siteLink": "https://www.bing.com/news/search?q=ilsoftware.it&qft=interval%3d%229%22+sortbydate%3d%221%22&form=PTFTNR&format=rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilsoftware.it"
      },
      {
        "siteName": "aranzulla.it",
        "siteLink": "https://www.aranzulla.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=aranzulla.it"
      },
      {
        "siteName": "mrwebmaster.it",
        "siteLink": "https://feeds.feedburner.com/Mr_Webmaster",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mrwebmaster.it"
      },
      {
        "siteName": "forum.mrwebmaster.it",
        "siteLink": "https://forum.mrwebmaster.it/forums/-/index.rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=forum.mrwebmaster.it"
      }
    ]
  },
  {
    "name": "Sport",
    "color": 4278223759,
    "iconData": 58857,
    "language": "italiano",
    "sites": [
      {
        "siteName": "gazzetta.it",
        "siteLink": "https://www.gazzetta.it/rss/home.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=gazzetta.it"
      },
      {
        "siteName": "sport.sky.it",
        "siteLink": "https://news.google.com/rss/search?q=site:sport.sky.it+when:2d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=sport.sky.it"
      },
      {
        "siteName": "oasport.it",
        "siteLink": "https://www.oasport.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=oasport.it"
      },
      {
        "siteName": "sport.rai.it",
        "siteLink": "https://www.rainews.it/rss/sport",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rainews.it"
      },
      {
        "siteName": "sportmediaset.mediaset.it",
        "siteLink": "https://sportmediaset.mediaset.it/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=sportmediaset.mediaset.it"
      },
      {
        "siteName": "corrieredellosport.it",
        "siteLink": "https://corrieredellosport.it/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=corrieredellosport.it"
      },
      {
        "siteName": "sport.virgilio.it",
        "siteLink": "https://news.google.com/rss/search?q=site:sport.virgilio.it+when:2d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=sport.virgilio.it"
      },
      {
        "siteName": "fantacalcio.it",
        "siteLink": "https://news.google.com/rss/search?q=site:fantacalcio.it+when:2d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fantacalcio.it"
      },
      {
        "siteName": "sportitalia.com",
        "siteLink": "https://news.google.com/rss/search?q=site:sportitalia.com+when:2d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=sportitalia.com"
      }
    ]
  },
  {
    "name": "Calcio",
    "color": 4278351805,
    "iconData": 984769,
    "language": "italiano",
    "sites": [
      {
        "siteName": "calciomercato.com",
        "siteLink": "https://www.calciomercato.com/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=calciomercato.com"
      },
      {
        "siteName": "tuttomercatoweb.com",
        "siteLink": "https://news.google.com/rss/search?q=site:tuttomercatoweb.com+when:1d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tuttomercatoweb.com"
      },
      {
        "siteName": "transfermarkt.it",
        "siteLink": "https://news.google.com/rss/search?q=site:transfermarkt.it+when:2d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=transfermarkt.it"
      },
      {
        "siteName": "gianlucadimarzio.com",
        "siteLink": "https://gianlucadimarzio.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=gianlucadimarzio.com"
      },
      {
        "siteName": "alfredopedulla.com",
        "siteLink": "https://www.alfredopedulla.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=alfredopedulla.com"
      },
      {
        "siteName": "numero-diez.com",
        "siteLink": "https://www.numero-diez.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=numero-diez.com"
      },
      {
        "siteName": "goal.com",
        "siteLink": "https://news.google.com/rss/search?q=site:goal.com+when:2d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=goal.com"
      },
      {
        "siteName": "calcionews24.com",
        "siteLink": "https://www.calcionews24.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=calcionews24.com"
      },
      {
        "siteName": "calciostyle.it",
        "siteLink": "https://www.calciostyle.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=calciostyle.it"
      },
      {
        "siteName": "calcioblog.it",
        "siteLink": "https://www.calcioblog.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=calcioblog.it"
      }
    ]
  },
  {
    "name": "Motori",
    "color": 4291176488,
    "iconData": 983491,
    "language": "italiano",
    "sites": [
      {
        "siteName": "formulapassion.it",
        "siteLink": "https://www.formulapassion.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=formulapassion.it"
      },
      {
        "siteName": "circusf1.com",
        "siteLink": "https://www.circusf1.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=circusf1.com"
      },
      {
        "siteName": "it.motorsport.com",
        "siteLink": "https://news.google.com/rss/search?q=site:it.motorsport.com+when:2d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=motorsport.com"
      },
      {
        "siteName": "f1ingenerale.com",
        "siteLink": "https://f1ingenerale.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=f1ingenerale.com"
      },
      {
        "siteName": "newsf1.it",
        "siteLink": "https://www.newsf1.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=newsf1.it"
      },
      {
        "siteName": "f1grandprix.motorionline.com",
        "siteLink": "https://f1grandprix.motorionline.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=motorionline.com"
      },
      {
        "siteName": "funoanalisitecnica.com",
        "siteLink": "https://www.funoanalisitecnica.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=funoanalisitecnica.com"
      },
      {
        "siteName": "f1sport.it",
        "siteLink": "https://www.f1sport.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=f1sport.it"
      },
      {
        "siteName": "giornalemotori.com",
        "siteLink": "https://www.giornalemotori.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=giornalemotori.com"
      },
      {
        "siteName": "f1world.it",
        "siteLink": "https://www.f1world.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=f1world.it"
      },
      {
        "siteName": "gpone.com",
        "siteLink": "https://www.gpone.com/it/article-feed.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=gpone.com"
      },
      {
        "siteName": "formula1.it",
        "siteLink": "https://news.google.com/rss/search?q=site:formula1.it+when:2d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=formula1.it"
      },
      {
        "siteName": "motoblog.it",
        "siteLink": "https://www.motoblog.it/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=motoblog.it"
      },
      {
        "siteName": "rallyssimo.it",
        "siteLink": "https://www.rallyssimo.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rallyssimo.it"
      },
      {
        "siteName": "it.motor1.com",
        "siteLink": "https://it.motor1.com/rss/news/all/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=it.motor1.com"
      },
      {
        "siteName": "alvolante.it",
        "siteLink": "https://www.alvolante.it/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=alvolante.it"
      },
      {
        "siteName": "automoto.it",
        "siteLink": "https://news.google.com/rss/search?q=site:automoto.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=automoto.it"
      },
      {
        "siteName": "livegp.it",
        "siteLink": "https://livegp.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=livegp.it"
      },
      {
        "siteName": "motorbox.com",
        "siteLink": "https://www.motorbox.com/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=motorbox.com"
      },
      {
        "siteName": "motors-addict.com",
        "siteLink": "https://www.motors-addict.com/it/58a31a66cac90d3222644a47/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=motors-addict.com"
      },
      {
        "siteName": "newsauto.it",
        "siteLink": "https://newsauto.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=newsauto.it"
      },
      {
        "siteName": "rally.it",
        "siteLink": "https://www.rally.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rally.it"
      },
      {
        "siteName": "rallyeslalom.com",
        "siteLink": "https://www.rallyeslalom.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rallyeslalom.com"
      },
      {
        "siteName": "rallytime.eu",
        "siteLink": "https://www.rallytime.eu/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rallytime.eu"
      },
      {
        "siteName": "veloce.it",
        "siteLink": "https://veloce.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=veloce.it"
      }
    ]
  },
  {
    "name": "Economia",
    "color": 4283315246,
    "iconData": 57628,
    "language": "italiano",
    "sites": [
      {
        "siteName": "money.it",
        "siteLink": "https://news.google.com/rss/search?q=site:money.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=money.it"
      },
      {
        "siteName": "milanofinanza.it",
        "siteLink": "https://news.google.com/rss/search?q=site:milanofinanza.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=milanofinanza.it"
      },
      {
        "siteName": "borsaefinanza.it",
        "siteLink": "https://borsaefinanza.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=borsaefinanza.it"
      },
      {
        "siteName": "borsaitaliana.it",
        "siteLink": "https://news.google.com/rss/search?q=site:borsaitaliana.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=borsaitaliana.it"
      },
      {
        "siteName": "finanza.com",
        "siteLink": "https://www.finanza.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=finanza.com"
      },
      {
        "siteName": "finanzacafona.it/feed",
        "siteLink": "https://finanzacafona.it/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=finanzacafona.it/feed"
      },
      {
        "siteName": "finanzaonline.com",
        "siteLink": "https://www.finanzaonline.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=finanzaonline.com"
      },
      {
        "siteName": "gov.it",
        "siteLink": "https://news.google.com/rss/search?q=site:gov.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=gov.it"
      },
      {
        "siteName": "quifinanza.it",
        "siteLink": "https://quifinanza.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=quifinanza.it"
      },
      {
        "siteName": "it.finance.yahoo.com",
        "siteLink": "https://it.finance.yahoo.com/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=it.finance.yahoo.com"
      },
      {
        "siteName": "soldionline.it",
        "siteLink": "https://www.soldionline.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=soldionline.it"
      },
      {
        "siteName": "teleborsa.it",
        "siteLink": "https://www.teleborsa.it/feed/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=teleborsa.it"
      },
      {
        "siteName": "wallstreetitalia.com",
        "siteLink": "https://www.wallstreetitalia.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=wallstreetitalia.com"
      },
      {
        "siteName": "affarimiei.biz",
        "siteLink": "https://news.google.com/rss/search?q=site:affarimiei.biz+when:30d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=affarimiei.biz"
      },
      {
        "siteName": "addlance.com",
        "siteLink": "https://www.addlance.com/blog/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=addlance.com"
      },
      {
        "siteName": "agendadigitale.eu",
        "siteLink": "https://www.agendadigitale.eu/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=agendadigitale.eu"
      },
      {
        "siteName": "biancolavoro.it",
        "siteLink": "https://news.biancolavoro.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=biancolavoro.it"
      },
      {
        "siteName": "retireinprogress.com",
        "siteLink": "https://retireinprogress.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=retireinprogress.com"
      },
      {
        "siteName": "enterprise.teamsystem.com",
        "siteLink": "https://enterprise.teamsystem.com/blog/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=teamsystem.com"
      },
      {
        "siteName": "corrierecomunicazioni.it",
        "siteLink": "https://www.corrierecomunicazioni.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=corrierecomunicazioni.it"
      },
      {
        "siteName": "cybersecurity360.it",
        "siteLink": "https://www.cybersecurity360.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=cybersecurity360.it"
      },
      {
        "siteName": "danea.it",
        "siteLink": "https://www.danea.it/blog/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=danea.it"
      },
      {
        "siteName": "digital-coach.it",
        "siteLink": "https://www.digital-coach.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=digital-coach.it"
      },
      {
        "siteName": "digital4.biz",
        "siteLink": "https://www.digital4.biz/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=digital4.biz"
      },
      {
        "siteName": "economyup.it",
        "siteLink": "https://www.economyup.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=economyup.it"
      },
      {
        "siteName": "educazionefinanziaria.com",
        "siteLink": "https://www.educazionefinanziaria.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=educazionefinanziaria.com"
      },
      {
        "siteName": "financecue.it",
        "siteLink": "https://financecue.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=financecue.it"
      },
      {
        "siteName": "fisco7.it",
        "siteLink": "https://www.fisco7.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fisco7.it"
      },
      {
        "siteName": "fiscomania.com",
        "siteLink": "https://fiscomania.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fiscomania.com"
      },
      {
        "siteName": "fortuneita.com",
        "siteLink": "https://www.fortuneita.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fortuneita.com"
      },
      {
        "siteName": "fiscozen.it",
        "siteLink": "https://blog.fiscozen.it/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fiscozen.it"
      },
      {
        "siteName": "iprogrammatori.it",
        "siteLink": "https://www.iprogrammatori.it/rss/offerte-di-lavoro.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=iprogrammatori.it"
      },
      {
        "siteName": "ilcommercialistaonline.it",
        "siteLink": "https://www.ilcommercialistaonline.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilcommercialistaonline.it"
      },
      {
        "siteName": "impresalavoro.eu",
        "siteLink": "https://www.impresalavoro.eu/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=impresalavoro.eu"
      },
      {
        "siteName": "intraprendere.net/feed/",
        "siteLink": "https://intraprendere.net/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=intraprendere.net/feed/"
      },
      {
        "siteName": "jobrapido.com",
        "siteLink": "https://it.jobrapido.com/blog/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=jobrapido.com"
      },
      {
        "siteName": "laramind.com",
        "siteLink": "https://www.laramind.com/blog/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=laramind.com"
      },
      {
        "siteName": "lavoroediritti.com",
        "siteLink": "https://www.lavoroediritti.com/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lavoroediritti.com"
      },
      {
        "siteName": "leggioggi.it",
        "siteLink": "https://www.leggioggi.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=leggioggi.it"
      },
      {
        "siteName": "logisticaefficiente.it",
        "siteLink": "https://www.logisticaefficiente.it/supply-chain-management/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=logisticaefficiente.it"
      },
      {
        "siteName": "mark-up.it",
        "siteLink": "https://www.mark-up.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mark-up.it"
      },
      {
        "siteName": "wearemarketers.net",
        "siteLink": "https://wearemarketers.net/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=wearemarketers.net"
      },
      {
        "siteName": "mondolavoro.it",
        "siteLink": "https://www.mondolavoro.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mondolavoro.it"
      },
      {
        "siteName": "moneyfarm.com",
        "siteLink": "https://blog.moneyfarm.com/it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=moneyfarm.com"
      },
      {
        "siteName": "partitaiva24.it",
        "siteLink": "https://www.partitaiva24.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=partitaiva24.it"
      },
      {
        "siteName": "performancestrategies.it",
        "siteLink": "https://www.performancestrategies.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=performancestrategies.it"
      },
      {
        "siteName": "regime-forfettario.it",
        "siteLink": "https://www.regime-forfettario.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=regime-forfettario.it"
      },
      {
        "siteName": "scuolainsoffitta.com",
        "siteLink": "https://scuolainsoffitta.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=scuolainsoffitta.com"
      },
      {
        "siteName": "spremutedigitali.com",
        "siteLink": "https://spremutedigitali.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=spremutedigitali.com"
      },
      {
        "siteName": "starbytes.it",
        "siteLink": "https://www.starbytes.it/blog/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=starbytes.it"
      },
      {
        "siteName": "tasse-fisco.com",
        "siteLink": "https://www.tasse-fisco.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tasse-fisco.com"
      },
      {
        "siteName": "zerounoweb.it",
        "siteLink": "https://www.zerounoweb.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=zerounoweb.it"
      },
      {
        "siteName": "fiscooggi.it",
        "siteLink": "https://www.fiscooggi.it/feed/rubrica/attualita",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fiscooggi.it"
      },
      {
        "siteName": "fiscooggi.it",
        "siteLink": "https://www.fiscooggi.it/feed/rubrica/normativa-e-prassi",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fiscooggi.it"
      },
      {
        "siteName": "skande.com",
        "siteLink": "https://www.skande.com/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=skande.com"
      },
      {
        "siteName": "alfiobardolla.com",
        "siteLink": "https://www.alfiobardolla.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=alfiobardolla.com"
      },
      {
        "siteName": "negoziazione.blog",
        "siteLink": "http://negoziazione.blog/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=negoziazione.blog"
      },
      {
        "siteName": "pmi.it",
        "siteLink": "https://www.pmi.it/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=pmi.it"
      },
      {
        "siteName": "investireoggi.it",
        "siteLink": "https://news.google.com/rss/search?q=site:investireoggi.it+when:2d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=investireoggi.it"
      }
    ]
  },
  {
    "name": "Musica",
    "color": 4293880832,
    "iconData": 58389,
    "language": "italiano",
    "sites": [
      {
        "siteName": "airmag.it",
        "siteLink": "https://www.airmag.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=airmag.it"
      },
      {
        "siteName": "hano.it",
        "siteLink": "https://www.hano.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=hano.it"
      },
      {
        "siteName": "blogdellamusica.eu",
        "siteLink": "https://www.blogdellamusica.eu/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=blogdellamusica.eu"
      },
      {
        "siteName": "rockit.it",
        "siteLink": "https://news.google.com/rss/search?q=site:rockit.it+when:5d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rockit.it"
      },
      {
        "siteName": "dlso.it",
        "siteLink": "https://www.dlso.it/site/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=dlso.it"
      },
      {
        "siteName": "parkettchannel.it",
        "siteLink": "https://www.parkettchannel.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=parkettchannel.it"
      },
      {
        "siteName": "rockol.it",
        "siteLink": "https://news.google.com/rss/search?q=site:rockol.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rockol.it"
      },
      {
        "siteName": "sentireascoltare.com",
        "siteLink": "https://www.sentireascoltare.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=sentireascoltare.com"
      },
      {
        "siteName": "soundsblog.it",
        "siteLink": "https://www.soundsblog.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=soundsblog.it"
      },
      {
        "siteName": "soundwall.it",
        "siteLink": "https://www.soundwall.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=soundwall.it"
      },
      {
        "siteName": "spaziorock.it",
        "siteLink": "https://www.spaziorock.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=spaziorock.it"
      },
      {
        "siteName": "allmusicitalia.it",
        "siteLink": "https://www.allmusicitalia.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=allmusicitalia.it"
      },
      {
        "siteName": "deejay.it",
        "siteLink": "https://www.deejay.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=deejay.it"
      },
      {
        "siteName": "imusicfun.it",
        "siteLink": "https://www.imusicfun.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=imusicfun.it"
      },
      {
        "siteName": "mbmusic.it",
        "siteLink": "https://www.mbmusic.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mbmusic.it"
      }
    ]
  },
  {
    "name": "Cibo",
    "color": 4294551589,
    "iconData": 57946,
    "language": "italiano",
    "sites": [
      {
        "siteName": "giallozafferano.it",
        "siteLink": "https://www.giallozafferano.it/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=giallozafferano.it"
      },
      {
        "siteName": "agrodolce.it",
        "siteLink": "https://www.agrodolce.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=agrodolce.it"
      },
      {
        "siteName": "dissapore.com",
        "siteLink": "https://news.google.com/rss/search?q=site:dissapore.com+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=dissapore.com"
      },
      {
        "siteName": "misya.info",
        "siteLink": "https://www.misya.info/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=misya.info"
      },
      {
        "siteName": "piuricette.it",
        "siteLink": "https://www.piuricette.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=piuricette.it"
      },
      {
        "siteName": "cibochepassioneblog.it",
        "siteLink": "https://cibochepassioneblog.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=cibochepassioneblog.it"
      },
      {
        "siteName": "cookingwithsere.it",
        "siteLink": "https://www.cookingwithsere.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=cookingwithsere.it"
      },
      {
        "siteName": "lacucinachevale.com",
        "siteLink": "https://www.lacucinachevale.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lacucinachevale.com"
      },
      {
        "siteName": "lucianopignataro.it",
        "siteLink": "https://www.lucianopignataro.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lucianopignataro.it"
      }
    ]
  },
  {
    "name": "Viaggi",
    "color": 4283045004,
    "iconData": 58131,
    "language": "italiano",
    "sites": [
      {
        "siteName": "agendaonline.it",
        "siteLink": "https://www.agendaonline.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=agendaonline.it"
      },
      {
        "siteName": "viaggi.corriere.it",
        "siteLink": "https://viaggi.corriere.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=viaggi.corriere.it"
      },
      {
        "siteName": "viaggiamo.it",
        "siteLink": "https://www.viaggiamo.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=viaggiamo.it"
      },
      {
        "siteName": "archetravel.com",
        "siteLink": "https://www.archetravel.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=archetravel.com"
      },
      {
        "siteName": "siviaggia.it",
        "siteLink": "https://siviaggia.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=siviaggia.it"
      },
      {
        "siteName": "guidaviaggi.it",
        "siteLink": "https://www.guidaviaggi.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=guidaviaggi.it"
      },
      {
        "siteName": "dovevado.net",
        "siteLink": "https://dovevado.net/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=dovevado.net"
      },
      {
        "siteName": "inviaggioconmonica.it",
        "siteLink": "https://www.inviaggioconmonica.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=inviaggioconmonica.it"
      },
      {
        "siteName": "inviaggiodasola.com",
        "siteLink": "https://inviaggiodasola.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=inviaggiodasola.com"
      },
      {
        "siteName": "nonsoloturisti.it",
        "siteLink": "https://nonsoloturisti.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=nonsoloturisti.it"
      },
      {
        "siteName": "thelostavocado.com",
        "siteLink": "https://www.thelostavocado.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=thelostavocado.com"
      },
      {
        "siteName": "viaggiare-low-cost.it",
        "siteLink": "https://www.bing.com/news/search?q=viaggiare-low-cost.it&qft=interval%3d%229%22+sortbydate%3d%221%22&form=PTFTNR&format=rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=viaggiare-low-cost.it"
      },
      {
        "siteName": "in-lombardia.it",
        "siteLink": "https://news.google.com/rss/search?q=site:in-lombardia.it&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=in-lombardia.it"
      }
    ]
  },
  {
    "name": "TV",
    "color": 4286259106,
    "iconData": 57943,
    "language": "italiano",
    "sites": [
      {
        "siteName": "badtaste.it",
        "siteLink": "https://www.badtaste.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=badtaste.it"
      },
      {
        "siteName": "davidemaggio.it",
        "siteLink": "https://feeds.feedburner.com/DavideMaggio",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=davidemaggio.it"
      },
      {
        "siteName": "digital-news.it",
        "siteLink": "https://www.digital-news.it/rss.php",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=digital-news.it"
      },
      {
        "siteName": "hallofseries.com",
        "siteLink": "https://www.hallofseries.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=hallofseries.com"
      },
      {
        "siteName": "recenserie.com",
        "siteLink": "https://recenserie.com/feed",
        "iconUrl": "https://icons.duckduckgo.com/ip3/recenserie.com.ico"
      },
      {
        "siteName": "serialminds.com",
        "siteLink": "https://feeds.feedburner.com/serialminds",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=serialminds.com"
      },
      {
        "siteName": "tvblog.it",
        "siteLink": "https://www.tvblog.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tvblog.it"
      },
      {
        "siteName": "gossipblog.it",
        "siteLink": "https://www.gossipblog.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=gossipblog.it"
      },
      {
        "siteName": "televisionando.it",
        "siteLink": "https://news.google.com/rss/search?q=site:televisionando.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=televisionando.it"
      },
      {
        "siteName": "webl0g.net",
        "siteLink": "https://www.webl0g.net/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=webl0g.net"
      },
      {
        "siteName": "movietele.it",
        "siteLink": "https://news.google.com/rss/search?q=site:movietele.it+when:4d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=movietele.it"
      }
    ]
  },
  {
    "name": "Bergamo",
    "color": 4278217052,
    "iconData": 61871,
    "language": "italiano",
    "sites": [
      {
        "siteName": "ecodibergamo.it",
        "siteLink": "https://www.ecodibergamo.it/feeds/latesthp/268/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ecodibergamo.it"
      },
      {
        "siteName": "bergamonews.it",
        "siteLink": "http://www.bergamonews.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=bergamonews.it"
      },
      {
        "siteName": "lavocedellevalli.it",
        "siteLink": "https://www.lavocedellevalli.it/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lavocedellevalli.it"
      },
      {
        "siteName": "primabergamo.it",
        "siteLink": "https://primabergamo.it/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=primabergamo.it"
      },
      {
        "siteName": "araberara.it",
        "siteLink": "https://araberara.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=araberara.it"
      },
      {
        "siteName": "bgreport.org",
        "siteLink": "https://bgreport.org/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=bgreport.org"
      },
      {
        "siteName": "bergamo.corriere.it",
        "siteLink": "http://xml2.corriereobjects.it/rss/homepage_bergamo.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=corriere.it"
      },
      {
        "siteName": "myvalley.it",
        "siteLink": "https://myvalley.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=myvalley.it"
      },
      {
        "siteName": "orobie.it",
        "siteLink": "https://www.orobie.it/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=orobie.it"
      },
      {
        "siteName": "primatreviglio.it",
        "siteLink": "https://primatreviglio.it/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=primatreviglio.it"
      },
      {
        "siteName": "socialbg.it",
        "siteLink": "https://www.socialbg.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=socialbg.it"
      },
      {
        "siteName": "valbrembanaweb.com",
        "siteLink": "https://www.valbrembanaweb.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=valbrembanaweb.com"
      },
      {
        "siteName": "valseriananews.it",
        "siteLink": "https://www.valseriananews.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=valseriananews.it"
      },
      {
        "siteName": "visitnembro.it",
        "siteLink": "https://visitnembro.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=visitnembro.it"
      },
      {
        "siteName": "bergamo.it",
        "siteLink": "https://news.google.com/rss/search?q=site:bergamo.it+when:10d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=comune.bergamo.it"
      },
      {
        "siteName": "bergamoesport.it",
        "siteLink": "https://www.bergamoesport.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=bergamoesport.it"
      },
      {
        "siteName": "visitbergamo.net",
        "siteLink": "https://news.google.com/rss/search?q=site:visitbergamo.net&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=visitbergamo.net"
      },
      {
        "siteName": "comunedibergamo.medium.com",
        "siteLink": "https://comunedibergamo.medium.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=comunedibergamo.medium.com"
      },
      {
        "siteName": "bg.camcom.it",
        "siteLink": "https://www.bg.camcom.it/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=bg.camcom.it"
      },
      {
        "siteName": "valseriana.eu/eventi",
        "siteLink": "https://www.valseriana.eu/eventi/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=valseriana.eu"
      },
      {
        "siteName": "valseriana.eu",
        "siteLink": "https://news.google.com/rss/search?q=site:valseriana.eu&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=valseriana.eu"
      },
      {
        "siteName": "cristianriva.it",
        "siteLink": "https://www.cristianriva.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=cristianriva.it"
      },
      {
        "siteName": "orobiestyle.com",
        "siteLink": "https://www.orobiestyle.com/blog/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=orobiestyle.com"
      }
    ]
  },
  {
    "name": "Milano",
    "color": 4281408402,
    "iconData": 57907,
    "language": "italiano",
    "sites": [
      {
        "siteName": "citymilano.com",
        "siteLink": "https://citymilano.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=citymilano.com"
      },
      {
        "siteName": "comune.milano.it",
        "siteLink": "https://news.google.com/rss/search?q=site:comune.milano.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=comune.milano.it"
      },
      {
        "siteName": "eventimilano.it",
        "siteLink": "https://www.eventimilano.it/news-milano/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=eventimilano.it"
      },
      {
        "siteName": "giornaledeinavigli.it",
        "siteLink": "https://giornaledeinavigli.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=giornaledeinavigli.it"
      },
      {
        "siteName": "ilgazzettinometropolitano.it",
        "siteLink": "https://www.ilgazzettinometropolitano.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilgazzettinometropolitano.it"
      },
      {
        "siteName": "lamilano.it",
        "siteLink": "https://lamilano.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lamilano.it"
      },
      {
        "siteName": "metronews.it",
        "siteLink": "https://metronews.it/cronaca-milano/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=metronews.it"
      },
      {
        "siteName": "milano.it",
        "siteLink": "https://news.google.com/rss/search?q=site:milano.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=milano.it"
      },
      {
        "siteName": "milano.notizie.it",
        "siteLink": "https://milano.notizie.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=milano.notizie.it"
      },
      {
        "siteName": "milanoevents.it",
        "siteLink": "https://milanoevents.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=milanoevents.it"
      },
      {
        "siteName": "milanofree.it",
        "siteLink": "https://www.milanofree.it/feed/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=milanofree.it"
      },
      {
        "siteName": "milanosud.it",
        "siteLink": "https://www.milanosud.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=milanosud.it"
      },
      {
        "siteName": "milanotoday.it",
        "siteLink": "https://www.milanotoday.it/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=milanotoday.it"
      },
      {
        "siteName": "primadituttomilano.it",
        "siteLink": "https://primadituttomilano.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=primadituttomilano.it"
      },
      {
        "siteName": "primamilanoovest.it",
        "siteLink": "https://primamilanoovest.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=primamilanoovest.it"
      },
      {
        "siteName": "quindicinews.it",
        "siteLink": "https://www.quindicinews.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=quindicinews.it"
      },
      {
        "siteName": "serravalle.it",
        "siteLink": "https://www.bing.com/news/search?q=serravalle.it&qft=interval%3d%229%22+sortbydate%3d%221%22&form=PTFTNR&format=rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=serravalle.it"
      }
    ]
  },
  {
    "name": "Roma",
    "color": 4292363029,
    "iconData": 58280,
    "language": "italiano",
    "sites": [
      {
        "siteName": "ilcorrieredellacitta.com",
        "siteLink": "https://www.ilcorrieredellacitta.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilcorrieredellacitta.com"
      },
      {
        "siteName": "lacronacadiroma.it",
        "siteLink": "https://www.lacronacadiroma.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lacronacadiroma.it"
      },
      {
        "siteName": "romadailynews.it",
        "siteLink": "https://www.romadailynews.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=romadailynews.it"
      },
      {
        "siteName": "romaedintorninotizie.it",
        "siteLink": "https://www.romaedintorninotizie.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=romaedintorninotizie.it"
      },
      {
        "siteName": "romanews.eu",
        "siteLink": "https://www.romanews.eu/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=romanews.eu"
      },
      {
        "siteName": "romatoday.it",
        "siteLink": "https://www.romatoday.it/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=romatoday.it"
      }
    ]
  },
  {
    "name": "Torino",
    "color": 4283315246,
    "iconData": 59068,
    "language": "italiano",
    "sites": [
      {
        "siteName": "cronacaqui.it",
        "siteLink": "https://cronacaqui.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=cronacaqui.it"
      },
      {
        "siteName": "primatorino.it",
        "siteLink": "https://primatorino.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=primatorino.it"
      },
      {
        "siteName": "torinoggi.it",
        "siteLink": "https://www.torinoggi.it/links/rss/argomenti/torinoggiit/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=torinoggi.it"
      },
      {
        "siteName": "torinonews24.it",
        "siteLink": "https://news.google.com/rss/search?q=site:torinonews24.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=torinonews24.it"
      },
      {
        "siteName": "torinotoday.it",
        "siteLink": "https://www.torinotoday.it/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=torinotoday.it"
      }
    ]
  },
  {
    "name": "Inter",
    "color": 4279060385,
    "iconData": 58866,
    "language": "italiano",
    "sites": [
      {
        "siteName": "calciomercato.com",
        "siteLink": "https://www.calciomercato.com/feed/teams/inter",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=calciomercato.com"
      },
      {
        "siteName": "inter.it",
        "siteLink": "https://news.google.com/rss/search?q=site:inter.it+when:15d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=inter.it"
      },
      {
        "siteName": "fcinternews.it",
        "siteLink": "https://www.fcinternews.it/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fcinternews.it"
      },
      {
        "siteName": "fcinter1908.it",
        "siteLink": "https://www.fcinter1908.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fcinter1908.it"
      },
      {
        "siteName": "passioneinter.com",
        "siteLink": "https://www.passioneinter.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=passioneinter.com"
      },
      {
        "siteName": "interlive.it",
        "siteLink": "https://interlive.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=interlive.it"
      },
      {
        "siteName": "internews24.com",
        "siteLink": "https://www.internews24.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=internews24.com"
      },
      {
        "siteName": "inter-news.it",
        "siteLink": "https://www.inter-news.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=inter-news.it"
      },
      {
        "siteName": "interdipendenza.net",
        "siteLink": "https://www.interdipendenza.net/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=interdipendenza.net"
      },
      {
        "siteName": "iminter.it",
        "siteLink": "https://www.iminter.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=iminter.it"
      },
      {
        "siteName": "fcitalia.com",
        "siteLink": "https://www.fcitalia.com/feed/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fcitalia.com"
      },
      {
        "siteName": "iotifointer.it",
        "siteLink": "https://www.iotifointer.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=iotifointer.it"
      },
      {
        "siteName": "bausciacafe.com",
        "siteLink": "https://www.bausciacafe.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=bausciacafe.com"
      }
    ]
  },
  {
    "name": "Milan",
    "color": 4291176488,
    "iconData": 58866,
    "language": "italiano",
    "sites": [
      {
        "siteName": "acmilan.com",
        "siteLink": "https://news.google.com/rss/search?q=site:acmilan.com+when:7d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=acmilan.com"
      },
      {
        "siteName": "ilmilanista.it",
        "siteLink": "https://www.ilmilanista.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilmilanista.it"
      },
      {
        "siteName": "magliarossonera.it",
        "siteLink": "https://www.bing.com/news/search?q=magliarossonera.it&qft=interval%3d%229%22+sortbydate%3d%221%22&form=PTFTNR&format=rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=magliarossonera.it"
      },
      {
        "siteName": "milanlive.it",
        "siteLink": "https://www.milanlive.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=milanlive.it"
      },
      {
        "siteName": "milannews.it",
        "siteLink": "https://www.milannews.it/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=milannews.it"
      },
      {
        "siteName": "milannews24.com",
        "siteLink": "https://www.milannews24.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=milannews24.com"
      },
      {
        "siteName": "pianetamilan.it",
        "siteLink": "https://www.pianetamilan.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=pianetamilan.it"
      },
      {
        "siteName": "spaziomilan.it",
        "siteLink": "https://www.spaziomilan.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=spaziomilan.it"
      }
    ]
  },
  {
    "name": "Juventus",
    "color": 4284513675,
    "iconData": 58866,
    "language": "italiano",
    "sites": [
      {
        "siteName": "juventus.com",
        "siteLink": "https://news.google.com/rss/search?q=site:juventus.com+when:10d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=juventus.com"
      },
      {
        "siteName": "bianconeranews.it",
        "siteLink": "https://www.bianconeranews.it/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=bianconeranews.it"
      },
      {
        "siteName": "ilbianconero.com",
        "siteLink": "https://news.google.com/rss/search?q=site:ilbianconero.com+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilbianconero.com"
      },
      {
        "siteName": "juvenews.eu",
        "siteLink": "https://www.juvenews.eu/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=juvenews.eu"
      },
      {
        "siteName": "juvefc.com",
        "siteLink": "https://www.juvefc.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=juvefc.com"
      },
      {
        "siteName": "juvelive.it",
        "siteLink": "https://www.juvelive.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=juvelive.it"
      },
      {
        "siteName": "spazioj.it",
        "siteLink": "https://www.spazioj.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=spazioj.it"
      },
      {
        "siteName": "tifojuventus.it",
        "siteLink": "https://www.tifojuventus.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tifojuventus.it"
      },
      {
        "siteName": "tuttojuve.com",
        "siteLink": "https://www.tuttojuve.com/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tuttojuve.com"
      },
      {
        "siteName": "juventusnews24.com",
        "siteLink": "https://www.juventusnews24.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=juventusnews24.com"
      },
      {
        "siteName": "tuttojuve24.it",
        "siteLink": "https://tuttojuve24.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tuttojuve24.it"
      },
      {
        "siteName": "mondobianconero.com",
        "siteLink": "https://mondobianconero.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mondobianconero.com"
      }
    ]
  },
  {
    "name": "Atalanta",
    "color": 4279903102,
    "iconData": 58866,
    "language": "italiano",
    "sites": [
      {
        "siteName": "atalanta.it",
        "siteLink": "https://news.google.com/rss/search?q=site:atalanta.it+when:3d&hl=it&gl=IT&ceid=IT:it",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=atalanta.it"
      },
      {
        "siteName": "atalantini.online",
        "siteLink": "https://www.atalantini.online/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=atalantini.online"
      },
      {
        "siteName": "calcioatalanta.it",
        "siteLink": "https://www.calcioatalanta.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=calcioatalanta.it"
      },
      {
        "siteName": "diarionerazzurro.it",
        "siteLink": "https://www.diarionerazzurro.it/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=diarionerazzurro.it"
      },
      {
        "siteName": "tuttoatalanta.com",
        "siteLink": "https://www.tuttoatalanta.com/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tuttoatalanta.com"
      }
    ]
  },
  {
    "name": "News",
    "color": 4280693304,
    "iconData": 984385,
    "language": "english",
    "sites": [
      {
        "siteName": "aljazeera.com",
        "siteLink": "https://www.aljazeera.com/xml/rss/all.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=aljazeera.com"
      },
      {
        "siteName": "dailymail.co.uk",
        "siteLink": "https://www.dailymail.co.uk/sport/index.rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=dailymail.co.uk"
      },
      {
        "siteName": "bbci.co.uk",
        "siteLink": "http://feeds.bbci.co.uk/news/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=bbci.co.uk"
      },
      {
        "siteName": "skynews.com",
        "siteLink": "http://feeds.skynews.com/feeds/rss/home.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=skynews.com"
      },
      {
        "siteName": "washingtonpost.com",
        "siteLink": "http://feeds.washingtonpost.com/rss/local?itid=lk_inline_manual_15",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=washingtonpost.com"
      },
      {
        "siteName": "ft.com",
        "siteLink": "https://www.ft.com/rss/home",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ft.com"
      },
      {
        "siteName": "independent.co.uk",
        "siteLink": "https://www.independent.co.uk/sport/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=independent.co.uk"
      },
      {
        "siteName": "ft.com",
        "siteLink": "https://news.google.com/rss?hl=en-US&gl=US&ceid=US:en+when:3d",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ft.com"
      },
      {
        "siteName": "nbcnews.com",
        "siteLink": "https://www.nbcnews.com/feeds/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=nbcnews.com"
      },
      {
        "siteName": "cnn.com",
        "siteLink": "https://news.google.com/rss/search?q=//cnn.com&hl=en-US&gl=US&ceid=US:en+when:3d",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=cnn.com"
      },
      {
        "siteName": "theguardian.com",
        "siteLink": "https://news.google.com/rss/search?q=//theguardian.com&hl=en-US&gl=US&ceid=US:en+when:3d",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=theguardian.com"
      },
      {
        "siteName": "politico.com",
        "siteLink": "https://www.politico.com/rss/politicopicks.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=politico.com"
      },
      {
        "siteName": "reuters.com",
        "siteLink": "https://news.google.com/rss/search?q=reuters.com&hl=en-US&gl=US&ceid=US:en",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=reuters.com"
      },
      {
        "siteName": "cnn.com",
        "siteLink": "http://rss.cnn.com/rss/edition.rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=cnn.com"
      },
      {
        "siteName": "nytimes.com",
        "siteLink": "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=nytimes.com"
      },
      {
        "siteName": "theguardian.com",
        "siteLink": "https://www.theguardian.com/mostviewed/rss/blog/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=theguardian.com"
      },
      {
        "siteName": "thehill.com",
        "siteLink": "https://thehill.com/news/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=thehill.com"
      }
    ]
  },
  {
    "name": "Technology",
    "color": 4281408402,
    "iconData": 58169,
    "language": "english",
    "sites": [
      {
        "siteName": "blog.malwarebytes.com",
        "siteLink": "https://blog.malwarebytes.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=malwarebytes.com"
      },
      {
        "siteName": "cmswire.com",
        "siteLink": "https://feeds2.feedburner.com/CMSWire",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=cmswire.com"
      },
      {
        "siteName": "torrentfreak.com",
        "siteLink": "https://torrentfreak.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=torrentfreak.com"
      },
      {
        "siteName": "techradar.com",
        "siteLink": "https://www.techradar.com/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=techradar.com"
      },
      {
        "siteName": "ghacks.net",
        "siteLink": "https://www.ghacks.net/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ghacks.net"
      },
      {
        "siteName": "techradar.com",
        "siteLink": "https://www.techradar.com/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=techradar.com"
      },
      {
        "siteName": "omgubuntu.co.uk",
        "siteLink": "https://www.omgubuntu.co.uk/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=www.omgubuntu.co.uk"
      },
      {
        "siteName": "fossmint.com",
        "siteLink": "https://www.fossmint.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fossmint.com"
      },
      {
        "siteName": "web.dev",
        "siteLink": "https://web.dev/feed.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=web.dev"
      },
      {
        "siteName": "9to5mac.com",
        "siteLink": "https://9to5mac.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=9to5mac.com"
      },
      {
        "siteName": "macrumors.com",
        "siteLink": "https://feeds.macrumors.com/MacRumors-All",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=macrumors.com"
      },
      {
        "siteName": "techcrunch.com",
        "siteLink": "https://techcrunch.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=techcrunch.com"
      },
      {
        "siteName": "theregister.com",
        "siteLink": "https://www.theregister.com/headlines.atom",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=theregister.com"
      },
      {
        "siteName": "xda-developers.com",
        "siteLink": "https://www.xda-developers.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=xda-developers.com"
      },
{
  "siteName": "theverge.com",
  "siteLink": "https://www.theverge.com/rss/index.xml",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=theverge.com"
},
{
  "siteName": "thenextweb.com",
  "siteLink": "https://thenextweb.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=thenextweb.com"
},
{
  "siteName": "9to5google.com",
  "siteLink": "https://9to5google.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=9to5google.com"
},
{
  "siteName": "9to5mac.com",
  "siteLink": "https://9to5mac.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=9to5mac.com"
},
{
  "siteName": "anandtech.com",
  "siteLink": "http://www.anandtech.com/rss/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=anandtech.com"
},
{
  "siteName": "androidauthority.com",
  "siteLink": "https://www.androidauthority.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=androidauthority.com"
},
{
  "siteName": "androidcentral.com",
  "siteLink": "https://androidcentral.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=androidcentral.com"
},
{
  "siteName": "androidpolice.com",
  "siteLink": "https://www.androidpolice.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=androidpolice.com"
},
{
  "siteName": "appleinsider.com",
  "siteLink": "https://appleinsider.com/rss/news",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=appleinsider.com"
},
{
  "siteName": "arstechnica.com",
  "siteLink": "https://arstechnica.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=arstechnica.com"
},
{
  "siteName": "bgr.com",
  "siteLink": "https://bgr.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=bgr.com"
},
{
  "siteName": "boingboing.net",
  "siteLink": "https://boingboing.net/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=boingboing.net"
},
{
  "siteName": "digitaltrends.com",
  "siteLink": "https://www.digitaltrends.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=digitaltrends.com"
},
{
  "siteName": "engadget.com",
  "siteLink": "http://www.engadget.com//www.engadget.com/rss.xml",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=engadget.com"
},
{
  "siteName": "extremetech.com",
  "siteLink": "https://www.extremetech.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=extremetech.com"
},
{
  "siteName": "gizmodo.com",
  "siteLink": "https://gizmodo.com/rss",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=gizmodo.com"
},
{
  "siteName": "gsmarena.com",
  "siteLink": "https://www.gsmarena.com/rss-news-reviews.php3",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=gsmarena.com"
},
{
  "siteName": "hackaday.com",
  "siteLink": "https://hackaday.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=hackaday.com"
},
{
  "siteName": "howtogeek.com",
  "siteLink": "https://www.howtogeek.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=howtogeek.com"
},
{
  "siteName": "makezine.com",
  "siteLink": "https://makezine.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=makezine.com"
},
{
  "siteName": "pcworld.com",
  "siteLink": "https://www.pcworld.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=pcworld.com"
},
{
  "siteName": "slashdot.org",
  "siteLink": "http://rss.slashdot.org/Slashdot/slashdotMain",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=slashdot.org"
},
{
  "siteName": "slashgear.com",
  "siteLink": "https://www.slashgear.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=slashgear.com"
},
{
  "siteName": "techmeme.com",
  "siteLink": "https://www.techmeme.com/feed.xml",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=techmeme.com"
},
{
  "siteName": "technologyreview.com",
  "siteLink": "https://www.technologyreview.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=technologyreview.com"
},
{
  "siteName": "venturebeat.com",
  "siteLink": "https://venturebeat.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=venturebeat.com"
},
{
  "siteName": "gigaom.com",
  "siteLink": "https://gigaom.com/feed/",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=gigaom.com"
}
    ]
  },
  {
    "name": "Curiosity",
    "color": 4289533015,
    "iconData": 984461,
    "language": "english",
    "sites": [
      {
        "siteName": "makeuseof.com",
        "siteLink": "https://www.makeuseof.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=makeuseof.com"
      },
      {
        "siteName": "wikihow.com",
        "siteLink": "https://www.wikihow.com/feed.rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=wikihow.com"
      },
      {
        "siteName": "lifehack.org",
        "siteLink": "https://www.lifehack.org/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lifehack.org"
      },
      {
        "siteName": "lifehacker.com",
        "siteLink": "https://lifehacker.com/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lifehacker.com"
      },
      {
        "siteName": "wired.com",
        "siteLink": "https://wired.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=wired.com"
      },
      {
        "siteName": "adventure-journal.com",
        "siteLink": "https://www.adventure-journal.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=adventure-journal.com"
      },
      {
        "siteName": "popsci.com",
        "siteLink": "https://www.popsci.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=popsci.com"
      },
      {
        "siteName": "thepointsguy.com",
        "siteLink": "https://thepointsguy.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=thepointsguy.com"
      },
      {
        "siteName": "seriouseats.com",
        "siteLink": "https://www.seriouseats.com/atom.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=seriouseats.com"
      },
      {
        "siteName": "skinnytaste.com",
        "siteLink": "https://www.skinnytaste.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=skinnytaste.com"
      },
      {
        "siteName": "smittenkitchen.com",
        "siteLink": "https://smittenkitchen.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=smittenkitchen.com"
      },
{
  "siteName": "daringfireball.net",
  "siteLink": "https://daringfireball.net/feeds/main",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=daringfireball.net"
}
,
{
  "siteName": "mashable.com",
  "siteLink": "https://mashable.com/feeds/rss/all",
  "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=aaaaaaaaaa"
}

    ]
  },
  {
    "name": "Sport",
    "color": 4278223759,
    "iconData": 58857,
    "language": "english",
    "sites": [
      {
        "siteName": "derbytelegraph.co.uk",
        "siteLink": "https://www.derbytelegraph.co.uk/sport/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=derbytelegraph.co.uk"
      },
      {
        "siteName": "eurosport.com",
        "siteLink": "https://www.eurosport.com/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=eurosport.com"
      },
      {
        "siteName": "metro.co.uk",
        "siteLink": "https://metro.co.uk/sport/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=metro.co.uk"
      },
      {
        "siteName": "nbcsports.com",
        "siteLink": "https://www.nbcsports.com/rss.xml",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=nbcsports.com"
      },
      {
        "siteName": "sports.yahoo.com",
        "siteLink": "https://sports.yahoo.com/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=sports.yahoo.com"
      },
      {
        "siteName": "talksport.com",
        "siteLink": "https://talksport.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=talksport.com"
      },
      {
        "siteName": "theathletic.com",
        "siteLink": "https://theathletic.com/feeds/rss/news/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=theathletic.com"
      },
      {
        "siteName": "thesun.co.uk",
        "siteLink": "https://www.thesun.co.uk/sport/football/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=thesun.co.uk"
      },
      {
        "siteName": "sportingnews.com",
        "siteLink": "https://www.sportingnews.com/uk/rss/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=sportingnews.com"
      }
    ]
  },
  {
    "name": "Business",
    "color": 4283215696,
    "iconData": 57628,
    "language": "english",
    "sites": [
      {
        "siteName": "workplace.stackexchange.com",
        "siteLink": "https://workplace.stackexchange.com/feeds",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=workplace.stackexchange.com"
      },
      {
        "siteName": "interpersonal.stackexchange.com",
        "siteLink": "https://interpersonal.stackexchange.com/feeds",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=interpersonal.stackexchange.com"
      },
      {
        "siteName": "entrepreneur.com",
        "siteLink": "https://www.entrepreneur.com/latest.rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=entrepreneur.com"
      },
      {
        "siteName": "econsultancy.com",
        "siteLink": "https://econsultancy.com/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=econsultancy.com"
      }
    ]
  },
  {
    "name": "Programming",
    "color": 4278351805,
    "iconData": 61871,
    "language": "english",
    "sites": [
      {
        "siteName": "workplace.stackexchange.com",
        "siteLink": "https://softwareengineering.stackexchange.com/feeds/month",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=workplace.stackexchange.com"
      },
      {
        "siteName": "devblogs.microsoft.com",
        "siteLink": "https://devblogs.microsoft.com/oldnewthing/feed/",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=devblogs.microsoft.com"
      },
      {
        "siteName": "blog.google",
        "siteLink": "https://blog.google/rss",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=blog.google"
      },
      {
        "siteName": "linuxjournal.com",
        "siteLink": "https://www.linuxjournal.com/node/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=linuxjournal.com"
      },
      {
        "siteName": "stackoverflow.blog",
        "siteLink": "https://stackoverflow.blog/feed",
        "iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=stackoverflow.blog"
      }
    ]
  }
]""";

  late SitesList sitesList =
      SitesList.withIndicator(updateItemLoading: _updateItemLoading);
  void _updateItemLoading(String itemLoading) {
    //setState(() {});
  }

  Future<bool> load(String language, String category) async {
    try {
      await save(json);
      items = await get(language, category);
      for (RecommendedCategory c in items) {
        for (RecommendedSite s in c.sites) {
          if (await sitesList.exists(s.siteLink)) {
            s.added = true;
          }
        }
      }

      return true;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  Future<void> save(String jsonRecommended) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('db_recommended', jsonRecommended);
    } catch (err) {
      //print('Caught error: $err');
    }
  }

  Future<List<RecommendedCategory>> get(
      String language, String category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData =
          await jsonDecode(prefs.getString('db_recommended') ?? '[]');
      late List<RecommendedCategory> list = List<RecommendedCategory>.from(
          jsonData.map((model) => RecommendedCategory.fromJson(model)));
      if (language.trim() != "") {
        list = list
            .where((e) =>
                e.language.toLowerCase() == language.toString().toLowerCase())
            .toList();
      }
      if (category.trim() != '') {
        list = list
            .where((e) =>
                e.name.toLowerCase().trim() ==
                category.toString().toLowerCase().trim())
            .toList();
      }

      return list;
    } catch (err) {
      // print('Caught error: $err');
    }
    return [];
  }
}
