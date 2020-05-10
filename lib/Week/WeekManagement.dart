import 'package:semanas/database/Database.dart';

class WeekUtils {
  var week = [];
  var weekdays = [];

  buildWeek() {
    DateTime dateNow = new DateTime.now();

    for (int i = 0; i <= 7; i++) {
      var contextDay = dateNow.add(new Duration(days: i));
      week.add(contextDay.toString().split(' ')[0]);
      weekdays.add(_parseIntDate(contextDay.weekday));
    }

    _saveWeek();
  }

  _parseIntDate(weekInt) {
    var weekdays = [
      "segunda-feira",
      "terça-feira",
      "quarta-feira",
      "quinta-feira",
      "sexta-feira",
      "sábado",
      "domingo"
    ];
    return weekdays[weekInt - 1];
  }

  _saveWeek() {
    DBProvider.db.createWeek(week, weekdays);
  }

  static Future<bool> hasWeekEnded() async {
    DateTime today = DateTime.now();
    var lastNote = await DBProvider.db.getLast();

    if (lastNote != null) {

      if (today.difference(DateTime.parse(lastNote.day)).inDays >= 1) {
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
    var days = await DBProvider.db.getDays();
    if (days != null) {
      for (String day in days) {
        if (post.difference(DateTime.parse(day)).inDays >= 1) {
          DBProvider.db.deleteDay(day);
        }
      }
    }
  }
}
