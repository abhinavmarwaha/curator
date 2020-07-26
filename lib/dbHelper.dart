import 'package:curator/Models/CRssFeedItem.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Models/CRssFeed.dart';

class DbHelper {
  static final DbHelper _instance = new DbHelper.internal();

  factory DbHelper() => _instance;

  static Database _db;

  openDB() async {
    var database = openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE webBookmarks(id INTEGER PRIMARY KEY, title TEXT, desc TEXT, read INTEGER, catgry TEXT, picURL TEXT, url TEXT, pubDate TEXT, author TEXT);");
        db.execute(
            "CREATE TABLE webRssItems(id INTEGER PRIMARY KEY, title TEXT, desc TEXT, read INTEGER, catgry TEXT, picURL TEXT, url TEXT, pubDate TEXT, author TEXT);");
        db.execute(
            "CREATE TABLE podcastRssItems(id INTEGER PRIMARY KEY, title TEXT, desc TEXT, read INTEGER, catgry TEXT, picURL TEXT, url TEXT, pubDate TEXT, author TEXT);");
        db.execute(
            "CREATE TABLE podcastBookmarks(id INTEGER PRIMARY KEY, title TEXT, desc TEXT, read INTEGER, catgry TEXT, picURL TEXT, url TEXT, pubDate TEXT, author TEXT);");
        db.execute(
            "CREATE TABLE podcastCategories(id INTEGER PRIMARY KEY, name TEXT)");
        db.execute(
            "CREATE TABLE webCategories(id INTEGER PRIMARY KEY, name TEXT); ");
        db.execute(
            "CREATE TABLE podcastFeeds(id INTEGER PRIMARY KEY, title TEXT, desc TEXT, catgry TEXT, picURL TEXT, url TEXT, generatedDate TEXT);");
        db.insert(
          'webCategories',
          {'name': "All"},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        db.insert(
          'podcastCategories',
          {'name': "All"},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return db.execute(
            "CREATE TABLE webFeeds(id INTEGER PRIMARY KEY, title TEXT, desc TEXT, catgry TEXT, picURL TEXT, url TEXT, generatedDate TEXT);");
      },
      version: 1,
    );
    return database;
  }

  DbHelper.internal();

  Future<Database> get getdb async {
    if (_db != null) {
      return _db;
    }
    _db = await openDB();

    return _db;
  }

  Future<void> insertCategory(String cat, String dbName) async {
    final Database db = await getdb;

    await db.insert(
      dbName,
      {'name': cat},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertRssFeed(CRssFeed feed, String dbName) async {
    final Database db = await getdb;

    await db.insert(
      dbName,
      feed.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertRssFeedtem(CRssFeedItem item, String dbName) async {
    final Database db = await getdb;

    await db.insert(
      dbName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> hasFeeditem(CRssFeedItem item, String dbName) async {
    final Database db = await getdb;
    return (await db.query(dbName,
                where: "title = ? && author = ?",
                whereArgs: [item.title, item.author]))
            .length !=
        0;
  }

  Future<List<CRssFeed>> getRssFeeds(String cat, String dbName) async {
    final Database db = await getdb;
    List<Map<String, dynamic>> maps;
    if (cat.compareTo("All") == 0)
      maps = await db.query(dbName);
    else
      maps = await db.query(dbName, where: "catgry = ?", whereArgs: [cat]);
    return List.generate(maps.length, (i) {
      print(maps[i]['title']);
      return CRssFeed(
        id: maps[i]['id'],
        title: maps[i]['title'],
        desc: maps[i]['desc'],
        catgry: maps[i]['catgry'],
        picURL: maps[i]['picURL'],
        url: maps[i]['url'],
        lastBuildDate: maps[i]['lastBuildDate'],
      );
    });
  }

  Future<List<CRssFeedItem>> getBookmarks(String cat, String dbName) async {
    final Database db = await getdb;
    List<Map<String, dynamic>> maps;
    if (cat.compareTo("All") == 0)
      maps = await db.query(dbName);
    else
      maps = await db.query(dbName, where: "catgry = ?", whereArgs: [cat]);
    return List.generate(maps.length, (i) {
      print(maps[i]['title']);
      return CRssFeedItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        desc: maps[i]['desc'],
        read: maps[i]['read'] == 1,
        catgry: maps[i]['catgry'],
        picURL: maps[i]['picURL'],
        url: maps[i]['url'],
        pubDate: maps[i]['pubDate'],
        author: maps[i]['author'],
        feedID: maps[i]['feedID'],
      );
    });
  }

  Future<List<CRssFeedItem>> getReadRssItems(String cat, String dbName) async {
    final Database db = await getdb;
    List<Map<String, dynamic>> maps;
    if (cat.compareTo("All") == 0)
      maps = await db.query(dbName);
    else
      maps = await db
          .query(dbName, where: "catgry = ? && read == ?", whereArgs: [cat, 1]);
    return List.generate(maps.length, (i) {
      print(maps[i]['title']);
      return CRssFeedItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        desc: maps[i]['desc'],
        read: maps[i]['read'] == 1,
        catgry: maps[i]['catgry'],
        picURL: maps[i]['picURL'],
        url: maps[i]['url'],
        pubDate: maps[i]['pubDate'],
        author: maps[i]['author'],
        feedID: maps[i]['feedID'],
      );
    });
  }

  Future<List<CRssFeedItem>> getUnreadRssItems(
      String cat, String dbName) async {
    final Database db = await getdb;
    List<Map<String, dynamic>> maps;
    if (cat.compareTo("All") == 0)
      maps = await db.query(dbName);
    else
      maps = await db
          .query(dbName, where: "catgry = ? && read == ?", whereArgs: [cat, 0]);
    return List.generate(maps.length, (i) {
      print(maps[i]['title']);
      return CRssFeedItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        desc: maps[i]['desc'],
        read: maps[i]['read'] == 1,
        catgry: maps[i]['catgry'],
        picURL: maps[i]['picURL'],
        url: maps[i]['url'],
        pubDate: maps[i]['pubDate'],
        author: maps[i]['author'],
        feedID: maps[i]['feedID'],
      );
    });
  }

  Future<List<String>> getCategories(String dbName) async {
    final Database db = await getdb;

    final List<Map<String, dynamic>> maps = await db.query(dbName);
    return List.generate(maps.length, (i) {
      return maps[i]['name'];
    });
  }

  Future<void> deleteRssFeed(int id) async {
    final db = await getdb;

    await db.delete(
      'web',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> editRssFeed(CRssFeed feed, String dbName) async {
    final db = await getdb;

    await db.update(
      dbName,
      feed.toMap(),
      where: "id = ?",
      whereArgs: [feed.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> editRssFeedItem(CRssFeedItem feedItem, String dbName) async {
    final db = await getdb;

    await db.update(
      dbName,
      feedItem.toMap(),
      where: "id = ?",
      whereArgs: [feedItem.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future close() async {
    var dbClient = await getdb;
    return dbClient.close();
  }
}
