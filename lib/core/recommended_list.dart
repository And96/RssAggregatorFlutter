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
		"name": "Bergamo",
		"color": 4289533015,
		"iconData": 61871,
		"language": "italiano",
		"sites": [{
				"siteName": "ecodibergamo.it",
				"siteLink": "https://www.ecodibergamo.it/feeds/latesthp/268/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ecodibergamo.it"
			},
			{
				"siteName": "ecodibergamo.it",
				"siteLink": "https://news.google.com/rss/search?q=ecodibergamo.it+when:2d&hl=it&gl=IT&ceid=IT:it",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=news.google.com"
			},
			{
				"siteName": "Nembro (Google News)",
				"siteLink": "https://news.google.com/rss/search?q=nembro+when:3d&hl=it&gl=IT&ceid=IT:it",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=news.google.com"
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
				"siteName": "primabergamo.it",
				"siteLink": "https://primabergamo.it/feed",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=primabergamo.it"
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
			}
		]
	},
	{
		"name": "Lavoro",
		"color": 4292363029,
		"iconData": 58866,
		"language": "italiano",
		"sites": [{
				"siteName": "addlance.com",
				"siteLink": "https://www.addlance.com/blog/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=addlance.com"
			},
			{
				"siteName": "affarimiei.biz",
				"siteLink": "https://www.affarimiei.biz/feed",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=affarimiei.biz"
			},
			{
				"siteName": "agendadigitale.eu",
				"siteLink": "https://www.agendadigitale.eu/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=agendadigitale.eu"
			},
			{
				"siteName": "alfiobardolla.com",
				"siteLink": "https://www.alfiobardolla.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=alfiobardolla.com"
			},
			{
				"siteName": "biancolavoro.it",
				"siteLink": "https://news.biancolavoro.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=biancolavoro.it"
			},
			{
				"siteName": "enterprise.teamsystem.com",
				"siteLink": "https://enterprise.teamsystem.com/blog/rss.xml",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=teamsystem.com"
			},
			{
				"siteName": "cmswire.com",
				"siteLink": "https://feeds2.feedburner.com/CMSWire",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=cmswire.com"
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
				"siteName": "econsultancy.com",
				"siteLink": "https://econsultancy.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=econsultancy.com"
			},
			{
				"siteName": "educazionefinanziaria.com",
				"siteLink": "https://www.educazionefinanziaria.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=educazionefinanziaria.com"
			},
			{
				"siteName": "entrepreneur.com",
				"siteLink": "https://www.entrepreneur.com/latest.rss",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=entrepreneur.com"
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
			}
		]
	},
	{
		"name": "TV",
		"color": 4279060385,
		"iconData": 57943,
		"language": "italiano",
		"sites": [{
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
				"siteName": "telefilmaddicted.com",
				"siteLink": "https://www.telefilmaddicted.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=telefilmaddicted.com"
			}
		]
	},
	{
		"name": "Curiosita",
		"color": 4278223759,
		"iconData": 984385,
		"language": "italiano",
		"sites": [{
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
				"siteName": "geopop.it",
				"siteLink": "https://www.geopop.it/rss",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=geopop.it"
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
			}

		]
	},
	{
		"name": "Inter",
		"color": 4278223759,
		"iconData": 984385,
		"language": "italiano",
		"sites": [{
				"siteName": "calciomercato.com",
				"siteLink": "https://www.calciomercato.com/feed/teams/inter",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=calciomercato.com"
			},
			{
				"siteName": "inter.it",
				"siteLink": "https://news.google.com/rss/search?q=inter.it+when:15d&hl=it&gl=IT&ceid=IT:it",
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
				"siteName": "sempreinter.com",
				"siteLink": "https://sempreinter.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=sempreinter.com"
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
		"name": "Musica",
		"color": 4278223759,
		"iconData": 984385,
		"language": "italiano",
		"sites": [{
				"siteName": "airmag.it",
				"siteLink": "https://www.airmag.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=airmag.it"
			},
			{
				"siteName": "hano.it",
				"siteLink": "https://www.hano.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=hano.it"
			}, {
				"siteName": "blogdellamusica.eu",
				"siteLink": "https://www.blogdellamusica.eu/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=blogdellamusica.eu"
			}, {
				"siteName": "rockit.it",
				"siteLink": "https://news.google.com/rss/search?q=rockit.it+when:5d&hl=it&gl=IT&ceid=IT:it",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rockit.it"
			}
		]
	},
	{
		"name": "News",
		"color": 4278223759,
		"iconData": 984385,
		"language": "italiano",
		"sites": [{
				"siteName": "miur.gov.it",
				"siteLink": "https://www.miur.gov.it/documents/20182/0/news-mi-rss.xml/2354a985-3d0c-f2df-1945-713c198bb8ad?t=1657029242222",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=miur.gov.it"
			},
			{
				"siteName": "ilfattoquotidiano.it",
				"siteLink": "https://www.ilfattoquotidiano.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilfattoquotidiano.it"
			},
			{
				"siteName": "ilpost.it",
				"siteLink": "https://www.ilpost.it/rss",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilpost.it"
			},
			{
				"siteName": "repubblica.it",
				"siteLink": "https://espresso.repubblica.it/rss?sezione=espresso",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=repubblica.it"
			},
			{
				"siteName": "open.online",
				"siteLink": "https://www.open.online/rss",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=open.online"
			},
			{
				"siteName": "panorama.it",
				"siteLink": "https://www.panorama.it/feeds/news.rss",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=panorama.it"
			},
			{
				"siteName": "ansa.it",
				"siteLink": "https://www.ansa.it/sito/ansait_rss.xml",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ansa.it"
			},
			{
				"siteName": "tg24.sky.it",
				"siteLink": "https://tg24.sky.it/rss/tg24_flipboard.cronaca.xml",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tg24.sky.it"
			},
			{
				"siteName": "startmag.it",
				"siteLink": "https://www.startmag.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=startmag.it"
			},
			{
				"siteName": "tpi.it",
				"siteLink": "https://tpi.it/feed",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tpi.it"
			},
			{
				"siteName": "termometropolitico.it",
				"siteLink": "https://www.termometropolitico.it/rss",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=termometropolitico.it"
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
				"siteName": "la7.it",
				"siteLink": "https://news.google.com/rss/search?q=site:la7.it+when:2d&hl=it&gl=IT&ceid=IT:it",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=la7.it"
			},
			{
				"siteName": "rainews.it",
				"siteLink": "https://www.rainews.it/rss/tutti",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rainews.it"
			},
			{
				"siteName": "servizitelevideo.rai.it",
				"siteLink": "https://www.servizitelevideo.rai.it/televideo/pub/rss101.xml",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rai.it"
			},
			{
				"siteName": "ilsole24ore.com",
				"siteLink": "https://www.ilsole24ore.com/rss/italia--attualita.xml",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ilsole24ore.com"
			},
			{
				"siteName": "tgcom24.mediaset.it",
				"siteLink": "https://tgcom24.mediaset.it/rss.xml",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tgcom24.mediaset.it"
			}
		]
	},
	{
		"name": "Scienza",
		"color": 4278217052,
		"iconData": 58714,
		"language": "italiano",
		"sites": [{
			"siteName": "prevenzioneatavola.it",
			"siteLink": "https://blog.prevenzioneatavola.it/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=prevenzioneatavola.it"
		}, {
			"siteName": "ecoblog.it",
			"siteLink": "https://www.ecoblog.it/rss2.xml",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ecoblog.it"
		}, {
			"siteName": "geopop.it",
			"siteLink": "https://www.geopop.it/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=geopop.it"
		}, {
			"siteName": "attivissimo.blogspot.com",
			"siteLink": "https://feeds.feedburner.com/Disinformatico",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=attivissimo.blogspot.com"
		}, {
			"siteName": "lescienze.it",
			"siteLink": "http://www.lescienze.it/rss/all/rss2.0.xml",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lescienze.it"
		}, {
			"siteName": "my-personaltrainer.it",
			"siteLink": "https://feeds.feedburner.com/My-personaltrainer/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=my-personaltrainer.it"
		}, {
			"siteName": "stateofmind.it",
			"siteLink": "https://www.stateofmind.it/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=stateofmind.it"
		}, {
			"siteName": "tantasalute.it",
			"siteLink": "https://www.tantasalute.it/rss/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tantasalute.it"
		}]
	},

	{
		"name": "Sport",
		"color": 4278351805,
		"iconData": 58857,
		"language": "italiano",
		"sites": [{
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
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=sport.rai.it"
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
				"siteLink": "https://news.google.com/rss/search?q=sport.virgilio.it+when:2d&hl=it&gl=IT&ceid=IT:it",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=sport.virgilio.it"
			},
			{
				"siteName": "fantacalcio.it",
				"siteLink": "https://news.google.com/rss/search?q=fantacalcio.it+when:2d&hl=it&gl=IT&ceid=IT:it",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fantacalcio.it"
			}
		]
	},
	{
		"name": "Sviluppo",
		"color": 4279060385,
		"iconData": 61871,
		"language": "italiano",
		"sites": [{
				"siteName": "html.it",
				"siteLink": "https://www.html.it/rss",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=html.it"
			},
			{
				"siteName": "italiancoders.it",
				"siteLink": "https://italiancoders.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=italiancoders.it"
			},
			{
				"siteName": "mrwebmaster.it",
				"siteLink": "https://feeds.feedburner.com/Mr_Webmaster",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mrwebmaster.it"
			}, {
				"siteName": "forum.mrwebmaster.it",
				"siteLink": "https://forum.mrwebmaster.it/forums/-/index.rss",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=forum.mrwebmaster.it"
			}
		]
	},
	{
		"name": "Tecnologia",
		"color": 4281408402,
		"iconData": 62571,
		"language": "italiano",
		"sites": [{
			"siteName": "mvnonews.com",
			"siteLink": "https://www.mvnonews.com/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mvnonews.com"
		}, {
			"siteName": "mondo3.com",
			"siteLink": "https://mondo3.com/rss",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mondo3.com"
		}, {
			"siteName": "mondomobileweb.it",
			"siteLink": "https://www.mondomobileweb.it/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=mondomobileweb.it"
		}, {
			"siteName": "tariffando.it",
			"siteLink": "https://feeds.feedburner.com/Tariffando",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tariffando.it"
		}, {
			"siteName": "universofree.com",
			"siteLink": "https://www.universofree.com/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=universofree.com"
		}, {
			"siteName": "amcomputers.org",
			"siteLink": "https://www.amcomputers.org/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=amcomputers.org"
		}, {
			"siteName": "androidworld.it",
			"siteLink": "https://www.androidworld.it/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=androidworld.it"
		}, {
			"siteName": "blog.kaspersky.it",
			"siteLink": "https://blog.kaspersky.it/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=blog.kaspersky.it"
		}, {
			"siteName": "chimerarevo.com",
			"siteLink": "https://www.chimerarevo.com/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=chimerarevo.com"
		}, {
			"siteName": "turbolab.it",
			"siteLink": "http://turbolab.it",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=turbolab.it"
		}, {
			"siteName": "hdblog.it/",
			"siteLink": "https://www.hdblog.it/feed",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=hdblog.it/"
		}, {
			"siteName": "lffl.org",
			"siteLink": "https://www.lffl.org/feed",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lffl.org"
		}, {
			"siteName": "miamammausalinux.org",
			"siteLink": "https://www.miamammausalinux.org/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=miamammausalinux.org"
		}, {
			"siteName": "psbprivacyesicurezza.it",
			"siteLink": "https://www.psbprivacyesicurezza.it/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=psbprivacyesicurezza.it"
		}, {
			"siteName": "punto-informatico.it",
			"siteLink": "https://www.punto-informatico.it/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=punto-informatico.it"
		}, {
			"siteName": "scubidu.eu",
			"siteLink": "https://scubidu.eu/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=scubidu.eu"
		}, {
			"siteName": "cryptonomist.ch",
			"siteLink": "https://cryptonomist.ch",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=cryptonomist.ch"
		}, {
			"siteName": "tuttoandroid.net",
			"siteLink": "https://www.tuttoandroid.net/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tuttoandroid.net"
		}, {
			"siteName": "ispazio.net",
			"siteLink": "https://feeds.feedburner.com/Ispazio",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ispazio.net"
		}, {
			"siteName": "telefonino.net",
			"siteLink": "https://www.telefonino.net/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=telefonino.net"
		}, {
			"siteName": "socializziamo.net",
			"siteLink": "https://www.socializziamo.net/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=socializziamo.net"
		}, {
			"siteName": "telefonino.net",
			"siteLink": "https://www.telefonino.net/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=telefonino.net"
		}]
	},
	{
		"name": "Calcio",
		"color": 4279060385,
		"iconData": 61871,
		"language": "italiano",
		"sites": [{
			"siteName": "calcionews24.com",
			"siteLink": "https://www.calcionews24.com/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=calcionews24.com"
		}, {
			"siteName": "calciomercato.com",
			"siteLink": "https://www.calciomercato.com/feed",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=calciomercato.com"
		}, {
			"siteName": "gianlucadimarzio.com",
			"siteLink": "https://gianlucadimarzio.com/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=gianlucadimarzio.com"
		}, {
			"siteName": "tuttomercatoweb.com",
			"siteLink": "https://news.google.com/rss/search?q=tuttomercatoweb.com+when:1d&hl=it&gl=IT&ceid=IT:it",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tuttomercatoweb.com"
		}, {
			"siteName": "goal.com",
			"siteLink": "https://news.google.com/rss/search?q=goal.com+when:2d&hl=it&gl=IT&ceid=IT:it",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=goal.com"
		}, {
			"siteName": "transfermarkt.it",
			"siteLink": "https://news.google.com/rss/search?q=transfermarkt.it+when:2d&hl=it&gl=IT&ceid=IT:it",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=transfermarkt.it"
		}, {
			"siteName": "transfermarkt.it",
			"siteLink": "https://news.google.com/rss/search?q=transfermarkt.it+when:2d&hl=it&gl=IT&ceid=IT:it",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=transfermarkt.it"
		}, {
			"siteName": "calciostyle.it",
			"siteLink": "https://www.calciostyle.it/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=calciostyle.it"
		}, {
			"siteName": "calcioblog.it",
			"siteLink": "https://www.calcioblog.it/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=calcioblog.it"
		}, {
			"siteName": "alfredopedulla.com",
			"siteLink": "https://www.alfredopedulla.com/feed/",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=alfredopedulla.com"
		}, {
			"siteName": "sportitalia.com",
			"siteLink": "https://news.google.com/rss/search?q=sportitalia.com+when:2d&hl=it&gl=IT&ceid=IT:it",
			"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=sportitalia.com"
		}]
	},
	{
		"name": "Motori",
		"color": 4283215696,
		"iconData": 58865,
		"language": "italiano",
		"sites": [{
				"siteName": "newsf1.it",
				"siteLink": "https://www.newsf1.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=newsf1.it"
			},
			{
				"siteName": "formula1.it",
				"siteLink": "https://news.google.com/rss/search?q=formula1.it+when:2d&hl=it&gl=IT&ceid=IT:it",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=formula1.it"
			},
			{
				"siteName": "f1grandprix.motorionline.com",
				"siteLink": "https://f1grandprix.motorionline.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=motorionline.com"
			}, {
				"siteName": "it.motorsport.com",
				"siteLink": "https://news.google.com/rss/search?q=it.motorsport.com+when:2d&hl=it&gl=IT&ceid=IT:it",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=motorsport.com"
			}, {
				"siteName": "f1ingenerale.com",
				"siteLink": "https://f1ingenerale.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=f1ingenerale.com"
			}, {
				"siteName": "circusf1.com",
				"siteLink": "https://www.circusf1.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=circusf1.com"
			}, {
				"siteName": "formulapassion.it",
				"siteLink": "https://www.formulapassion.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=formulapassion.it"
			}, {
				"siteName": "funoanalisitecnica.com",
				"siteLink": "https://www.funoanalisitecnica.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=funoanalisitecnica.com"
			}, {
				"siteName": "f1sport.it",
				"siteLink": "https://www.f1sport.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=f1sport.it"
			}, {
				"siteName": "giornalemotori.com",
				"siteLink": "https://www.giornalemotori.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=giornalemotori.com"
			}, {
				"siteName": "f1world.it",
				"siteLink": "https://www.f1world.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=f1world.it"
			}, {
				"siteName": "gpone.com",
				"siteLink": "https://www.gpone.com/it/article-feed.xml",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=gpone.com"
			}, {
				"siteName": "motoblog.it",
				"siteLink": "https://www.motoblog.it/feed",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=motoblog.it"
			}, {
				"siteName": "rallyssimo.it",
				"siteLink": "https://www.rallyssimo.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=rallyssimo.it"
			}
		]
	},
	{
		"name": "Technology",
		"color": 4279060385,
		"iconData": 61871,
		"language": "english",
		"sites": [{
				"siteName": "hackerjournal.it",
				"siteLink": "https://hackerjournal.it/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=hackerjournal.it"
			},
			{
				"siteName": "blog.malwarebytes.com",
				"siteLink": "https://blog.malwarebytes.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=malwarebytes.com"
			},
			{
				"siteName": "torrentfreak.com",
				"siteLink": "https://torrentfreak.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=torrentfreak.com"
			}, {
				"siteName": "techradar.com",
				"siteLink": "https://www.techradar.com/rss",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=techradar.com"
			}, {
				"siteName": "tecmint.com",
				"siteLink": "feeds.feedburner.com/tecmint",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=tecmint.com"
			}, {
				"siteName": "ghacks.net",
				"siteLink": "https://www.ghacks.net/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=ghacks.net"
			}, {
				"siteName": "techradar.com",
				"siteLink": "https://www.techradar.com/rss",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=techradar.com"
			}, {
				"siteName": "omgubuntu.co.uk",
				"siteLink": "https://www.omgubuntu.co.uk/feed",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=www.omgubuntu.co.uk"
			}, {
				"siteName": "fossmint.com",
				"siteLink": "https://www.fossmint.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=fossmint.com"
			}, {
				"siteName": "web.dev",
				"siteLink": "https://web.dev/feed.xml",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=web.dev"
			}
		]
	},
	{
		"name": "Curiosity",
		"color": 4279060385,
		"iconData": 61871,
		"language": "english",
		"sites": [{
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
			}, {
				"siteName": "lifehacker.com",
				"siteLink": "https://lifehacker.com/rss",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=lifehacker.com"
			}, {
				"siteName": "wired.com",
				"siteLink": "https://wired.com/feed/",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=wired.com"
			}
		]
	},
	{
		"name": "Work",
		"color": 4279060385,
		"iconData": 61871,
		"language": "english",
		"sites": [{
				"siteName": "workplace.stackexchange.com",
				"siteLink": "https://workplace.stackexchange.com/feeds",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=workplace.stackexchange.com"
			},
			{
				"siteName": "interpersonal.stackexchange.com",
				"siteLink": "https://interpersonal.stackexchange.com/feeds",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=interpersonal.stackexchange.com"
			}
		]
	},
	{
		"name": "Development",
		"color": 4279060385,
		"iconData": 61871,
		"language": "english",
		"sites": [{
				"siteName": "workplace.stackexchange.com",
				"siteLink": "https://softwareengineering.stackexchange.com/feeds/month",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=workplace.stackexchange.com"
			},
			{
				"siteName": "linuxjournal.com",
				"siteLink": "https://www.linuxjournal.com/node/feed",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=linuxjournal.com"
			},
			{
				"siteName": "hub.packtpub.com",
				"siteLink": "hub.packtpub.com/feed",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=packtpub.com"
			},
			{
				"siteName": "stackoverflow.blog",
				"siteLink": "https://stackoverflow.blog/feed",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=stackoverflow.blog"
			},
			{
				"siteName": "codeburst.io",
				"siteLink": "https://codeburst.io/feed",
				"iconUrl": "https://www.google.com/s2/favicons?sz=64&domain_url=codeburst.io"
			}
		]
	}
]""";

  late SitesList sitesList = SitesList(updateItemLoading: _updateItemLoading);
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
