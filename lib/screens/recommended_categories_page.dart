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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ThemeColor.isDarkMode().then((value) => {
            darkMode = value,
          });
      await loadData();
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
      await recommendedList.load(dropdownValue, '');
    } catch (err) {
      //print('Caught error: $err');
    }
    setState(() {
      isLoading = false;
    });
  }

  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    setState(() {
                      dropdownValue = value!;
                      loadData();
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
                          ? 3
                          : 2,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                      childAspectRatio: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 1.6
                          : 0.80,
                    ),
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      return Card(
                        elevation: 2.0,
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
                              backgroundColor: Colors.white.withAlpha(40),
                              title: Text(
                                recommendedList.items[index].name,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            child: Icon(
                              IconData(recommendedList.items[index].iconData,
                                  fontFamily: 'MaterialIcons'),
                              color: Colors.white,
                              size: 75,
                            ),
                          ),
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
