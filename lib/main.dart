import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:semanas/model/user_preferences.dart';
import 'package:semanas/option_screen.dart';
import 'package:semanas/service/week_service.dart';
import 'package:semanas/theme.dart';
import 'package:semanas/widgets/note_cell.dart';
import 'preferences.dart';
import 'designs.dart';
import 'model/note.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semanas',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: MyHomePage(title: 'Semanas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

UserPreferences userPreferences = UserPreferences(false, false);

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    WeekService.hasWeekEnded().then((var res) => res
        ? _showDialog(
            "Sua Semana Acabou",
            "Iremos apagà-la para que você possa criar uma nova semana.\n"
                "Recomeçar é essencial :D",
            "Ok, apagar.")
        : null);

    find().then((value) {
      userPreferences = value;
      setState(() {});
    });

    WeekService.deletePastDay().then((var res) => setState(() {}));
  }

  Widget _buildPlusButton() {
    if (!userPreferences.hasCurrentWeek) {
      return Flexible(
          child: IconButton(
        onPressed: () {
          _createWeek();
          setState(() {});
        },
        icon: Icon(Icons.add),
      ));
    } else {
      return Flexible(
        child: Container(),
      );
    }
  }

  Widget _buildOptionsButton() {
    return Flexible(
      child: IconButton(
          icon: Icon(
            Icons.settings,
          ),
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => OptionScreen()));
            setState(() {});
          }),
    );
  }

  EdgeInsets _paddingForView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double padding;
    const double top_bottom = 8;

    if (width > 500) {
      padding = (width) * 0.5; //5% of width padding
    } else {
      padding = 8;
    }

    return EdgeInsets.only(
        left: padding, right: padding, top: top_bottom, bottom: top_bottom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          widget.title,
          style: TextStyle(color: primary_dark_yellow),
        ),
        actions: <Widget>[_buildPlusButton(), _buildOptionsButton()],
      ),
      body: FutureBuilder(
          future: WeekService.getWeek(),
          builder: (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
            if (snapshot.hasData) {
              return Container(
                  child: Padding(
                padding: _paddingForView(context),
                child: StaggeredGridView.count(
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    staggeredTiles: List.generate(
                        snapshot.data.length, (index) => StaggeredTile.fit(1)),
                    children: List.generate(snapshot.data.length, (int index) {
                      Note item = snapshot.data[index];
                      return GridTile(
                        child: NoteCell(item, setState),
                      );
                    })),
              ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  _createWeek() {
    WeekService.createWeek();

    userPreferences.hasCurrentWeek = true;
    save(userPreferences);
  }

  _showDialog(String title, String body, String accept) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(body),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  WeekService.deleteWeek();
                  Navigator.of(context).pop();
                  userPreferences.hasCurrentWeek = false;
                  save(userPreferences);
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(accept),
                ),
              )
            ],
          );
        });
  }
}
