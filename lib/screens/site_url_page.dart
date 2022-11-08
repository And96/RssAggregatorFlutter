import 'package:flutter/material.dart';

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

  _showInfoDialog(BuildContext context) async {
    var dialog = AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Come aggiungere un sito?',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        contentPadding: const EdgeInsets.all(12),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                  style: Theme.of(context).textTheme.titleMedium,
                  "Scrivi nella casella l'indirizzo url del sito internet o del feed RSS\n\nPuoi aggiungere piu siti contemporaneamente separandoli da ; oppure incollando il contenuto di un file OPML \n\nSe un sito non viene trovato potrebbe non supportare RSS"),
            )
          ],
        ));
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: widget.textInput.trim() == ""
              ? const Text('Configuration')
              : const Text('Configuration'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.help),
              tooltip: 'Help',
              onPressed: () {
                _showInfoDialog(context);
              },
            ), //
          ]),
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
                hintText: 'Incolla link qui',
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
