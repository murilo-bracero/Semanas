import 'package:semanas/database/database_eager.dart';
import 'package:semanas/model/note.dart';
import 'package:sqflite/sqflite.dart';

class WeekService {
  static createWeek() async {
    final db = await DatabaseEager.db.database;

    DateTime dateNow = new DateTime.now();

    for (int i = 0; i <= 7; i++) {
      var contextDay = dateNow.add(Duration(days: i));
      db.insert('week', Note(contextDay, '', '').toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> addNote(String day, String title, String note) async {
    final db = await DatabaseEager.db.database;
    String query =
        "UPDATE week SET note = '$note', title='$title' WHERE day = '$day'";
    await db.rawUpdate(query);
  }

  static deleteWeek() async {
    final db = await DatabaseEager.db.database;
    return db.delete('week');
  }

  static _deleteDay(String day) async {
    final db = await DatabaseEager.db.database;
    String query = "DELETE FROM week WHERE day = '$day'";
    var res = await db.rawDelete(query);
    return res;
  }

  static Future<List<Note>> getWeek() async {
    final db = await DatabaseEager.db.database;
    var res = await db.query("week");

    return res.map((c) => Note.fromJson(c)).toList();
  }

  static Future<Note> _getLast() async {
    final db = await DatabaseEager.db.database;
    String query = "SELECT * FROM week ORDER BY day DESC LIMIT 1";
    var res = await db.rawQuery(query);
    return res.isNotEmpty ? Note.fromJson(res.first) : null;
  }

  static Future<List<String>> _getDays() async {
    final db = await DatabaseEager.db.database;
    String query = "SELECT day FROM week";
    var res = await db.rawQuery(query);

    if (res.isNotEmpty) {
      res.map((e) => Note.fromJson(e).day.toIso8601String());
    }

    return [];
  }

  static Future<bool> hasWeekEnded() async {
    DateTime today = DateTime.now();
    var lastNote = await _getLast();

    if (lastNote != null) {
      if (today.difference(lastNote.day).inDays >= 1) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static deletePastDay() async {
    DateTime post = DateTime.now();
    var days = await _getDays();
    if (days != null) {
      for (String day in days) {
        if (post.difference(DateTime.parse(day)).inDays >= 1) {
          _deleteDay(day);
        }
      }
    }
  }
}
