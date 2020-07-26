class CRssFeedItem {
  final int id;
  final String title;
  final String desc;
  final String picURL;
  final String url;
  final String catgry;
  final String pubDate;
  final String author;
  final int feedID;
  final String mediaURL;

  bool read;

  CRssFeedItem(
      {this.id,
      this.title,
      this.desc,
      this.read,
      this.catgry,
      this.picURL,
      this.mediaURL,
      this.url,
      this.pubDate,
      this.author,
      this.feedID});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'read': read ? 1 : 0,
      'catgry': catgry,
      'picURL': picURL,
      'url': url,
      'pubDate': pubDate,
      'author': author,
      'feedID': feedID,
      'mediaURL': mediaURL
    };
  }
}
