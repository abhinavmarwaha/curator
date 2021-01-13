// import 'package:curator/Models/CRssFeedItem.dart';
// import 'package:curator/Screens/ZenReader.dart';
// import 'package:curator/Utilities/utilities.dart';
// import 'package:curator/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:curator/Models/CRssFeed.dart';
// import 'package:curator/dbHelper.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// // import 'package:pull_to_refresh/pull_to_refresh.dart';
// import './feedsScreen.dart';

// import 'package:webfeed/webfeed.dart';
// import 'package:http/http.dart' as http;

// BuildContext _scaffoldContext;

// class WebRssScreen extends StatefulWidget {
//   WebRssScreen({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _WebRssScreenState createState() => _WebRssScreenState();
// }

// class _WebRssScreenState extends State<WebRssScreen> {
//   List<CRssFeedItem> _feeditems = [];
//   List<String> _categories = [];
//   Map<String, bool> _isSelected = {};
//   String _selectedCat = "All";
//   bool _bookmarkUI = false;
//   bool _readUI = false;
//   bool _zenReader = false;

//   DbHelper _dbHelper = new DbHelper();

//   @override
//   void initState() {
//     getFeedItems(_selectedCat);
//     getCategories();
//     Utilities.getZenBool().then((value) => _zenReader = value);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   bool dialVisible = true;

//   void setDialVisible(bool value) {
//     setState(() {
//       dialVisible = value;
//     });
//   }

//   SpeedDial buildSpeedDial() {
//     return SpeedDial(
//       child: Icon(Icons.add),
//       animatedIconTheme: IconThemeData(size: 22.0),
//       onOpen: () => print('OPENING DIAL'),
//       onClose: () => print('DIAL CLOSED'),
//       visible: dialVisible,
//       curve: Curves.bounceIn,
//       children: [
//         SpeedDialChild(
//           child: Icon(Icons.rss_feed, color: Colors.white),
//           backgroundColor: Colors.deepOrange,
//           onTap: () => showAddDialog(context, false),
//           label: 'Rss Feed',
//           labelStyle: TextStyle(fontWeight: FontWeight.w500),
//           labelBackgroundColor: Colors.deepOrangeAccent,
//         ),
//         SpeedDialChild(
//           child: Icon(Icons.rss_feed, color: Colors.white),
//           backgroundColor: Colors.green,
//           onTap: () => showAddDialog(context, true),
//           label: 'Atom Feed',
//           labelStyle: TextStyle(fontWeight: FontWeight.w500),
//           labelBackgroundColor: Colors.green,
//         ),
//         SpeedDialChild(
//           child:
//               SizedBox(width: 60, child: Image.asset("assets/opml_icon.png")),
//           backgroundColor: Colors.green,
//           onTap: () => showAddDialog(context, true),
//           label: 'Opml',
//           labelStyle: TextStyle(fontWeight: FontWeight.w500),
//           labelBackgroundColor: Colors.green,
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     TextStyle greyTextStyle = new TextStyle(color: Colors.grey);
//     _scaffoldContext = context;

