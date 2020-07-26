import 'package:audio_service/audio_service.dart';
import 'package:curator/Models/CRssFeedItem.dart';
import 'package:curator/Models/CRssFeed.dart';
import 'package:curator/Utilities/audio.dart';
import 'package:curator/constants.dart';
import 'package:flutter/material.dart';
import 'package:curator/dbHelper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;

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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await getFeedItems(_selectedCat);
    await getCategories();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle greyTextStyle = new TextStyle(color: Colors.grey);

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
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _readUI = false;
                    _bookmarkUI = false;
                    getFeedItems(_selectedCat);
                  });
                },
                child: !_bookmarkUI && !_readUI
                    ? Icon(
                        Icons.bookmark,
                        color: Colors.black,
                      )
                    : Icon(
                        Icons.bookmark,
                        color: Colors.white,
                      ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _readUI = true;
                    _bookmarkUI = false;
                    getFeedItems(_selectedCat);
                  });
                },
                child: _readUI
                    ? Icon(
                        Icons.book,
                        color: Colors.black,
                      )
                    : Icon(
                        Icons.book,
                        color: Colors.white,
                      ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _bookmarkUI = true;
                    _readUI = false;
                    getFeedItems(_selectedCat);
                  });
                },
                child: _bookmarkUI
                    ? Icon(
                        Icons.bookmark,
                        color: Colors.black,
                      )
                    : Icon(
                        Icons.bookmark,
                        color: Colors.white,
                      ),
              ),
            ],
          ),
          Container(
            height: 20,
            child: ListView.builder(
              itemCount: _categories.length,
              padding: const EdgeInsets.all(2.0),
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSelected[_selectedCat] = false;
                        _selectedCat = _categories[index];
                        _isSelected[_selectedCat] = true;
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
              child: SmartRefresher(
                enablePullDown: true,
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.builder(
                    itemCount: _feeditems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: GestureDetector(
                          onLongPress: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.all(5),
                                                child: RaisedButton(
                                                  onPressed: () {
                                                    saveBookmark(index);
                                                  },
                                                  child: Text("Save"),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(5),
                                                child: RaisedButton(
                                                  onPressed: () {
                                                    readRssitem(index);
                                                  },
                                                  child: Text("Listened"),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Text("Title:"),
                                                Text(_feeditems[index].title)
                                              ],
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Text("Descrition")),
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child:
                                                  Text(_feeditems[index].desc)),
                                          getAuthor(_feeditems[index].author),
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Text("PubDate:"),
                                                Text(_feeditems[index].pubDate)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
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
                                child: Text(_feeditems[index].title),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
          )
        ],
      ),
    );
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
    _dbHelper
        .insertRssFeedtem(_feeditems[index], podcastBookmarks)
        .then((value) {
      Navigator.of(context).pop();
    });
  }

  readRssitem(int index) {
    _feeditems[index].read = true;
    _dbHelper.editRssFeedItem(_feeditems[index], podcastRssItems).then((value) {
      Navigator.of(context).pop();
    });
  }

  playAudio(int index) {
    setState(() {
      if (_curAudio == -1) {
        _curAudio = index;
        startAudio(_feeditems[index].url);
      } else {
        stopAudio();
        _curAudio = index;
        startAudio(_feeditems[index].url);
      }
    });
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

  getFeedItems(String cat) {
    _feeditems.clear();
    if (_bookmarkUI) {
      _dbHelper.getBookmarks(podcastBookmarks, cat).then((feedsItems) {
        setState(() {
          _feeditems += feedsItems;
        });
      });
    } else if (_readUI) {
      _dbHelper.getReadRssItems(cat, webRssItems).then((feedItems) {
        setState(() {
          _feeditems = feedItems;
        });
      });
    } else {
      _dbHelper.getRssFeeds(cat, podcastFeeds).then((feeds) {
        feeds.forEach((feed) async {
          print(feed.url);
          var rssFeed =
              new RssFeed.parse((await http.Client().get(feed.url)).body);
          _dbHelper.getUnreadRssItems(cat, podcastRssItems).then((feedItems) {
            if (feed.lastBuildDate != rssFeed.lastBuildDate) {
              rssFeed.items.forEach((feedItem) {
                String url = feedItem.enclosure.url;
                CRssFeedItem item = new CRssFeedItem(
                    title: feedItem.title,
                    desc: feedItem.description,
                    url: url,
                    mediaURL: url,
                    read: false,
                    picURL: "",
                    pubDate: feedItem.pubDate,
                    author: feedItem.author);

                _dbHelper.hasFeeditem(item, podcastRssItems).then((value) {
                  if (!value) {
                    _feeditems.add(item);
                    _dbHelper.insertRssFeedtem(item, podcastRssItems);
                  }
                });
              });
            }

            setState(() {
              _feeditems += feedItems;
            });
          });
        });
      });
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
                      _categories.add(catTextController.text);
                      getFeedItems(_selectedCat);
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
                            String rssURL = rssTextController.text;
                            final response =
                                await http.Client().get(Uri.parse(rssURL));
                            var rssFeed = new RssFeed.parse(response.body);
                            String url = "";
                            if (rssFeed.image != null) url = rssFeed.image.url;
                            final CRssFeed rss = new CRssFeed(
                                title: rssFeed.title,
                                desc: rssFeed.description,
                                picURL: url,
                                catgry: catgry,
                                url: rssURL,
                                lastBuildDate: rssFeed.lastBuildDate,
                                author: rssFeed.author);

                            _dbHelper
                                .insertRssFeed(rss, podcastFeeds)
                                .then((value) {
                              setState(() {
                                _isSelected[_selectedCat] = false;
                                _selectedCat = catgry;
                                _isSelected[catgry] = true;
                              });
                              getFeedItems(_selectedCat);
                              rssTextController.dispose();
                              Navigator.of(context).pop();
                            });
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
      params: {'url': url},
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
