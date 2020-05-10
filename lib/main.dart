import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:semanas/OptionScreen.dart';
import 'package:semanas/Week/WeekManagement.dart';
import 'package:semanas/database/Database.dart';
import 'package:semanas/database/NoteModel.dart';
import 'Preferences.dart';
import 'Designs.dart';
import 'EditNoteScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semanas',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
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

var alreadyClicked = false;

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    WeekUtils.hasWeekEnded()
        .then((var res) => res ? _showDialog("end_week") : null);

    loadSharedPrefs().then((value) {
      alreadyClicked = value;
      setState(() {});
    });

    WeekUtils.deletePastDay().then((var res) => setState(() {}));
  }

  Widget _buildPlusButton() {
    if (!alreadyClicked) {
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

  _buildOptionsButton() {
    return Flexible(
      child: IconButton(
          icon: Icon(
            Icons.settings,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => OptionScreen()));
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
    print('builded');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          widget.title,
          style: TextStyle(color: primary_dark_yellow),
        ),
        actions: <Widget>[_buildPlusButton(), _buildOptionsButton()],
      ),
      body: FutureBuilder(
          future: DBProvider.db.getWeek(),
          builder: (BuildContext context, AsyncSnapshot<List<Notes>> snapshot) {
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
                      Notes item = snapshot.data[index];
                      return GridTile(
                        child: Card(
                            elevation: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        item.weekday,
                                        style: subtitleStyle,
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Divider(
                                    height: 12,
                                    color: clear_grey,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, top: 8, bottom: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _isTitleNull(item.title),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 8, right: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Flexible(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(_isNoteNull(
                                              item.note, item.title)),
                                        ],
                                      ))
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Divider(
                                    height: 12,
                                    color: clear_grey,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    IconButton(
                                        icon: _changeNoteIcon(item.note),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditNoteScreen(
                                                        day: item.day,
                                                        title: item.title,
                                                        note: item.note,
                                                      ))).then((value) {
                                            setState(() {});
                                          });
                                        })
                                  ],
                                )
                              ],
                            )),
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

  void _createWeek() {
    WeekUtils wu = new WeekUtils();

    wu.buildWeek();

    alreadyClicked = true;
    saveNewPref(alreadyClicked);
  }
  
  _showFriendlyDate(String date) {
    String dia = date.substring(8, 10);
    String mes = date.substring(5, 7);

    return dia + "/" + mes;
  }

  _changeNoteIcon(String note) {
    if (note == null) {
      return new Icon(
        Icons.add,
        color: clear_grey,
      );
    } else {
      return new Icon(
        Icons.edit,
        color: clear_grey,
      );
    }
  }

  String _isNoteNull(String note, String title) {
    if (note == null || note.isEmpty || note == " ") {
      if (title == null || title.isEmpty || title == " ") {
        return "Nenhuma nota para hoje :/";
      } else {
        return "Que tal colocar um corpo para essa nota?";
      }
    } else {
      return note;
    }
  }

  var _isTitleNull = (String title) => (title == null) ? "" : title;

  roundAdvice(String note, String title, String day) {
    if ((note != null && note.isNotEmpty && note != " ") ||
        (title != null && title.isNotEmpty && title != " ")) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(_showFriendlyDate(day)),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              width: 10,
              height: 10,
              decoration: new BoxDecoration(
                color: primary_yellow,
                shape: BoxShape.circle,
              ),
            ),
          )
        ],
      );
    } else {
      return Text(_showFriendlyDate(day));
    }
  }

  _showDialog(String s) {
    switch (s) {
      case "end_week":
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Sua Semana Acabou"),
                content: Text(
                    "Iremos apagà-la para que você possa criar uma nova semana.\n"
                    "Recomeçar é essencial :D"),
                contentPadding: EdgeInsets.all(10),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      DBProvider.db.deleteWeek();
                      Navigator.of(context).pop();
                      alreadyClicked = false;
                      saveNewPref(alreadyClicked);
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Ok, apagar."),
                    ),
                  )
                ],
              );
            });
    }
  }
}