//     return Scaffold(
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       floatingActionButton: buildSpeedDial(),
//       body: Column(
//         children: <Widget>[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: <Widget>[
//               GestureDetector(
//                 onTap: () {
//                   Navigator.of(context).push(new MaterialPageRoute(
//                       builder: (context) => FeedsScreen(false)));
//                 },
//                 child: Text("Feeds"),
//               ),
//               Spacer(),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _readUI = false;
//                     _bookmarkUI = false;
//                     getFeedItems(_selectedCat);
//                     // getFeedItems(_selectedCat);
//                     Utilities.vibrate();
//                   });
//                 },
//                 child: !_bookmarkUI && !_readUI
//                     ? Icon(
//                         Icons.rss_feed,
//                         color: Colors.black,
//                       )
//                     : Icon(
//                         Icons.rss_feed,
//                         color: Colors.grey,
//                       ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _readUI = true;
//                     _bookmarkUI = false;
//                     getFeedItems(_selectedCat);
//                     // getFeedItems(_selectedCat);
//                     Utilities.vibrate();
//                   });
//                 },
//                 child: _readUI
//                     ? Icon(
//                         Icons.done_all,
//                         color: Colors.black,
//                       )
//                     : Icon(
//                         Icons.done_all,
//                         color: Colors.grey,
//                       ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _bookmarkUI = true;
//                     _readUI = false;
//                     getFeedItems(_selectedCat);
//                     // getFeedItems(_selectedCat)
//                     Utilities.vibrate();
//                   });
//                 },
//                 child: _bookmarkUI
//                     ? Icon(
//                         Icons.bookmark,
//                         color: Colors.black,
//                       )
//                     : Icon(
//                         Icons.bookmark,
//                         color: Colors.grey,
//                       ),
//               ),
//             ],
//           ),
//           getClearBookmarkWidget(),
//           Container(
//             height: 25,
//             child: ListView.builder(
//               itemCount: _categories.length,
//               padding: const EdgeInsets.all(2.0),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                     onLongPress: () {
//                       if (_categories[index].compareTo("All") != 0)
//                         showDialog(
//                             builder: (context) => Dialog(
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius:
//                                           BorderRadius.circular(20.0)),
//                                   child: Container(
//                                     height: 120,
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: <Widget>[
//                                         Text("Delete " +
//                                             _categories[index] +
//                                             "?"),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.center,
//                                           children: <Widget>[
//                                             RaisedButton(
//                                               onPressed: () {
//                                                 _dbHelper
//                                                     .deleteCat(
//                                                         _categories[index],
//                                                         webCategories,
//                                                         webFeeds,
//                                                         webRssItems)
//                                                     .then((value) {
//                                                   setState(() {
//                                                     Navigator.pop(context);
//                                                     getCategories();
//                                                     _isSelected[_selectedCat] =
//                                                         false;
//                                                     _selectedCat = "All";
//                                                     _isSelected["All"] = true;
//                                                     getFeedItems(_selectedCat);
//                                                   });
//                                                 });
//                                               },
//                                               child: Text("Yes"),
//                                             ),
//                                             RaisedButton(
//                                               child: Text("No"),
//                                               onPressed: () {
//                                                 Navigator.of(context).pop();
//                                               },
//                                             )
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                             context: context);
//                     },
//                     onTap: () {
//                       Utilities.vibrate();
//                       setState(() {
//                         _isSelected[_selectedCat] = false;
//                         _selectedCat = _categories[index];
//                         _isSelected[_selectedCat] = true;
//                         //  getFeedItems(_selectedCat);
//                         getFeedItems(_selectedCat);
//                         // _onRefresh();
//                       });
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(1.0),
//                       child: _isSelected[_categories[index]]
//                           ? Text(_categories[index])
//                           : Text(
//                               _categories[index],
//                               style: greyTextStyle,
//                             ),
//                     ));
//               },
//               scrollDirection: Axis.horizontal,
//             ),
//           ),
//           Flexible(
//             child: Padding(
//               padding: EdgeInsets.all(8),
//               child: ListView.builder(
//                   itemCount: _feeditems.length,
//                   padding: const EdgeInsets.all(15.0),
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () {
//                         readRssitemWithoutState(index);
//                         if (_zenReader)
//                           Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) =>
//                                 ZenReader(_feeditems[index].url),
//                           ));
//                         else
//                           Utilities.launchInWebViewOrVC(_feeditems[index].url);
//                       },
//                       onLongPress: () {
//                         showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return Dialog(
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20.0)),
//                                 child: SingleChildScrollView(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: <Widget>[
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: <Widget>[
//                                           Padding(
//                                             padding: EdgeInsets.all(5),
//                                             child: RaisedButton(
//                                               onPressed: () {
//                                                 _feeditems[index].bookmarked
//                                                     ? deleteBookmark(index)
//                                                     : saveBookmark(index);
//                                               },
//                                               child:
//                                                   _feeditems[index].bookmarked
//                                                       ? Text("Delete Bookmark")
//                                                       : Text("Save"),
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: EdgeInsets.all(5),
//                                             child: RaisedButton(
//                                               onPressed: () {
//                                                 _feeditems[index].read
//                                                     ? unReadRssitem(index)
//                                                     : readRssitem(index);
//                                               },
//                                               child: _feeditems[index].read
//                                                   ? Text("Unread")
//                                                   : Text("Read"),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Padding(
//                                           padding: EdgeInsets.all(5),
//                                           child: Container(
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 0.65,
//                                             child: Text(
//                                               _feeditems[index].title,
//                                               textAlign: TextAlign.center,
//                                               overflow: TextOverflow.visible,
//                                             ),
//                                           )),
//                                       Divider(),
//                                       Padding(
//                                         padding: EdgeInsets.all(5),
//                                         child: Text(
//                                           _feeditems[index].pubDate.toString(),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       Divider(),
//                                       getAuthor(_feeditems[index].author),
//                                       getAuthorDivider(
//                                           _feeditems[index].author),
//                                       Padding(
//                                           padding: EdgeInsets.all(5),
//                                           child: Html(
//                                               data: _feeditems[index].desc))
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             });
//                       },
//                       child: Card(
//                         elevation: 1,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: <Widget>[
//                               getImageWidget(_feeditems[index].picURL),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(Utilities.trimText(
//                                     _feeditems[index].title)),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   readRssitem(int index) {
//     _feeditems[index].read = true;
//     _dbHelper.editRssFeedItem(_feeditems[index], webRssItems).then((value) {
//       Navigator.of(context).pop();
//       getFeedItems(_selectedCat);
//       // getFeedItems(_selectedCat);
//     });
//   }

