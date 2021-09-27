import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseEager {
  DatabaseEager._();

  static final DatabaseEager db = DatabaseEager._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), "Week.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (db, version) {
      return db.execute("CREATE TABLE IF NOT EXISTS week ("
          "day TEXT PRIMARY KEY,"
          "weekday TEXT,"
          "title TEXT,"
          "note TEXT)");
    });
  }
}
