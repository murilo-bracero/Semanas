import 'package:semanas/database/Database.dart';

class WeekUtils{
  var week = [ ];
  var weekdays = [];

  buildWeek(){
    DateTime date_now = new DateTime.now();

    for(int i = 0; i <= 7; i++){
      var context_day = date_now.add(new Duration(days: i));
      week.add( context_day.toString().split(' ')[0] );
      weekdays.add( _parseIntDate(context_day.weekday) );
    }

    _saveWeek();
  }

  _parseIntDate(weekInt){
    var weekdays = ["segunda-feira", "terça-feira", "quarta-feira", "quinta-feira", "sexta-feira", "sábado","domingo"];
    return weekdays[weekInt - 1];
  }

  _saveWeek(){
    DBProvider.db.createWeek(week, weekdays);
  }

  static Future<bool> hasWeekEnded() async {
    DateTime today = DateTime.now();
    print("_hasWeekEnded: \n HOJE " + today.toString());
    var last_note = await DBProvider.db.getLast();

    if (last_note != null) {
      print("ÚLTIMO DIA DA SEMANA: "+last_note.day);

      if (today.difference(DateTime.parse(last_note.day)).inDays >= 1) {
        return true;

      } else {
        return false;
      }
    }
  }

  static deletePastDay() async {
    DateTime post = DateTime.now();
    print("_deletePastDay: \n DIA DE HOJE " + post.toString());
    var days = await DBProvider.db.getDays();
    if(days != null){
      for(String day in days){
        if(post.difference(DateTime.parse(day)).inDays >= 1){
          DBProvider.db.deleteDay(day);
        }
      }
    }
  }

}
