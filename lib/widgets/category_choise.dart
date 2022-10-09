import 'package:flutter/material.dart';
import 'package:grouped_buttons_ns/grouped_buttons_ns.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';

class CategoryChoice extends StatelessWidget {
  const CategoryChoice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grouped Buttons Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePagex(),
    );
  }
}

class HomePagex extends StatefulWidget {
  const HomePagex({super.key});

  @override
  _HomePagexState createState() => _HomePagexState();
}

List<S2Choice<String>> fruitsx = [
  S2Choice<String>(value: 'app', title: 'Apple'),
  S2Choice<String>(value: 'ore', title: 'Orange'),
  S2Choice<String>(value: 'mel', title: 'Melon'),
];

class _HomePagexState extends State<HomePagex> {
  List<String> _checked = ['A', 'B'];
  String _picked = 'Two';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Grouped Buttons Example'),
        ),
        body: Column(
          children: <Widget>[
            const SizedBox(height: 7),
            SmartSelect<String>.single(
                title: 'Days',
                selectedValue: _day,
                modalType: S2ModalType.fullPage,
                choiceItems: fruitsx,
                onChange: (selected) => setState(() => _day = selected.value),
                tileBuilder: (context, state) {
                  return S2Tile.fromState(
                    state,
                    isTwoLine: false,
                    leading: const Icon(Icons.sell),
                    trailing: const Icon(
                      Icons.sell,
                      size: 0,
                    ),
                    title: const Text("Categories"),
                  );
                }),
            const Divider(indent: 20),
            SmartSelect<String>.single(
              title: 'Month',
              selectedValue: _month,
              choiceItems: fruitsx,
              onChange: (selected) => setState(() => _month = selected.value),
            ),
            const SizedBox(height: 7),
          ],
        ));
    //
  }

  String _day = 'fri';
  String _month = 'apr';

/*
  Widget _body() {
    return ListView(children: <Widget>[
      //--------------------
      //SIMPLE USAGE EXAMPLE
      //--------------------

      //BASIC CHECKBOXGROUP
      Container(
        padding: const EdgeInsets.only(left: 14.0, top: 14.0),
        child: Text(
          'Basic CheckboxGroup',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),

      CheckboxGroup(
        labels: <String>[
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
        ],
        disabled: ['Wednesday', 'Friday'],
        onChange: (bool isChecked, String label, int index) =>
            print('isChecked: $isChecked   label: $label  index: $index'),
        onSelected: (List<String> checked) =>
            print('checked: ${checked.toString()}'),
      ),

      //BASIC RADIOBUTTONGROUP
      Container(
        padding: const EdgeInsets.only(left: 14.0, top: 14.0),
        child: Text(
          'Basic RadioButtonGroup',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),

      RadioButtonGroup(
        labels: [
          'Option 1',
          'Option 2',
          'Option 3',
        ],
        disabled: ['Option 1'],
        onChange: (String label, int index) =>
            print('label: $label index: $index'),
        onSelected: (String label) => print(label),
      ),
    ]);
  }*/
}
