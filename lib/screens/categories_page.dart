import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
// ignore: depend_on_referenced_packages
import 'package:rss_aggregator_flutter/core/category.dart';
import 'package:rss_aggregator_flutter/core/site.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/screens/news_page.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';
import 'package:rss_aggregator_flutter/widgets/site_logo_big.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late CategoriesList categoriesList = CategoriesList();
  late SitesList sitesList = SitesList(updateItemLoading: _updateItemLoading);
  bool darkMode = false;

  bool isLoading = true;

  final TextEditingController _textFieldController = TextEditingController();

  late String codeDialog;
  late String valueText;

  List<String> sitesSelectedCategory = [];

  Future<void> _displayTextInputDialog(
      BuildContext context, Category? categoryUpdated) async {
    _textFieldController.text =
        categoryUpdated == null ? '' : categoryUpdated.name;
    Widget saveButton = TextButton(
      child: const Text("Save"),
      onPressed: () {
        if (categoryUpdated != null) {
          categoriesList.delete(categoryUpdated.name);
          sitesList
              .renameCategory(categoryUpdated.name, _textFieldController.text)
              .then((value) => setState(() {}));
        }
        categoriesList
            .add(_textFieldController.text,
                categoryUpdated == null ? -1 : categoryUpdated.color)
            .then((value) => setState(() {}));
        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Category'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Write name here"),
            ),
            actions: [
              saveButton,
              cancelButton,
            ],
          );
        });
  }

  ColorSwatch? _selectedColor = ThemeColor()
      .createMaterialColor(Color(ThemeColor().defaultCategoryColor));

  void _updateItemLoading(String itemLoading) {
    setState(() {});
  }

  Future<bool> _changeCategory(
      S2MultiSelected<String> selectedValues, String categoryName) async {
    try {
      //Remove old category
      for (String siteLink in sitesSelectedCategory) {
        await sitesList.setCategory(siteLink, '');
      }
      //Add new category
      for (String siteLink in selectedValues.value) {
        await sitesList.setCategory(siteLink, categoryName);
      }
    } catch (err) {
      //print('Caught error: $err');
    }
    return true;
  }

  void _openColorPickerDialog(String name, Widget content) {
    Widget saveButton = TextButton(
      child: const Text("Save"),
      onPressed: () {
        categoriesList
            .add(name, _selectedColor!.value)
            .then((value) => setState(() {}));

        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(name),
          content: content,
          actions: [saveButton, cancelButton],
        );
      },
    );
  }

  void _openColorPicker(String name, int color) async {
    _openColorPickerDialog(
      name,
      MaterialColorPicker(
        //circleSize: 50,
        selectedColor: Color(color),
        colors: ThemeColor().getColorPicker(),
        allowShades: false,
        onMainColorChange: (color) => setState(() => _selectedColor = color),
      ),
    );
  }

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

  void showOptionDialog(BuildContext context, Category category) {
    var dialog = SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            "Options",
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      contentPadding: const EdgeInsets.all(8),
      children: <Widget>[
        const Divider(),
        ListTile(
          leading: const Icon(Icons.newspaper),
          title: const Text('Open news'),
          onTap: () async {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NewsPage(
                      siteFilter: '*',
                      categoryFilter: category.name,
                    )));
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Rename'),
          onTap: () {
            Navigator.pop(context);
            _displayTextInputDialog(context, category);
          },
        ),
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text('Choose color'),
          onTap: () {
            Navigator.pop(context);
            _openColorPicker(category.name, category.color);
          },
        ),
        SizedBox(
          width: 300,
          child: SmartSelect<String>.multiple(
              title: 'Select sites',
              selectedValue: sitesSelectedCategory,
              //sitesList.toList(category.name), //const [], //category.sites,*/
              modalType: S2ModalType.fullPage,
              //choiceGrouped: true,
              modalFilter: true,
              choiceItems: S2Choice.listFrom<String, Site>(
                source: sitesList.items,
                value: (index, item) => item.siteLink,
                title: (index, item) => item.siteName,
                subtitle: (index, item) => item.siteLink,
                meta: (index, item) => item.iconUrl,
                //group: (index, item) => item.category,
              ),
              choiceSecondaryBuilder: (context, state, choice) => SiteLogoBig(
                    iconUrl: choice.meta,
                    color: Colors.white,
                  ),
              onChange: (selected) async {
                Navigator.pop(context);
                SnackBar snackBar;
                _changeCategory(selected, category.name).then((value) => {
                      snackBar = SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content: Text('Changed category to ${category.name}'),
                      ),
                      ScaffoldMessenger.of(context).showSnackBar(snackBar),
                      sitesSelectedCategory = [],
                      setState(() {}),
                    });
              },
              tileBuilder: (context, state) {
                return S2Tile.fromState(
                  state,
                  isTwoLine: true,
                  leading: const Icon(Icons.list),
                  trailing: const Icon(
                    Icons.sell,
                    size: 0,
                  ),
                  title: const Text("Choose sites"),
                );
              }),
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete'),
          onTap: () {
            setState(() {
              categoriesList.delete(category.name);
              sitesList
                  .renameCategory(category.name, '')
                  .then((value) => setState(() {}));
            });
            Navigator.pop(context);
            const snackBar = SnackBar(
              duration: Duration(seconds: 1),
              content: Text('Deleted'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  showDeleteDialog(BuildContext context, String url) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        setState(() {
          categoriesList.delete(url);
        });
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      content: const Text("Delete all categories?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await categoriesList.load();
      await sitesList.load();
    } catch (err) {
      //print('Caught error: $err');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: categoriesList.items.isEmpty
            ? const Text('Categories')
            : Text('Categories (${categoriesList.items.length})'),
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
            ),
          if (categoriesList.items.isNotEmpty && !isLoading)
            IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
                onPressed: () => showDeleteDialog(context, "*")),
        ],
      ),
      body: Stack(
        children: [
          isLoading == false
              ? Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: ListView.separated(
                      itemCount: categoriesList.items.length,
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemBuilder: (BuildContext context, index) {
                        final item = categoriesList.items[index];
                        return InkWell(
                          child: ListTile(
                            minLeadingWidth: 55,
                            leading: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                    radius: 23,
                                    backgroundColor:
                                        Color(item.color).withAlpha(255),
                                    child: ClipRRect(
                                        child: item.color.toString().trim() ==
                                                    "" &&
                                                item.icon > 0
                                            ? const Icon(Icons.newspaper)
                                            : Icon(
                                                IconData(item.icon,
                                                    fontFamily:
                                                        'MaterialIcons'),
                                                color:
                                                    Colors.white.withAlpha(200),
                                                size: 25,
                                              ))),
                                /*Positioned(
                                    top: 25,v
                                    left: 25,
                                    child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Color(item.color),
                                        child: const Icon(
                                          Icons.label,
                                          size: 13,
                                          color: Colors.white,
                                        ))),*/
                              ],
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Text(
                                (item.name.toString()),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            subtitle: const Padding(
                              padding: EdgeInsets.only(top: 0),
                              child: Text(
                                ("Premi per modificare"),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            isThreeLine: false,
                            onTap: () {
                              sitesList.getSitesFromCategory(item.name).then(
                                  (value) => {
                                        sitesSelectedCategory = value,
                                        showOptionDialog(context, item)
                                      });
                            },
                          ),
                        );
                      }))
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
                          title: 'Searching...',
                          description: '...',
                          icon: Icons.manage_search,
                          darkMode: darkMode,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('New Category'),
              onPressed: () {
                _displayTextInputDialog(context, null);
              },
            ),
    );
  }
}
