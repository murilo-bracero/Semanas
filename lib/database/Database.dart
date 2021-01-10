import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'NoteModel.dart';

class DBProvider {
  //singleton
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Week.dp");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE week ("
          "day TEXT PRIMARY KEY,"
          "weekday TEXT,"
          "title TEXT,"
          "note TEXT)");
    });
  }

  createWeek(var days, var weekdays) async {
    final db = await database;
    String query =
        "INSERT INTO week(day, weekday) VALUES ('${days[0]}','${weekdays[0]}'),('${days[1]}','${weekdays[1]}'),"
        "('${days[2]}','${weekdays[2]}'),('${days[3]}','${weekdays[3]}'),('${days[4]}','${weekdays[4]}'),('${days[5]}','${weekdays[5]}'),"
        "('${days[6]}','${weekdays[6]}'),('${days[7]}','${weekdays[7]}')";
    var res = await db.rawInsert(query);
    return res;
  }

  Future<void> addNote(String day, String title, String note) async {
    final db = await database;
    String query =
        "UPDATE week SET note = '$note', title='$title' WHERE day = '$day'";
    await db.rawUpdate(query);
  }

  deleteWeek() async {
    final db = await database;
    String query = "DELETE FROM week";
    var res = await db.rawDelete(query);
    return res;
  }

  deleteDay(String day) async {
    final db = await database;
    String query = "DELETE FROM week WHERE day = '$day'";
    var res = await db.rawDelete(query);
    return res;
  }

  Future<List<Notes>> getWeek() async {
    final db = await database;
    var res = await db.query("week");
    List<Notes> notes =
        res.isNotEmpty ? res.map((c) => Notes.fromJson(c)).toList() : [];

    return notes;
  }

  Future<Notes> getLast() async {
    final db = await database;
    String query = "SELECT * FROM week ORDER BY day DESC LIMIT 1";
    var res = await db.rawQuery(query);
    return res.isNotEmpty ? Notes.fromJson(res.first) : null;
  }

  Future<List<String>> getDays() async {
    final db = await database;
    String query = "SELECT day FROM week";
    var res = await db.rawQuery(query);
    List<String> days =
        res.isNotEmpty ? res.map((c) => Notes.fromJson(c).day).toList() : [];
    return days;
  }
}
