class CRssFeed {
  final int id;
  final String title;
  final String desc;
  String catgry;
  final String picURL;
  final String url;
  final String lastBuildDate;
  final String author;
  final bool atom;

  CRssFeed(
      {this.id,
      this.title,
      this.desc,
      this.catgry,
      this.picURL,
      this.url,
      this.lastBuildDate,
      this.author,
      this.atom});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'catgry': catgry,
      'picURL': picURL,
      'url': url,
      'lastBuildDate': lastBuildDate,
      'author': author,
      'atom': atom ? 1 : 0
    };
  }
}
