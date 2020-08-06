import 'package:audio_service/audio_service.dart';
import 'package:curator/Models/CRssFeedItem.dart';
import 'package:curator/Models/CRssFeed.dart';
import 'package:curator/Screens/feedsScreen.dart';
import 'package:curator/Utilities/audio.dart';
import 'package:curator/Utilities/utilities.dart';
import 'package:curator/constants.dart';
import 'package:flutter/material.dart';
import 'package:curator/dbHelper.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;

BuildContext _scaffoldContext;

class PodcastRssScreen extends StatefulWidget {
  PodcastRssScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PodcastRssScreenState createState() => _PodcastRssScreenState();
}

class _PodcastRssScreenState extends State<PodcastRssScreen> {
  List<CRssFeedItem> _feeditems = [];
  List<String> _categories = [];
  Map<String, bool> _isSelected = {};
  String _selectedCat = "All";
  int _curAudio = -1;
  bool _bookmarkUI = false;
  bool _readUI = false;

  DbHelper _dbHelper = new DbHelper();

  @override
  void initState() {
    getFeedItems(_selectedCat);
    getCategories();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);

  // void _onRefresh() async {
  //   await getFeedItems(_selectedCat);
  //   await getCategories();
  //   await Future.delayed(Duration(milliseconds: 1000));
  //   _refreshController.refreshCompleted();
  // }

  // void _onLoading() async {
  //   await Future.delayed(Duration(milliseconds: 1000));
  //   _refreshController.loadComplete();
  // }

