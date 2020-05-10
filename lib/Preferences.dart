import 'package:shared_preferences/shared_preferences.dart';

const String PREF_HASCURRENTWEEK = "hasCurrentWeek";

void saveNewPref(bool hasCurrentWeek) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(PREF_HASCURRENTWEEK, hasCurrentWeek);
}

Future<bool> loadSharedPrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final hasCurrentWeek = prefs.getBool(PREF_HASCURRENTWEEK) ?? false;

  return hasCurrentWeek;
}
