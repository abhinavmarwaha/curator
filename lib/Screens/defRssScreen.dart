import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:curator/Models/CRssFeedItem.dart';
import 'package:curator/Screens/ZenReader.dart';
import 'package:curator/Screens/opml_add_screen.dart';
import 'package:curator/Utilities/audio.dart';
import 'package:curator/Utilities/utilities.dart';
import 'package:curator/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:curator/Models/CRssFeed.dart';
import 'package:curator/dbHelper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:opmlparser/opmlparser.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
import './feedsScreen.dart';

import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;

BuildContext _scaffoldContext;

class DefRssScreen extends StatefulWidget {
  DefRssScreen({Key key, @required this.title, @required this.web})
      : super(key: key);

  final String title;
  final bool web;

  @override
  _DefRssScreenState createState() => _DefRssScreenState();
}

class _DefRssScreenState extends State<DefRssScreen> {
  List<CRssFeedItem> _feeditems = [];
  List<String> _categories = [];
  Map<String, bool> _isSelected = {};
  String _selectedCat = "All";
  bool _bookmarkUI = false;
  bool _readUI = false;
  bool _zenReader = false;

  DbHelper _dbHelper = new DbHelper();

  String cats, rssItems, rssFeeds;
  final double iconSize = 36;

  @override
  void initState() {
    if (widget.web) {
      cats = webCategories;
      rssItems = webRssItems;
      rssFeeds = webFeeds;
    } else {
      cats = podcastCategories;
      rssItems = podcastRssItems;
      rssFeeds = podcastFeeds;
    }
    getFeedItems(_selectedCat);
    getCategories();
    Utilities.getZenBool().then((value) => _zenReader = value);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool dialVisible = true;

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      child: Icon(Icons.add),
      animatedIconTheme: IconThemeData(size: 22.0),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.rss_feed, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () => showAddDialog(context, false),
          label: 'Rss Feed',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.deepOrangeAccent,
        ),
        if (widget.web)
          SpeedDialChild(
            child: Icon(Icons.rss_feed, color: Colors.white),
            backgroundColor: Colors.green,
            onTap: () => showAddDialog(context, true),
            label: 'Atom Feed',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.green,
          ),
        SpeedDialChild(
            child:
                SizedBox(width: 60, child: Image.asset("assets/opml_icon.png")),
            backgroundColor: Colors.blue,
            onTap: () {
              showDialog(context: context, builder: (context) => opmlDialog());
            },
            label: 'Opml',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.blue),
        SpeedDialChild(
          child: Icon(Icons.category),
          backgroundColor: Colors.grey,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => catDialog(),
            );
          },
          label: 'Category',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.grey,
        ),
      ],
    );
  }

  Dialog opmlDialog() {
    TextEditingController opmlUrlController = TextEditingController();
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          height: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: opmlUrlController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Opml Url',
                  ),
                ),
              ),
              RaisedButton(
                child: Text("Add"),
                onPressed: () {
                  http.get(opmlUrlController.text).then((value) {
                    Opml opml = Opml.parse(value.body);
                    parseOpml(opml);
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Or"),
              ),
              RaisedButton(
                child: Text("File"),
                onPressed: () {
                  FilePicker.platform.pickFiles().then((result) {
                    if (result != null) {
                      File file = File(result.files.single.path);
                      Opml opml = Opml.parse(file.readAsStringSync());
                      parseOpml(opml);
                    } else {}
                  });
                },
              ),
            ],
          ),
        ));
  }

  parseOpml(Opml opml) {
    List<CRssFeed> feedsNew = [];
    // feedsNew = opml.items
    //     .map<CRssFeed>((e) => CRssFeed(
    //         atom: e.type != null
    //             ? e.type.toLowerCase().compareTo("rss") == 0
    //                 ? false
    //                 : true
    //             : false,
    //         url: e.xmlUrl,
    //         title: e.title,
    //         desc: e.description))
    //     .toList();
    opml.items.forEach((element) {
      if (element.nesteditems != null && element.nesteditems.length != 0) {
        feedsNew.addAll(element.nesteditems
            .map((e) => CRssFeed(
                atom: e.type != null
                    ? e.type.toLowerCase().compareTo("rss") == 0
                        ? false
                        : true
                    : false,
                url: e.xmlUrl,
                title: e.title,
                desc: e.description))
            .toList());
      } else {
        feedsNew.add(CRssFeed(
            atom: element.type != null
                ? element.type.toLowerCase().compareTo("rss") == 0
                    ? false
                    : true
                : false,
            url: element.xmlUrl,
            title: element.title,
            desc: element.description));
      }
    });
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => OpmlAddScreen(
              feeds: feedsNew,
              web: widget.web,
            )));
  }

  @override
  Widget build(BuildContext context) {
    TextStyle greyTextStyle = new TextStyle(color: Colors.grey, fontSize: 16);
    _scaffoldContext = context;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: buildSpeedDial(),
      body: Padding(
        padding: MediaQuery.of(context).padding,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => FeedsScreen(!widget.web)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Feeds",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
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
                          size: iconSize,
                          color: Colors.black,
                        )
                      : Icon(
                          Icons.rss_feed,
                          size: iconSize,
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
                          size: iconSize,
                          color: Colors.black,
                        )
                      : Icon(
                          Icons.done_all,
                          size: iconSize,
                          color: Colors.grey,
                        ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _bookmarkUI = true;
                      _readUI = false;
                      getFeedItems(_selectedCat);
                      // getFeedItems(_selectedCat)
                      Utilities.vibrate();
                    });
                  },
                  child: _bookmarkUI
                      ? Icon(
                          Icons.bookmark,
                          size: iconSize,
                          color: Colors.black,
                        )
                      : Icon(
                          Icons.bookmark,
                          size: iconSize,
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
                                                          cats,
                                                          rssFeeds,
                                                          rssItems)
                                                      .then((value) {
                                                    setState(() {
                                                      Navigator.pop(context);
                                                      getCategories();
                                                      _isSelected[
                                                          _selectedCat] = false;
                                                      _selectedCat = "All";
                                                      _isSelected["All"] = true;
                                                      getFeedItems(
                                                          _selectedCat);
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
                          // _onRefresh();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _isSelected[_categories[index]]
                            ? Text(
                                _categories[index],
                                style: TextStyle(fontSize: 16),
                              )
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
                    padding: const EdgeInsets.all(15.0),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          readRssitemWithoutState(index);
                          if (_zenReader)
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ZenReader(_feeditems[index].url),
                            ));
                          else
                            Utilities.launchInWebViewOrVC(
                                _feeditems[index].url);
                        },
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
                                                child: _feeditems[index]
                                                        .bookmarked
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
                                                    ? Text("Unread")
                                                    : Text("Read"),
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
                                            _feeditems[index]
                                                .pubDate
                                                .toString(),
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
                        child: widget.web
                            ? Card(
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            _feeditems[index].feedTitle ?? "",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            getImageWidget(
                                                _feeditems[index].picURL),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(Utilities.trimText(
                                                  _feeditems[index].title)),
                                            ),
                                          ],
                                        ),
                                      ]),
                                ),
                              )
                            : Card(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          _feeditems[index].feedTitle ?? "",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              child: _curAudio == index
                                                  ? Icon(Icons.stop)
                                                  : Icon(
                                                      Icons.play_circle_filled),
                                              onTap: () {
                                                _curAudio == index
                                                    ? stopAudio()
                                                    : playAudio(index);
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(Utilities.trimText(
                                                _feeditems[index].title)),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  int _curAudio = -1;

  playAudio(int index) {
    if (_curAudio == -1
        // && !AudioService.playbackState.playing
        ) {
      setState(() {
        _curAudio = index;
      });
      final snackBar = SnackBar(content: Text('Audio Loading'));
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
      print(_feeditems[index].url + "   URL");
      startAudio(_feeditems[index].url);
    } else if (_curAudio > -1 || AudioService.playbackState.playing) {
      stopAudio();
      setState(() {
        _curAudio = index;
      });
      final snackBar = SnackBar(content: Text('Audio Loading'));
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
      startAudio(_feeditems[index].url);
    }
  }

  startAudio(String url) async {
    print("screeen:" + url);
    await AudioService.start(
      backgroundTaskEntrypoint: _myEntrypoint,
      androidNotificationChannelName: 'Audio Player',
      androidNotificationColor: 0xFF2196f3,
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

  readRssitem(int index) {
    _feeditems[index].read = true;
    _dbHelper.editRssFeedItem(_feeditems[index], rssItems).then((value) {
      Navigator.of(context).pop();
      getFeedItems(_selectedCat);
      // getFeedItems(_selectedCat);
    });
  }

  readRssitemWithoutState(int index) {
    _feeditems[index].read = true;
    _dbHelper.editRssFeedItem(_feeditems[index], rssItems).then((value) {
      // getFeedItems(_selectedCat);
    });
  }

  unReadRssitem(int index) {
    _feeditems[index].read = false;
    _dbHelper.editRssFeedItem(_feeditems[index], rssItems).then((value) {
      Navigator.of(context).pop();
      getFeedItems(_selectedCat);
      // getFeedItems(_selectedCat);
    });
  }

  getClearBookmarkWidget() {
    if (_readUI) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _dbHelper.clearTable(rssItems).then((value) {
                getFeedItems(_selectedCat);
                // getFeedItems(_selectedCat);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Clear",
                style: TextStyle(fontSize: 14),
              ),
            ),
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
        .editRssFeedItem(_feeditems[index], rssItems)
        .then((value) => getFeedItems(_selectedCat));
  }

  getAuthor(String author) {
    if (author != null && author.compareTo("") != 0) {
      return Padding(
          padding: EdgeInsets.all(5),
          child: Text(
            author,
            textAlign: TextAlign.center,
          ));
    } else {
      return Container();
    }
  }

  getAuthorDivider(String author) {
    if (author != null && author.compareTo("") != 0) {
      return Divider();
    } else {
      return Container();
    }
  }

  saveBookmark(int index) {
    _feeditems[index].bookmarked = true;
    _dbHelper.editRssFeedItem(_feeditems[index], rssItems).then((value) {
      Navigator.of(context).pop();
      getFeedItems(_selectedCat);
    });
  }

  getCategories() {
    _dbHelper.getCategories(cats).then((categories) {
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
    try {
      _feeditems.clear();
      if (_bookmarkUI) {
        _dbHelper.getBookmarks(cat, rssItems).then((feedItems) {
          if (cat.compareTo(_selectedCat) == 0 && _bookmarkUI)
            setState(() {
              _feeditems = feedItems;
            });
        });
      } else if (_readUI) {
        _dbHelper.getReadRssItems(cat, rssItems).then((feedItems) {
          if (cat.compareTo(_selectedCat) == 0 && _readUI)
            setState(() {
              _feeditems = feedItems;
            });
        });
      } else {
        _dbHelper.getRssFeeds(cat, rssFeeds).then((feeds) {
          if (cat.compareTo(_selectedCat) == 0 && !_readUI && !_bookmarkUI)
            feeds.forEach((feed) async {
              RssFeed rssFeed;
              AtomFeed atomFeed;
              print(feed.url);
              String FeedBody = (await http.Client().get(feed.url)).body;
              if (feed.atom)
                atomFeed = new AtomFeed.parse(FeedBody);
              else
                rssFeed = new RssFeed.parse(FeedBody);
              _dbHelper.getUnreadRssItems(cat, rssItems).then((feedItems) {
                // if (feed.lastBuildDate == null) {
                if (feed.atom) {
                  print(atomFeed.items.length);
                  // if (atomFeed.updated.compareTo(feed.lastBuildDate) != 0)
                  if (cat.compareTo(_selectedCat) == 0 &&
                      !_readUI &&
                      !_bookmarkUI)
                    atomFeed.items.forEach((feedItem) {
                      if (cat.compareTo(_selectedCat) == 0 &&
                          !_readUI &&
                          !_bookmarkUI) {
                        CRssFeedItem item = new CRssFeedItem(
                            feedTitle: atomFeed.title,
                            feedID: feed.id.toString(),
                            title: feedItem.title,
                            desc: feedItem.summary == null
                                ? ""
                                : feedItem.summary,
                            url: feedItem.links[0].href,
                            read: false,
                            picURL: "",
                            pubDate: feedItem.updated.toIso8601String(),
                            author: feedItem.authors.length == 0
                                ? ""
                                : feedItem.authors[0].name,
                            catgry: cat,
                            bookmarked: false);
                        _dbHelper.hasFeeditem(item, rssItems).then((value) {
                          if (!value) {
                            _feeditems.add(item);
                            _dbHelper.insertRssFeedtem(item, rssItems);
                          }
                        });
                      }
                    });
                } else {
                  if (cat.compareTo(_selectedCat) == 0 &&
                      !_readUI &&
                      !_bookmarkUI)
                    rssFeed.items.forEach((feedItem) {
                      if (cat.compareTo(_selectedCat) == 0 &&
                          !_readUI &&
                          !_bookmarkUI) {
                        String url = "";
                        if (feedItem.enclosure != null &&
                            feedItem.enclosure.type.compareTo("image/jpg") == 0)
                          url = feedItem.enclosure.url;
                        String feedUrl;
                        if (widget.web) {
                          feedUrl = feedItem.link;
                        } else {
                          feedUrl = feedItem.enclosure.url;
                        }

                        CRssFeedItem item = new CRssFeedItem(
                            feedTitle: rssFeed.title,
                            feedID: feed.id.toString(),
                            title: feedItem.title,
                            desc: feedItem.description,
                            url: feedUrl,
                            read: false,
                            picURL: url,
                            pubDate: feedItem.pubDate.toIso8601String(),
                            author: feedItem.author,
                            catgry: cat,
                            bookmarked: false);
                        _dbHelper.hasFeeditem(item, rssItems).then((value) {
                          if (!value) {
                            _feeditems.add(item);
                            _dbHelper.insertRssFeedtem(item, rssItems);
                          }
                        });
                      }
                    });
                }
                // }
                setState(() {
                  if (cat.compareTo(_selectedCat) == 0 &&
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

  Dialog catDialog() {
    final catTextController = TextEditingController();
    return Dialog(
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
                      .insertCategory(catTextController.text, cats)
                      .then((value) {
                    setState(() {
                      _categories.add(catTextController.text);
                      _isSelected[_selectedCat] = false;
                      _selectedCat = catTextController.text;
                      _isSelected[_selectedCat] = true;
                      getFeedItems(_selectedCat);
                      // getFeedItems(_selectedCat);
                    });
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
  }

  showAddDialog(BuildContext contex, bool atom) {
    final rssTextController = TextEditingController();

    String catgry;

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
                            border: InputBorder.none, hintText: 'Feed Link'),
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
                          // GestureDetector(
                          //   onTap: () {
                          //     showDialog(
                          //         context: context,
                          //         builder: (BuildContext context) {
                          //           return catDialog();
                          //         });
                          //   },
                          //   child: Icon(Icons.add),
                          // ),
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
                              if (catgry.compareTo("") == 0) catgry = "All";
                              final response =
                                  await http.Client().get(Uri.parse(rssURL));
                              CRssFeed rss;
                              if (atom) {
                                print("insideA Atom");
                                AtomFeed atomFeed =
                                    new AtomFeed.parse(response.body);
                                String url = "";
                                if (atomFeed.logo != null) url = atomFeed.logo;
                                rss = new CRssFeed(
                                    title: atomFeed.title,
                                    desc: atomFeed.subtitle == null
                                        ? ""
                                        : atomFeed.subtitle,
                                    picURL: url,
                                    catgry: catgry,
                                    url: rssURL,
                                    author: atomFeed.authors.length == 0
                                        ? ""
                                        : atomFeed.authors[0].name,
                                    lastBuildDate:
                                        atomFeed.updated?.toIso8601String(),
                                    atom: atom);
                              } else {
                                var rssFeed = new RssFeed.parse(response.body);
                                String url = "";
                                if (rssFeed.image != null)
                                  url = rssFeed.image.url;
                                rss = new CRssFeed(
                                    title: rssFeed.title,
                                    desc: rssFeed.description,
                                    picURL: url,
                                    catgry: catgry,
                                    url: rssURL,
                                    author: rssFeed.author,
                                    lastBuildDate: rssFeed.lastBuildDate,
                                    atom: atom);
                              }

                              _dbHelper
                                  .insertRssFeed(rss, rssFeeds)
                                  .then((value) {
                                setState(() {
                                  _isSelected[_selectedCat] = false;
                                  _selectedCat = catgry;
                                  _isSelected[_selectedCat] = true;
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
                              print(e.toString());
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

  // openLink(String url) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(
  //           builder: (context, setState) {
  //             bool _zenReader;
  //             Utilities.getZenBool().then((value) => setState(() {
  //                   _zenReader = value;
  //                 }));
  //             return Dialog(
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(20.0)),
  //               child: Container(),
  //             );
  //           },
  //         );
  //       });
  // }
}

void _myEntrypoint() => AudioServiceBackground.run(() => AudioTasks());