  @override
  Widget build(BuildContext context) {
    TextStyle greyTextStyle = new TextStyle(color: Colors.grey);
    _scaffoldContext = context;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddDialog(context);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
        elevation: 2.0,
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (context) => FeedsScreen(true)));
                },
                child: Text("Feeds"),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _readUI = false;
                    _bookmarkUI = false;
                    getFeedItems(_selectedCat);
                    // getFeedItems(_selectedCat);
                    Utilities.vibrate();
                  });
                },
                child: !_bookmarkUI && !_readUI
                    ? Icon(
                        Icons.rss_feed,
                        color: Colors.black,
                      )
                    : Icon(
                        Icons.rss_feed,
                        color: Colors.grey,
                      ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _readUI = true;
                    _bookmarkUI = false;
                    getFeedItems(_selectedCat);
                    // getFeedItems(_selectedCat);
                    Utilities.vibrate();
                  });
                },
                child: _readUI
                    ? Icon(
                        Icons.done_all,
                        color: Colors.black,
                      )
                    : Icon(
                        Icons.done_all,
                        color: Colors.grey,
                      ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _bookmarkUI = true;
                    _readUI = false;
                    getFeedItems(_selectedCat);
                    // getFeedItems(_selectedCat);
                    Utilities.vibrate();
                  });
                },
                child: _bookmarkUI
                    ? Icon(
                        Icons.bookmark,
                        color: Colors.black,
                      )
                    : Icon(
                        Icons.bookmark,
                        color: Colors.grey,
                      ),
              ),
            ],
          ),
          getClearBookmarkWidget(),
          Container(
            height: 30,
            child: ListView.builder(
              itemCount: _categories.length,
              padding: const EdgeInsets.all(2.0),
              itemBuilder: (context, index) {
                return GestureDetector(
                    onLongPress: () {
                      if (_categories[index].compareTo("All") != 0)
                        showDialog(
                            builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  child: Container(
                                    height: 120,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text("Delete " +
                                            _categories[index] +
                                            "?"),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            RaisedButton(
                                              onPressed: () {
                                                _dbHelper
                                                    .deleteCat(
                                                        _categories[index],
                                                        podcastCategories,
                                                        podcastFeeds,
                                                        podcastRssItems)
                                                    .then((value) {
                                                  setState(() {
                                                    Navigator.pop(context);
                                                    getCategories();
                                                    _isSelected[_selectedCat] =
                                                        false;
                                                    _selectedCat = "All";
                                                    _isSelected["All"] = true;
                                                    getFeedItems(_selectedCat);
                                                  });
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
                                ),
                            context: context);
                    },
                    onTap: () {
                      Utilities.vibrate();
                      setState(() {
                        _isSelected[_selectedCat] = false;
                        _selectedCat = _categories[index];
                        _isSelected[_selectedCat] = true;
                        //  getFeedItems(_selectedCat);
                        getFeedItems(_selectedCat);
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
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                  itemCount: _feeditems.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {},
                      onLongPress: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                            child: RaisedButton(
                                              onPressed: () {
                                                _feeditems[index].bookmarked
                                                    ? deleteBookmark(index)
                                                    : saveBookmark(index);
                                              },
                                              child:
                                                  _feeditems[index].bookmarked
                                                      ? Text("Delete Bookmark")
                                                      : Text("Save"),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                            child: RaisedButton(
                                              onPressed: () {
                                                _feeditems[index].read
                                                    ? unReadRssitem(index)
                                                    : readRssitem(index);
                                              },
                                              child: _feeditems[index].read
                                                  ? Text("Unlisten")
                                                  : Text("Listened"),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65,
                                            child: Text(
                                              _feeditems[index].title,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.visible,
                                            ),
                                          )),
                                      Divider(),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          _feeditems[index].pubDate,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Divider(),
                                      getAuthor(_feeditems[index].author),
                                      getAuthorDivider(
                                          _feeditems[index].author),
                                      Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Html(
                                              data: _feeditems[index].desc))
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: Card(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                child: _curAudio == index
                                    ? Icon(Icons.stop)
                                    : Icon(Icons.play_circle_filled),
                                onTap: () {
                                  _curAudio == index
                                      ? stopAudio()
                                      : playAudio(index);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  Utilities.trimText(_feeditems[index].title)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }

  getClearBookmarkWidget() {
    if (_readUI) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _dbHelper.clearTable(podcastRssItems).then((value) {
                getFeedItems(_selectedCat);
                // getFeedItems(_selectedCat);
              });
            },
            child: Text("Clear"),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  deleteBookmark(int index) {
    _feeditems[index].bookmarked = false;
    _dbHelper
        .editRssFeedItem(_feeditems[index], podcastRssItems)
        .then((value) => getFeedItems(_selectedCat));
  }

  getAuthorDivider(String author) {
    if (author != null && author.compareTo("") != 0) {
      return Divider();
    } else {
      return Container();
    }
  }

  getAuthor(String author) {
    if (author != null && author.compareTo("") != 0) {
      return Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[Text("Author:"), Text(author)],
        ),
      );
    } else {
      return Container();
    }
  }

  saveBookmark(int index) {
    _feeditems[index].bookmarked = true;
    _dbHelper.editRssFeedItem(_feeditems[index], podcastRssItems).then((value) {
      print(_feeditems[index].bookmarked.toString() + _feeditems[index].catgry);
      Navigator.of(context).pop();
      getFeedItems(_selectedCat);
    });
  }

  readRssitem(int index) {
    _feeditems[index].read = true;
    _dbHelper.editRssFeedItem(_feeditems[index], podcastRssItems).then((value) {
      Navigator.of(context).pop();
      getFeedItems(_selectedCat);
      // getFeedItems(_selectedCat);
    });
  }

  unReadRssitem(int index) {
    _feeditems[index].read = false;
    _dbHelper.editRssFeedItem(_feeditems[index], podcastRssItems).then((value) {
      Navigator.of(context).pop();
      getFeedItems(_selectedCat);
      // getFeedItems(_selectedCat);
    });
  }

  playAudio(int index) {
    if (_curAudio == -1 && !AudioServiceBackground.state.playing) {
      setState(() {
        _curAudio = index;
      });
      final snackBar = SnackBar(content: Text('Audio Loading'));
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
      startAudio(_feeditems[index].url);
    } else if (_curAudio > -1 || AudioServiceBackground.state.playing) {
      stopAudio();
      setState(() {
        _curAudio = index;
      });
      final snackBar = SnackBar(content: Text('Audio Loading'));
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
      startAudio(_feeditems[index].url);
    }
  }

  getCategories() {
    _dbHelper.getCategories(podcastCategories).then((categories) {
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

  getFeedItems(String _cat) {
    try {
      _feeditems.clear();
      if (_bookmarkUI) {
        _dbHelper.getBookmarks(_cat, podcastRssItems).then((feedsItems) {
          if (_cat.compareTo(_selectedCat) == 0 && _bookmarkUI)
            setState(() {
              _feeditems += feedsItems;
            });
        });
      } else if (_readUI) {
        _dbHelper.getReadRssItems(_cat, podcastRssItems).then((feedItems) {
          if (_cat.compareTo(_selectedCat) == 0 && _readUI)
            setState(() {
              _feeditems = feedItems;
            });
        });
      } else {
        _dbHelper.getRssFeeds(_cat, podcastFeeds).then((feeds) {
          if (_cat.compareTo(_selectedCat) == 0 && !_readUI && !_bookmarkUI)
            feeds.forEach((feed) async {
              print(feed.url);
              String FeedBody = (await http.Client().get(feed.url)).body;

              var rssFeed = new RssFeed.parse(FeedBody);

              _dbHelper
                  .getUnreadRssItems(_cat, podcastRssItems)
                  .then((feedItems) {
                if (feed.lastBuildDate == null ||
                    feed.lastBuildDate != rssFeed.lastBuildDate) {
                  if (_cat.compareTo(_selectedCat) == 0 &&
                      !_readUI &&
                      !_bookmarkUI)
                    rssFeed.items.forEach((feedItem) {
                      if (_cat.compareTo(_selectedCat) == 0 &&
                          !_readUI &&
                          !_bookmarkUI) {
                        String url = feedItem.enclosure.url;
                        CRssFeedItem item = new CRssFeedItem(
                            title: feedItem.title,
                            desc: feedItem.description,
                            url: url,
                            mediaURL: url,
                            read: false,
                            picURL: "",
                            pubDate: feedItem.pubDate,
                            author: feedItem.author,
                            bookmarked: false,
                            catgry: _cat);

                        _dbHelper
                            .hasFeeditem(item, podcastRssItems)
                            .then((value) {
                          if (!value) {
                            _feeditems.add(item);
                            _dbHelper.insertRssFeedtem(item, podcastRssItems);
                          }
                        });
                      }
                    });
                }

                setState(() {
                  if (_cat.compareTo(_selectedCat) == 0 &&
                      !_readUI &&
                      !_bookmarkUI) _feeditems += feedItems;
                });
              });
            });
        });
      }
    } catch (e) {
      final snackBar = SnackBar(content: Text('Some Error has occured'));
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
      print(e.toString());
    }
  }

  getImageWidget(String url) {
    if (url == null || url.compareTo("") == 0)
      return Container();
    else {
      return Image.network(url);
    }
  }

  showAddDialog(BuildContext context) {
    final rssTextController = TextEditingController();
    final catTextController = TextEditingController();
    String catgry;
    Dialog catDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        height: 120,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: catTextController,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Category'),
              ),
              RaisedButton(
                onPressed: () {
                  _dbHelper
                      .insertCategory(catTextController.text, podcastCategories)
                      .then((value) {
                    setState(() {
                      _isSelected[catTextController.text] = true;
                      _isSelected[_selectedCat] = false;
                      _selectedCat = catTextController.text;
                      _categories.add(catTextController.text);
                      getFeedItems(_selectedCat);
                      // getFeedItems(_selectedCat);
                    });
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  });
                },
                child: Text("Add"),
              )
            ],
          ),
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                height: 160,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: rssTextController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Rss Feed Link'),
                      ),
                      Row(
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
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return catDialog;
                                  });
                            },
                            child: Icon(Icons.add),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 320.0,
                        height: 40,
                        child: RaisedButton(
                          onPressed: () async {
                            final snackBar = SnackBar(content: Text('Loading'));
                            Scaffold.of(_scaffoldContext)
                                .showSnackBar(snackBar);
                            try {
                              String rssURL = rssTextController.text;
                              final response =
                                  await http.Client().get(Uri.parse(rssURL));
                              var rssFeed = new RssFeed.parse(response.body);
                              if (rssFeed.items[0].enclosure == null ||
                                  rssFeed.items[0].enclosure.url == null)
                                throw Exception();
                              if (catgry.compareTo("") == 0) catgry = "All";
                              String url = "";
                              if (rssFeed.image != null)
                                url = rssFeed.image.url;
                              final CRssFeed rss = new CRssFeed(
                                  title: rssFeed.title,
                                  desc: rssFeed.description,
                                  picURL: url,
                                  catgry: catgry,
                                  url: rssURL,
                                  lastBuildDate: rssFeed.lastBuildDate,
                                  author: rssFeed.author,
                                  atom: false);

                              _dbHelper
                                  .insertRssFeed(rss, podcastFeeds)
                                  .then((value) {
                                setState(() {
                                  _isSelected[_selectedCat] = false;
                                  _selectedCat = catgry;
                                  _isSelected[catgry] = true;
                                  getFeedItems(_selectedCat);
                                  // getFeedItems(_selectedCat);
                                });
                                Navigator.of(context).pop();
                              });
                            } catch (e) {
                              Navigator.of(context).pop();
                              final snackBar =
                                  SnackBar(content: Text('Invalid Feed'));
                              Scaffold.of(_scaffoldContext)
                                  .showSnackBar(snackBar);
                            }
                          },
                          child: Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: const Color(0xFF1BC0C5),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  startAudio(String url) async {
    print("screeen:" + url);
    await AudioService.start(
      backgroundTaskEntrypoint: _myEntrypoint,
      androidNotificationIcon: 'mipmap/ic_launcher',
      params: {'url': url, 'curAudio': _curAudio},
    );
  }

  stopAudio() async {
    setState(() {
      _curAudio = -1;
    });
    await AudioService.stop();
  }
}

void _myEntrypoint() => AudioServiceBackground.run(() => AudioTasks());
