import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/core/categories_list.dart';
// ignore: depend_on_referenced_packages
import 'package:rss_aggregator_flutter/core/category.dart';
import 'package:rss_aggregator_flutter/core/sites_list.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/widgets/empty_section.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';

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

  Future<void> _displayTextInputDialog(BuildContext context) async {
    _textFieldController.text = '';
    Widget saveButton = TextButton(
      child: const Text("Save"),
      onPressed: () {
        setState(() {
          categoriesList.add(_textFieldController.text, -1);
        });
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

  ColorSwatch? _selectedColor = Colors.blueGrey;

  void _updateItemLoading(String itemLoading) {
    setState(() {});
  }

  void _openColorPickerDialog(String name, Widget content) {
    Widget saveButton = TextButton(
      child: const Text("Save"),
      onPressed: () {
        setState(() {
          categoriesList.add(name, _selectedColor!.value);
        });

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
        selectedColor: Color(color),
        allowShades: false,
        onMainColorChange: (color) => setState(() => _selectedColor = color),
      ),
    );
  }

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
          onTap: () {
            Navigator.pop(context, category.name);
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Rename'),
          onTap: () {
            _displayTextInputDialog(context);
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
        SmartSelect<String>.multiple(
            title: 'Category',
            selectedValue: const [], //category.sites,
            modalType: S2ModalType.fullPage,
            choiceItems: S2Choice.listFrom<String, String>(
              source: sitesList.toList(),
              value: (index, item) => item,
              title: (index, item) => item,
            ),
            onChange: (selected) async {
              Navigator.pop(context);
              /*setState(() {
                sitesList.setCategory(site.siteName, selected.value);
              });*/
              SnackBar snackBar = SnackBar(
                duration: const Duration(milliseconds: 700),
                content: Text('Changed category to ${selected.value}'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            tileBuilder: (context, state) {
              return S2Tile.fromState(
                state,
                isTwoLine: false,
                leading: const Icon(Icons.list),
                trailing: const Icon(
                  Icons.sell,
                  size: 0,
                ),
                title: const Text("Choose sites"),
              );
            }),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete'),
          onTap: () {
            setState(() {
              categoriesList.delete(category.name);
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
                    angle: _refreshIconController.value * 4 * 3.1415,
                    child: child,
                  );
                },
                child: const Icon(Icons.refresh),
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
                  child: Scrollbar(
                      child: ListView.separated(
                          itemCount: categoriesList.items.length,
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, index) {
                            final item = categoriesList.items[index];
                            return InkWell(
                              child: ListTile(
                                minLeadingWidth: 30,
                                leading: SizedBox(
                                  height: double.infinity,
                                  width: 17,
                                  child: item.color.toString().trim() == ""
                                      ? const Icon(Icons.sell)
                                      : Icon(Icons.sell,
                                          color: Color(item.color)),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: Text(
                                    (item.name.toString()),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: darkMode
                                          ? const Color.fromARGB(
                                              255, 210, 210, 210)
                                          : const Color.fromARGB(255, 5, 5, 5),
                                    ),
                                  ),
                                ),
                                isThreeLine: false,
                                onTap: () {
                                  showOptionDialog(context, item);
                                },
                                /*subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(
                                            child: Text(
                                              item.name.toString(),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: darkMode
                                                    ? const Color.fromARGB(
                                                        255, 150, 150, 150)
                                                    : const Color.fromARGB(
                                                        255, 80, 80, 80),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))*/
                              ),
                            );
                          })),
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
                _displayTextInputDialog(context);
              },
            ),
    );
  }
}
