import 'package:semanas/model/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String PREF_HASCURRENTWEEK = "hasCurrentWeek";
const String PREF_AUTOSAVE = "hasAutosave";

void save(UserPreferences up) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(PREF_HASCURRENTWEEK, up.hasCurrentWeek);
  prefs.setBool(PREF_AUTOSAVE, up.hasAutosave);
}

Future<UserPreferences> find() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final hasCurrentWeek = prefs.getBool(PREF_HASCURRENTWEEK) ?? false;
  final hasAutosave = prefs.getBool(PREF_AUTOSAVE) ?? false;

  return UserPreferences(hasAutosave, hasCurrentWeek);
}