//   readRssitemWithoutState(int index) {
//     _feeditems[index].read = true;
//     _dbHelper.editRssFeedItem(_feeditems[index], webRssItems).then((value) {
//       // getFeedItems(_selectedCat);
//     });
//   }

//   unReadRssitem(int index) {
//     _feeditems[index].read = false;
//     _dbHelper.editRssFeedItem(_feeditems[index], webRssItems).then((value) {
//       Navigator.of(context).pop();
//       getFeedItems(_selectedCat);
//       // getFeedItems(_selectedCat);
//     });
//   }

//   getClearBookmarkWidget() {
//     if (_readUI) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: <Widget>[
//           GestureDetector(
//             onTap: () {
//               _dbHelper.clearTable(webRssItems).then((value) {
//                 getFeedItems(_selectedCat);
//                 // getFeedItems(_selectedCat);
//               });
//             },
//             child: Text("Clear"),
//           )
//         ],
//       );
//     } else {
//       return Container();
//     }
//   }

//   deleteBookmark(int index) {
//     _feeditems[index].bookmarked = false;

//     _dbHelper
//         .editRssFeedItem(_feeditems[index], webRssItems)
//         .then((value) => getFeedItems(_selectedCat));
//   }

//   getAuthor(String author) {
//     if (author != null && author.compareTo("") != 0) {
//       return Padding(
//           padding: EdgeInsets.all(5),
//           child: Text(
//             author,
//             textAlign: TextAlign.center,
//           ));
//     } else {
//       return Container();
//     }
//   }

//   getAuthorDivider(String author) {
//     if (author != null && author.compareTo("") != 0) {
//       return Divider();
//     } else {
//       return Container();
//     }
//   }

//   saveBookmark(int index) {
//     _feeditems[index].bookmarked = true;
//     _dbHelper.editRssFeedItem(_feeditems[index], webRssItems).then((value) {
//       Navigator.of(context).pop();
//       getFeedItems(_selectedCat);
//     });
//   }

//   getCategories() {
//     _dbHelper.getCategories(webCategories).then((categories) {
//       setState(() {
//         _categories = categories;
//         _categories.forEach((cat) {
//           if (cat.compareTo("All") == 0)
//             _isSelected['All'] = true;
//           else {
//             _isSelected[cat] = false;
//           }
//         });
//       });
//     });
//   }

