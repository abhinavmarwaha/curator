import 'package:curator/Models/CRssFeed.dart';
import 'package:curator/constants.dart';
import 'package:curator/dbHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webfeed/domain/rss_feed.dart';

class OpmlAddScreen extends StatelessWidget {
  const OpmlAddScreen({Key key, this.feeds, this.web}) : super(key: key);

  final List<CRssFeed> feeds;
  final bool web;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: MediaQuery.of(context).padding,
        child: Column(children: [
          RaisedButton(
            onPressed: () {
              Future.wait(feeds.map((e) => DbHelper().insertRssFeed(
                  e, web ? webFeeds : podcastFeeds))).then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
              });
            },
            child: Text("Save"),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: feeds.length,
                itemBuilder: (context, index) {
                  return CatSelect(feed: feeds[index], web: web);
                }),
          )
        ]),
      ),
    );
  }
}

class CatSelect extends StatefulWidget {
  const CatSelect({Key key, this.feed, this.web}) : super(key: key);

  _CatSelectState createState() => _CatSelectState();
  final bool web;
  final CRssFeed feed;
}

class _CatSelectState extends State<CatSelect> {
  final GlobalKey _menuKey = new GlobalKey();
  String selectedCat;
  DbHelper _dbHelper = new DbHelper();
  List<String> categories;
  String cats;

  bool opened = false;

  @override
  void initState() {
    if (widget.web ?? true) {
      cats = webCategories;
    } else {
      cats = podcastCategories;
    }
    _dbHelper.getCategories(cats).then((value) => setState(() {
          categories = value;
          selectedCat = categories.first;
        }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.feed.title ?? ""),
          PopupMenuButton(
            key: _menuKey,
            itemBuilder: (context) => categories
                .map(
                  (e) => PopupMenuItem<String>(child: Text(e), value: e),
                )
                .toList(),
            child: GestureDetector(
              onTap: () {
                dynamic state = _menuKey.currentState;
                setState(() {
                  opened = true;
                });

                state.showButtonMenu();
              },
              child: Container(
                width: 70,
                child: Card(
                  elevation: 2,
                  // shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          selectedCat ?? "def",
                        ),
                      ),
                      // Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Icon(
                          opened ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onSelected: (value) {
              setState(() {
                selectedCat = value;
                widget.feed.catgry = selectedCat;
                opened = false;
              });
            },
            onCanceled: () {
              setState(() {
                opened = false;
              });
            },
          )
        ],
      ),
    );
  }
}
