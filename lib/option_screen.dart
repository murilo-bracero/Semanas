import 'package:flutter/material.dart';
import 'package:semanas/service/week_service.dart';
import 'designs.dart';
import 'preferences.dart';
import 'main.dart';

class OptionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OptionScreenState();
  }
}

class _OptionScreenState extends State<OptionScreen> {
  _onTapInkWellDeleteWeek(context) {
    WeekService.deleteWeek();
    userPreferences.hasCurrentWeek = false;
    save(userPreferences);
    Navigator.pop(context);
  }

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
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8, top: 14, right: 14, bottom: 8),
                  child: InkWell(
                    onTap: () => _onTapInkWellDeleteWeek(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Remover semana atual"),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 14),
                  child: Divider(
                    color: clear_grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 14, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Salvamento automático"),
                      Switch(
                          value: userPreferences.hasAutosave,
                          onChanged: (value) {
                            userPreferences.hasAutosave = value;
                            save(userPreferences);
                            setState(() {});
                          })
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
