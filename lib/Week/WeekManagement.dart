class WeekUtils{
  var strdate = [];
  var is_final_february = (mounth, day) => mounth == 2 && day == 28;

  buildWeek(){
    DateTime date_now = new DateTime.now();
    var weeks = [];

    for(int i = 1; i <= 8; i++){
      weeks.add( date_now.add(new Duration(days: i)) );
    }

    print(weeks);

  }

}

main() {
  new WeekUtils().buildWeek();  
}