//   getFeedItems(String cat) {
//     try {
//       _feeditems.clear();
//       if (_bookmarkUI) {
//         _dbHelper.getBookmarks(cat, webRssItems).then((feedItems) {
//           if (cat.compareTo(_selectedCat) == 0 && _bookmarkUI)
//             setState(() {
//               _feeditems = feedItems;
//             });
//         });
//       } else if (_readUI) {
//         _dbHelper.getReadRssItems(cat, webRssItems).then((feedItems) {
//           if (cat.compareTo(_selectedCat) == 0 && _readUI)
//             setState(() {
//               _feeditems = feedItems;
//             });
//         });
//       } else {
//         _dbHelper.getRssFeeds(cat, webFeeds).then((feeds) {
//           if (cat.compareTo(_selectedCat) == 0 && !_readUI && !_bookmarkUI)
//             feeds.forEach((feed) async {
//               RssFeed rssFeed;
//               AtomFeed atomFeed;
//               print(feed.url);
//               String FeedBody = (await http.Client().get(feed.url)).body;
//               if (feed.atom)
//                 atomFeed = new AtomFeed.parse(FeedBody);
//               else
//                 rssFeed = new RssFeed.parse(FeedBody);
//               _dbHelper.getUnreadRssItems(cat, webRssItems).then((feedItems) {
//                 // if (feed.lastBuildDate == null) {
//                 if (feed.atom) {
//                   print(atomFeed.items.length);
//                   // if (atomFeed.updated.compareTo(feed.lastBuildDate) != 0)
//                   if (cat.compareTo(_selectedCat) == 0 &&
//                       !_readUI &&
//                       !_bookmarkUI)
//                     atomFeed.items.forEach((feedItem) {
//                       if (cat.compareTo(_selectedCat) == 0 &&
//                           !_readUI &&
//                           !_bookmarkUI) {
//                         CRssFeedItem item = new CRssFeedItem(
//                             feedID: feed.id.toString(),
//                             title: feedItem.title,
//                             desc: feedItem.summary == null
//                                 ? ""
//                                 : feedItem.summary,
//                             url: feedItem.links[0].href,
//                             read: false,
//                             picURL: "",
//                             pubDate: feedItem.updated,
//                             author: feedItem.authors.length == 0
//                                 ? ""
//                                 : feedItem.authors[0].name,
//                             catgry: cat,
//                             bookmarked: false);
//                         _dbHelper.hasFeeditem(item, webRssItems).then((value) {
//                           if (!value) {
//                             _feeditems.add(item);
//                             _dbHelper.insertRssFeedtem(item, webRssItems);
//                           }
//                         });
//                       }
//                     });
//                 } else {
//                   if (cat.compareTo(_selectedCat) == 0 &&
//                       !_readUI &&
//                       !_bookmarkUI)
//                     rssFeed.items.forEach((feedItem) {
//                       if (cat.compareTo(_selectedCat) == 0 &&
//                           !_readUI &&
//                           !_bookmarkUI) {
//                         String url = "";
//                         if (feedItem.enclosure != null &&
//                             feedItem.enclosure.type.compareTo("image/jpg") == 0)
//                           url = feedItem.enclosure.url;
//                         CRssFeedItem item = new CRssFeedItem(
//                             feedID: feed.id.toString(),
//                             title: feedItem.title,
//                             desc: feedItem.description,
//                             url: feedItem.link,
//                             read: false,
//                             picURL: url,
//                             pubDate: feedItem.pubDate,
//                             author: feedItem.author,
//                             catgry: cat,
//                             bookmarked: false);
//                         _dbHelper.hasFeeditem(item, webRssItems).then((value) {
//                           if (!value) {
//                             _feeditems.add(item);
//                             _dbHelper.insertRssFeedtem(item, webRssItems);
//                           }
//                         });
//                       }
//                     });
//                 }
//                 // }
//                 setState(() {
//                   if (cat.compareTo(_selectedCat) == 0 &&
//                       !_readUI &&
//                       !_bookmarkUI) _feeditems += feedItems;
//                 });
//               });
//             });
//         });
//       }
//     } catch (e) {
//       final snackBar = SnackBar(content: Text('Some Error has occured'));
//       Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
//       print(e.toString());
//     }
//   }

//   getImageWidget(String url) {
//     if (url == null || url.compareTo("") == 0)
//       return Container();
//     else {
//       return Image.network(url);
//     }
//   }

