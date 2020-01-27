import 'package:flutter/material.dart';
import 'package:semanas/OptionScreen.dart';
import 'package:semanas/Week/WeekManagement.dart';
import 'package:semanas/database/Database.dart';
import 'package:semanas/database/NoteModel.dart';
import 'Designs.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
const String PREF_HASCURRENTWEEK = "hasCurrentWeek";

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    WeekUtils.hasWeekEnded()
        .then((var res) => {res ? _showDialog("end_week") : null});

    _loadSharedPrefs();
    WeekUtils.deletePastDay().then((var res) => {setState(() {})});
  }

  //************ PREFS **********************************************

  void _saveNewPref(bool hasCurrentWeek) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(PREF_HASCURRENTWEEK, hasCurrentWeek);
  }

  Future<bool> _loadSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final hasCurrentWeek = prefs.getBool(PREF_HASCURRENTWEEK) ?? false;
    print(
        "_loadSharedPrefs()\nPREF hasCurrentWeek: ${hasCurrentWeek.toString()}");
    alreadyClicked = hasCurrentWeek;
    setState(() {});
    return hasCurrentWeek;
  }

  //**************************METODOS QUE CRIAM ICONES DA APP BAR***********************************

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

  //********************CONSTROI O DESIGN DA PAGINA*********************************

  @override
  Widget build(BuildContext context) {
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
              return GridView.builder(
                  itemCount: snapshot.data.length,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    Notes item = snapshot.data[index];
                    print(item.day);
                    return Card(
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
                                      Text(
                                          _isNoteNull(item.note, item.title)),
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
                                                  )));
                                    })
                              ],
                            )
                          ],
                        ));
                  });
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
    _saveNewPref(alreadyClicked);
  }

  //******************GERENCIAMENTO DA NOTA *********************************

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

  _roundAdvice(String note, String title, String day) {
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

  //*********************MOSTRA UM DIALOG PARA O USUARIO ************************

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
                      _saveNewPref(alreadyClicked);
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
