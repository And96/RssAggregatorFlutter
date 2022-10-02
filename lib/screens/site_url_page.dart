import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
// ignore: depend_on_referenced_packages

class SiteUrlPage extends StatefulWidget {
  const SiteUrlPage({Key? key, required this.textInput}) : super(key: key);

  final String textInput;

  @override
  State<SiteUrlPage> createState() => _SiteUrlPageState();
}

class _SiteUrlPageState extends State<SiteUrlPage> {
  TextEditingController mycontroller = TextEditingController();

  @override
  void initState() {
    mycontroller.text = widget.textInput;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.textInput.trim() == ""
            ? const Text('Edit Site')
            : const Text('Add Site'),
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
        icon: const Icon(Icons.check),
        label: const Text('Save'),
        onPressed: () {
          Navigator.pop(context, mycontroller.text);
        },
      ),
    );
  }
}