//   showAddDialog(BuildContext contex, bool atom) {
//     final rssTextController = TextEditingController();
//     final catTextController = TextEditingController();
//     String catgry;
//     Dialog catDialog = Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       child: Container(
//         height: 120,
//         child: Padding(
//           padding: EdgeInsets.all(12.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               TextField(
//                 controller: catTextController,
//                 decoration: InputDecoration(
//                     border: InputBorder.none, hintText: 'Category'),
//               ),
//               RaisedButton(
//                 onPressed: () {
//                   _dbHelper
//                       .insertCategory(catTextController.text, webCategories)
//                       .then((value) {
//                     setState(() {
//                       _categories.add(catTextController.text);
//                       _isSelected[_selectedCat] = false;
//                       _selectedCat = catTextController.text;
//                       _isSelected[_selectedCat] = true;
//                       getFeedItems(_selectedCat);
//                       // getFeedItems(_selectedCat);
//                     });
//                     Navigator.of(context).pop();
//                     Navigator.of(context).pop();
//                   });
//                 },
//                 child: Text("Add"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20.0)),
//               child: Container(
//                 height: 160,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextField(
//                         controller: rssTextController,
//                         decoration: InputDecoration(
//                             border: InputBorder.none, hintText: 'Feed Link'),
//                       ),
//                       Row(
//                         children: <Widget>[
//                           DropdownButton<String>(
//                             value: catgry,
//                             onChanged: (value) {
//                               setState(() {
//                                 catgry = value;
//                               });
//                             },
//                             hint: Text("category"),
//                             items: _categories.map((String value) {
//                               return new DropdownMenuItem<String>(
//                                 value: value,
//                                 child: new Text(value),
//                               );
//                             }).toList(),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return catDialog;
//                                   });
//                             },
//                             child: Icon(Icons.add),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         width: 320.0,
//                         height: 40,
//                         child: RaisedButton(
//                           onPressed: () async {
//                             final snackBar = SnackBar(content: Text('Loading'));
//                             Scaffold.of(_scaffoldContext)
//                                 .showSnackBar(snackBar);
//                             try {
//                               String rssURL = rssTextController.text;
//                               if (catgry.compareTo("") == 0) catgry = "All";
//                               final response =
//                                   await http.Client().get(Uri.parse(rssURL));
//                               CRssFeed rss;
//                               if (atom) {
//                                 print("insideA Atom");
//                                 AtomFeed atomFeed =
//                                     new AtomFeed.parse(response.body);
//                                 String url = "";
//                                 if (atomFeed.logo != null) url = atomFeed.logo;
//                                 rss = new CRssFeed(
//                                     title: atomFeed.title,
//                                     desc: atomFeed.subtitle == null
//                                         ? ""
//                                         : atomFeed.subtitle,
//                                     picURL: url,
//                                     catgry: catgry,
//                                     url: rssURL,
//                                     author: atomFeed.authors.length == 0
//                                         ? ""
//                                         : atomFeed.authors[0].name,
//                                     lastBuildDate: atomFeed.updated,
//                                     atom: atom);
//                               } else {
//                                 var rssFeed = new RssFeed.parse(response.body);
//                                 String url = "";
//                                 if (rssFeed.image != null)
//                                   url = rssFeed.image.url;
//                                 rss = new CRssFeed(
//                                     title: rssFeed.title,
//                                     desc: rssFeed.description,
//                                     picURL: url,
//                                     catgry: catgry,
//                                     url: rssURL,
//                                     author: rssFeed.author,
//                                     lastBuildDate:
//                                         DateTime.parse(rssFeed.lastBuildDate),
//                                     atom: atom);
//                               }

//                               _dbHelper
//                                   .insertRssFeed(rss, webFeeds)
//                                   .then((value) {
//                                 setState(() {
//                                   _isSelected[_selectedCat] = false;
//                                   _selectedCat = catgry;
//                                   _isSelected[_selectedCat] = true;
//                                   getFeedItems(_selectedCat);
//                                   // getFeedItems(_selectedCat);
//                                 });
//                                 Navigator.of(context).pop();
//                               });
//                             } catch (e) {
//                               Navigator.of(context).pop();
//                               final snackBar =
//                                   SnackBar(content: Text('Invalid Feed'));
//                               Scaffold.of(_scaffoldContext)
//                                   .showSnackBar(snackBar);
//                               print(e.toString());
//                             }
//                           },
//                           child: Text(
//                             "Save",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           color: const Color(0xFF1BC0C5),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // openLink(String url) {
//   //   showDialog(
//   //       context: context,
//   //       builder: (BuildContext context) {
//   //         return StatefulBuilder(
//   //           builder: (context, setState) {
//   //             bool _zenReader;
//   //             Utilities.getZenBool().then((value) => setState(() {
//   //                   _zenReader = value;
//   //                 }));
//   //             return Dialog(
//   //               shape: RoundedRectangleBorder(
//   //                   borderRadius: BorderRadius.circular(20.0)),
//   //               child: Container(),
//   //             );
//   //           },
//   //         );
//   //       });
//   // }
// }
