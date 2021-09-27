import 'package:flutter/material.dart';
import 'package:semanas/service/week_service.dart';
import 'designs.dart';
import 'preferences.dart';
import 'main.dart';

class OptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          "Opções",
          style: TextStyle(color: primary_dark_yellow),
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
                        child: TextButton.icon(
                            onPressed: () {
                              WeekService.deleteWeek();
                              alreadyClicked = false;
                              saveNewPref(alreadyClicked);
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.delete,
                            ),
                            label: Text("Deletar semana atual.")),
                      ),
                    ],
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
