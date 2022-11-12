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
                    setState(() async {
                      dropdownValue = value!;
                      await loadData();
                    });
                  },
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ))
        ]),
        body: Stack(
          children: [
            isLoading == false
                ? GridView.builder(
                    itemCount: recommendedList.items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 4
                          : 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                      childAspectRatio: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 1.3
                          : 0.9,
                    ),
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      return Card(
                        elevation: 0.0,
                        //color: Color(recommendedList.items[index].color),
                        //color: Color.fromARGB(255, 236, 236, 236),
                        color: Color(recommendedList.items[index].color),
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => RecommendedSitesPage(
                                      language:
                                          recommendedList.items[index].language,
                                      category:
                                          recommendedList.items[index].name))),
                          child: GridTile(
                              footer: GridTileBar(
                                backgroundColor: Colors.black.withAlpha(50),
                                title: Text(
                                  recommendedList.items[index].name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Icon(
                                  IconData(
                                      recommendedList.items[index].iconData,
                                      fontFamily: 'MaterialIcons'),
                                  color: Colors.white70,
                                  size: 50,
                                ),
                              )),
                        ),
                      );
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
          ],
        ));
  }
}
