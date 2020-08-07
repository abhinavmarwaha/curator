import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html_main_element/html_main_element.dart';

class ZenReader extends StatefulWidget {
  ZenReader(this.url);

  final String url;

  @override
  _ZenReaderState createState() => _ZenReaderState();
}

class _ZenReaderState extends State<ZenReader> {
  String _bestElemReadability;

  @override
  void initState() {
    http.Client().get(widget.url).then((response) {
      var doc = html_parser.parse(response.bodyBytes);
      final scoreMapReadability = readabilityScore(doc.documentElement);
      setState(() {
        _bestElemReadability =
            readabilityMainElement(doc.documentElement).innerHtml.toString();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 0),
        child: SizedBox.expand(
          child: SingleChildScrollView(
            child: Html(
              data: _bestElemReadability == null ? "" : _bestElemReadability,
            ),
          ),
        ),
      ),
    );
  }
}
