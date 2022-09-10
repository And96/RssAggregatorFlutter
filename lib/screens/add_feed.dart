import 'dart:convert';

import 'package:favicon/favicon.dart' hide Icon;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Sito {
  var link = "";
  var iconUrl = "";
  Sito({
    required this.link,
    required this.iconUrl,
  });

  factory Sito.fromJson(Map<String, dynamic> json) {
    return Sito(
      link: json["link"],
      iconUrl: json["iconUrl"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "link": link,
      "iconUrl": iconUrl,
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
              minLines: 6,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste RSS URLs here',
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
