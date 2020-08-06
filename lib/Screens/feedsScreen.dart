import 'package:curator/Models/CRssFeed.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../dbHelper.dart';
import 'package:curator/Utilities/utilities.dart';

class FeedsScreen extends StatefulWidget {
  FeedsScreen(this._podcast);

  final bool _podcast;

  @override
  _FeedsScreen createState() => _FeedsScreen();
}

class _FeedsScreen extends State<FeedsScreen> {
  List<CRssFeed> _feeds = [];
  List<String> _categories = [];
  Map<String, bool> _isSelected = {};
  String _selectedCat = "All";
  DbHelper _dbHelper = new DbHelper();
  TextStyle greyTextStyle = new TextStyle(color: Colors.grey);
  String _whichDB = "";
  String _whichCat = "";

  @override
  void initState() {
    _whichDB = widget._podcast ? podcastFeeds : webFeeds;
    _whichCat = widget._podcast ? podcastCategories : webCategories;
    getFeeds(_selectedCat);
    getCategories();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: Column(
          children: <Widget>[
            Container(
              height: 30,
              child: ListView.builder(
                itemCount: _categories.length,
                padding: const EdgeInsets.all(2.0),
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        Utilities.vibrate();
                        setState(() {
                          _isSelected[_selectedCat] = false;
                          _selectedCat = _categories[index];
                          _isSelected[_selectedCat] = true;
                          getFeeds(_selectedCat);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: _isSelected[_categories[index]]
                            ? Text(_categories[index])
                            : Text(
                                _categories[index],
                                style: greyTextStyle,
                              ),
                      ));
                },
                scrollDirection: Axis.horizontal,
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: ListView.builder(
                    itemCount: _feeds.length,
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(_feeds[index].title),
                          Spacer(),
                          GestureDetector(
                              onTap: () {
                                editCat(index);
                              },
                              child: Text(
                                "Edit",
                                style: TextStyle(backgroundColor: Colors.blue),
                              )),
                          GestureDetector(
                              onTap: () {
                                deleteFeed(index);
                              },
                              child: Text(
                                "Delete",
                                style: TextStyle(backgroundColor: Colors.red),
                              ))
                        ],
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  deleteFeed(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Delete " + _feeds[index].title + "?"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () {
                          _dbHelper
                              .deleteRssFeed(_feeds[index].id, _whichDB)
                              .then((value) {
                            Navigator.pop(context);
                            getFeeds(_selectedCat);
                          });
                        },
                        child: Text("Yes"),
                      ),
                      RaisedButton(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  editCat(int index) {
    String catgry;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            height: 120,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DropdownButton<String>(
                    value: catgry,
                    onChanged: (value) {
                      setState(() {
                        catgry = value;
                      });
                    },
                    hint: Text("category"),
                    items: _categories.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                  ),
                  RaisedButton(
                    onPressed: () {
                      _feeds[index].catgry = catgry;
                      _dbHelper
                          .editRssFeed(_feeds[index], _whichDB)
                          .then((value) {
                        getFeeds(_selectedCat);
                        Navigator.of(context).pop();
                      });
                    },
                    child: Text("Edit"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
    _dbHelper.editRssFeed(_feeds[index], _whichDB);
  }

  getCategories() {
    _dbHelper.getCategories(_whichCat).then((categories) {
      setState(() {
        _categories = categories;
        _categories.forEach((cat) {
          if (cat.compareTo("All") == 0)
            _isSelected['All'] = true;
          else {
            _isSelected[cat] = false;
          }
        });
      });
    });
  }

  getFeeds(String cat) {
    _feeds.clear();
    _dbHelper.getRssFeeds(cat, _whichDB).then((feeds) {
      setState(() {
        _feeds = feeds;
      });
    });
  }
}
