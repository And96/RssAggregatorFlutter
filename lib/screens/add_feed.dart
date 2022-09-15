import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages

class Sito {
  var link = "";
  Sito({
    required this.link,
  });

  factory Sito.fromJson(Map<String, dynamic> json) {
    return Sito(
      link: json["link"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "link": link,
    };
  }

  @override
  String toString() => '{link: $link}';
}

class AddFeed extends StatefulWidget {
  const AddFeed({Key? key}) : super(key: key);

  @override
  State<AddFeed> createState() => _AddFeedState();
}

class _AddFeedState extends State<AddFeed> {
  TextEditingController mycontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Feed'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: mycontroller,
              minLines: 8,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste RSS address or OPML text here',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Feed'),
        onPressed: () {
          Navigator.pop(context, mycontroller.text);
        },
      ),
    );
  }
}
