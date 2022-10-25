import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
import 'package:rss_aggregator_flutter/core/recommended_list.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
import 'package:rss_aggregator_flutter/widgets/site_logo.dart';

class RecommendedSitesPage extends StatefulWidget {
  const RecommendedSitesPage(
      {Key? key, required this.language, required this.category})
      : super(key: key);

  final String language;
  final String category;

  @override
  State<RecommendedSitesPage> createState() => _RecommendedSitesPageState();
}

class _RecommendedSitesPageState extends State<RecommendedSitesPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  double progressLoading = 0;
  late RecommendedList recommendedList = RecommendedList();
  bool darkMode = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
      await loadData();
      c1 = AnimateIconController();
    });
    super.initState();
  }

  @override
  dispose() {
    _refreshIconController.stop(canceled: true);
    _refreshIconController.dispose();
    super.dispose();
  }

  late final AnimationController _refreshIconController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

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

  late SitesList sitesList = SitesList(updateItemLoading: _updateItemLoading);
  void _updateItemLoading(String itemLoading) {
    setState(() {});
  }

  Future<bool> onStartIconPress(
      BuildContext context, RecommendedSite selected) async {
    try {
      await categoriesList.add(
          recommendedList.items[0].name, recommendedList.items[0].color);
      await sitesList.add(
          selected.siteLink, false, selected.category, selected.siteName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("onStartIconPress called"),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (err) {
      //print('Caught error: $err');
    }
    return true;
  }

  bool onEndIconPress(BuildContext context, RecommendedSite selected) {
    try {
      sitesList.delete(selected.iconUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Removed site"),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (err) {
      //print('Caught error: $err');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(recommendedList.items[0].name),
          backgroundColor: Color(recommendedList.items[0].color),
          actions: <Widget>[
            if (isLoading)
              IconButton(
                icon: AnimatedBuilder(
                  animation: _refreshIconController,
                  builder: (_, child) {
                    return Transform.rotate(
                      angle: _refreshIconController.value * 3 * 3.1415,
                      child: child,
                    );
                  },
                  child: const Icon(Icons.autorenew),
                ),
                onPressed: () => {},
              )
          ]),
      body: Stack(
        children: [
          isLoading == false
              ? Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: recommendedList.items.isEmpty
                      ? null
                      : ListView.separated(
                          itemCount: recommendedList.items[0].sites.length,
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, index) {
                            final item = recommendedList.items[0].sites[index];
                            return InkWell(
                              child: ListTile(
                                  minLeadingWidth: 30,
                                  leading: SiteLogo(iconUrl: item.iconUrl),
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
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: darkMode
                                                  ? ThemeColor.light1
                                                  : ThemeColor.dark1,
                                            ),
                                          ),
                                        ),
                                      ]),
                                  isThreeLine: false,
                                  trailing: Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: AnimateIcons(
                                      startIconColor: darkMode
                                          ? Colors.white
                                          : Colors.black45,
                                      endIconColor: darkMode
                                          ? Colors.white
                                          : Colors.black45,
                                      startIcon: Icons.add,
                                      endIcon: Icons.check,
                                      startTooltip: "Add",
                                      endTooltip: "Remove",
                                      controller: c1,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      clockwise: false,
                                      onEndIconPress: () =>
                                          onEndIconPress(context, item),
                                      onStartIconPress: () {
                                        onStartIconPress(context, item)
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
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: darkMode
                                                    ? ThemeColor.light3
                                                    : ThemeColor.dark3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))),
                            );
                          }))
              : Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      /*AnimatedOpacity(
                        opacity: isLoading ? opacityAnimation : 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: */
                      EmptySection(
                        title: 'Searching...',
                        description: '', //sitesList.itemLoading,
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
