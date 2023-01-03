import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/recommended_list.dart';
import 'package:rss_aggregator_flutter/screens/recommended_sites_page.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';

class RecommendedCategoriesPage extends StatefulWidget {
  const RecommendedCategoriesPage({Key? key}) : super(key: key);

  @override
  State<RecommendedCategoriesPage> createState() =>
      _RecommendedCategoriesPageState();
}

List<String> list = <String>['Italiano', 'English'];

class _RecommendedCategoriesPageState extends State<RecommendedCategoriesPage>
    with SingleTickerProviderStateMixin {
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
      dropdownValue = Platform.localeName.toLowerCase().contains("it")
          ? 'Italiano'
          : 'English';
      await loadData();
    });
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
      isLoading = true;
      setState(() {});

      await recommendedList.load(dropdownValue, '');
    } catch (err) {
      //print('Caught error: $err');
    }
    isLoading = false;
    setState(() {});
  }

  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Color.fromARGB(255, 236, 236, 236),
        appBar: AppBar(title: const Text('Recommendations'), actions: <Widget>[
          isLoading
              ? IconButton(
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
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                  value: dropdownValue,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: ThemeColor.primaryColorLight,
                  //underline: SizedBox(),
                  //iconEnabledColor: Colors.white,
                  //focusColor: Colors.white,
                  //iconDisabledColor: Colors.white,
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    dropdownValue = value!;
                    loadData();
                  },
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ))
        ]),
        body: Container(
          padding: const EdgeInsets.only(right: 7, left: 7, top: 7, bottom: 7),
          color: darkMode ? ThemeColor.dark1.withAlpha(180) : ThemeColor.light2,
          child: isLoading == false
              ? GridView.builder(
                  itemCount: recommendedList.items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 5
                        : 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 1.3
                        : 0.8,
                  ),
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    return Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: darkMode
                                ? ThemeColor.dark3.withAlpha(0)
                                : Colors.black.withAlpha(10),
                            width: 0.0,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 0.0,
                        //color: Color(recommendedList.items[index].color),
                        color: darkMode
                            ? ThemeColor.dark2.withAlpha(150)
                            : ThemeColor.light1.withAlpha(150),
                        child: InkWell(
                            onTap: () {
                              Future.delayed(const Duration(milliseconds: 120))
                                  .then((value) => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RecommendedSitesPage(
                                                  language: recommendedList
                                                      .items[index].language,
                                                  category: recommendedList
                                                      .items[index].name))));
                            },
                            hoverColor: darkMode
                                ? ThemeColor.dark3.withAlpha(50)
                                : ThemeColor.light1.withAlpha(70),
                            highlightColor: darkMode
                                ? ThemeColor.dark3.withAlpha(150)
                                : Color(recommendedList.items[index].color)
                                    .withAlpha(40),
                            splashColor: darkMode
                                ? ThemeColor.dark1
                                : Color(recommendedList.items[index].color)
                                    .withAlpha(150),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(
                                        recommendedList.items[index].color),
                                  ),
                                  child: Icon(
                                    IconData(
                                        recommendedList.items[index].iconData,
                                        fontFamily: 'MaterialIcons'),
                                    color: Colors.white70,
                                    size: 37,
                                  ),
                                ),
                                Text(
                                  recommendedList.items[index].name,
                                )
                              ],
                            )));
                  },
                )
              : Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: EmptySection(
                          title: 'Loading',
                          description: '...',
                          icon: Icons.query_stats,
                          darkMode: darkMode,
                        ),
                      ),
                    ],
                  ),
                ),
        ));
  }
}
