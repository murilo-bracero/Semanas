import 'package:flutter/material.dart';
import 'package:semanas/database/Database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Designs.dart';
import 'main.dart';

class OptionScreen extends StatelessWidget {

  void _saveNewPref(bool hasCurrentWeek) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(PREF_HASCURRENTWEEK, hasCurrentWeek);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Opções",
          style: TextStyle(color: pretty_black),
        ),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: FlatButton.icon(
                            onPressed: () {
                              DBProvider.db.deleteWeek();
                              print("Semana deletada");
                              alreadyClicked = false;
                              _saveNewPref(alreadyClicked);
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: light_grey,
                            ),
                            label: Text("Deletar semana atual.")),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Divider(
                    color: light_grey,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
