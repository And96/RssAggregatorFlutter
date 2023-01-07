import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/recommended_list.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
import 'package:rss_aggregator_flutter/widgets/site_logo_big.dart';

class RecommendedSitesPage extends StatefulWidget {
  const RecommendedSitesPage(
      {Key? key, required this.language, required this.category})
      : super(key: key);

  final String language;
  final String category;

  @override
  State<RecommendedSitesPage> createState() => _RecommendedSitesPageState();
}

class _RecommendedSitesPageState extends State<RecommendedSitesPage> {
  bool isLoading = false;
  double progressLoading = 0;
  late RecommendedList recommendedList = RecommendedList();
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
      await loadData();
      c1 = AnimateIconController();
    });
  }

  @override
  dispose() {
    super.dispose();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await recommendedList.load(
          widget.language.toString(), widget.category.toString());
    } catch (err) {
      //print('Caught error: $err');
    }
    setState(() {
      isLoading = false;
    });
  }

  late AnimateIconController c1;
  late CategoriesList categoriesList = CategoriesList();

  late SitesList sitesList = SitesList();

  Future<bool> onTapIconList(
      BuildContext context, RecommendedSite selected) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      int siteID = await sitesList.getSiteID(selected.siteLink);
      if (siteID > 0) {
        await sitesList.delete(selected.siteLink, selected.siteName, 0);
        selected.added = false;
      } else {
        bool exists =
            await categoriesList.exists(recommendedList.items[0].name);
        if (!exists) {
          await categoriesList.add(
              recommendedList.items[0].name,
              recommendedList.items[0].color,
              recommendedList.items[0].iconData);
        }
        Site site = Site(
            siteID: siteID,
            siteName: selected.siteName,
            siteLink: selected.siteLink,
            iconUrl: selected.iconUrl,
            category: recommendedList.items[0].name);
        await sitesList.addSite(site);
        selected.added = true;
      }
    } catch (err) {
      //print('Caught error: $err');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recommendedList.items.isEmpty
            ? "Category"
            : recommendedList.items[0].name),
        backgroundColor: darkMode || recommendedList.items.isEmpty
            ? null
            : Color(recommendedList.items[0].color),
      ),
      body: Stack(
        children: [
          isLoading == false
              ? Container(
                  padding: const EdgeInsets.only(top: 9),
                  color: darkMode
                      ? ThemeColor.dark1.withAlpha(120)
                      : ThemeColor.light1,
                  child: recommendedList.items.isEmpty
                      ? null
                      : ListView.builder(
                          itemCount: recommendedList.items[0].sites.length,
                          /* separatorBuilder: (context, index) {
                            return const Divider();
                          },*/

                          itemBuilder: (BuildContext context, index) {
                            final item = recommendedList.items[0].sites[index];
                            return InkWell(
                                child: Card(
                              margin: const EdgeInsets.only(
                                  left: 12, right: 12, top: 7, bottom: 7),
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Colors.transparent,
                                  width: 0.0,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 0,
                              color:
                                  darkMode ? Colors.transparent : Colors.white,
                              shadowColor:
                                  darkMode ? Colors.black : Colors.white,
                              child: ListTile(
                                  contentPadding: const EdgeInsets.only(
                                      left: 15, right: 15, top: 10, bottom: 10),
                                  minLeadingWidth: 50,
                                  leading: SiteLogoBig(
                                      iconUrl: item.iconUrl,
                                      color: Color(
                                          recommendedList.items[0].color)),
                                  title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0),
                                          child: Text(
                                            (item.siteName.toString()),
                                          ),
                                        ),
                                      ]),
                                  isThreeLine: false,
                                  trailing: Padding(
                                    padding: const EdgeInsets.only(left: 1),
                                    child: AnimateIcons(
                                      startIconColor: darkMode
                                          ? Colors.white
                                          : Colors.black45,
                                      endIconColor: darkMode
                                          ? Colors.white
                                          : Colors.black45,
                                      startIcon:
                                          item.added ? Icons.check : Icons.add,
                                      endIcon:
                                          item.added ? Icons.add : Icons.check,
                                      startTooltip: "Add",
                                      endTooltip: "Remove",
                                      controller: c1,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      clockwise: false,
                                      onEndIconPress: () {
                                        onTapIconList(context, item)
                                            .then((value) => null);
                                        return true;
                                      },
                                      onStartIconPress: () {
                                        onTapIconList(context, item)
                                            .then((value) => null);
                                        return true;
                                      },
                                    ),
                                  ),
                                  subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(
                                            child: Text(
                                              item.siteLink.toString(),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ))),
                            ));
                          }))
              : Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      EmptySection(
                        title: 'Searching...',
                        description: '',
                        icon: Icons.manage_search,
                        darkMode: darkMode,
                      ),
                      /*  ),*/
                      Container(
                        width: 175,
                        height: 3,
                        margin: const EdgeInsets.only(top: 22),
                        child: const LinearProgressIndicator(
                          backgroundColor: Colors.blueGrey,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black54),
                        ),
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
