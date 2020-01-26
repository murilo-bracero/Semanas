import 'package:flutter/material.dart';
import 'package:semanas/OptionScreen.dart';
import 'package:semanas/database/Database.dart';
import 'package:semanas/database/NoteModel.dart';
import 'Designs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'EditNoteScreen.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

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
  //strings de dias da semana
  var weekdays = [];

  //strings de datas completas
  var strdate = [];

  List<Widget> listDays = [];

  //******************* CONSTRUTOR **********************************

  _MyHomePageState() {
    _hasWeekEnded();
    _loadSharedPrefs();
    _deletePastDay();
  }

  //************ PREFS **********************************************

  void _saveNewPref(bool hasCurrentWeek) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(PREF_HASCURRENTWEEK, hasCurrentWeek);
  }

  Future<bool> _loadSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final hasCurrentWeek = prefs.getBool(PREF_HASCURRENTWEEK) ?? false;
    print("_loadSharedPrefs()\nPREF hasCurrentWeek: ${hasCurrentWeek.toString()}");
    alreadyClicked = hasCurrentWeek;
    setState(() {});
    return hasCurrentWeek;
  }

  //***********************CONSTRUÇÃO E GERENCIAMENTO DA SEMANA*************************

  _deletePastDay() async {
    DateTime post = DateTime.now();
    print("_deletePastDay: \n DIA DE HOJE " + post.toString());
    DBProvider.db.getDays().then((var res) {
      if(res != null){
        for(String day in res){
          if(post.difference(DateTime.parse(day)).inDays >= 1){
            DBProvider.db.deleteDay(day);
            setState(() {});
          }
        }
      }
    });
  }

  _hasWeekEnded() async {
    DateTime today = DateTime.now();
    print("_hasWeekEnded: \n HOJE " + today.toString());
    DBProvider.db.getLast().then((var res) {
      if (res != null) {
        print("ÚLTIMO DIA DA SEMANA: "+res.day);
        if (today.difference(DateTime.parse(res.day)).inDays >= 1) {
          _showDialog("end_week");
        } else {
          print("_hasWeekEnded: \n não é");
        }
      }
    });
  }

  _buildWeek() {
    var data = new DateTime.now();
    //dias
    var days = [];
    bool virouMes = false;
    int dia = data.day, mes = data.month, ano = data.year;

    for (int i = 0; i <= 7; i++) {
      if (mes == 2 && dia == 28) {
        days.add(28);
        dia = 1;
        virouMes = true;
      } else if (mes == 4 && dia == 30 || mes == 6 && dia == 30 || mes == 9 && dia == 30 || mes == 11 && dia == 30) {
        days.add(30);
        dia = 1;
        virouMes = true;
      } else if (dia == 31) {
        days.add(31);
        dia = 1;
        virouMes = true;
      } else {
        days.add(dia++);
      }

      print("_buildWeek(): \n" + days[i].toString() + "/" + mes.toString());

      strdate.add(buildStringDate(days[i], mes, ano));
      print(strdate);

      var newdate = DateTime.parse(strdate[i]);
      weekdays.add(_intForWeek(newdate.weekday));

      if (virouMes) {
        mes = mes + 1;
        virouMes = false;
      }
    }
  }

  String buildStringDate(int dia, int mes, int ano) {
    if (dia < 10 && mes < 10) {
      return "${ano.toString()}-0${mes.toString()}-0${dia.toString()} 20:00:01";

    } else if (dia >= 10 && mes < 10) {

      return "${ano.toString()}-0${mes.toString()}-${dia.toString()} 20:00:01";
    } else if (dia < 10 && mes >= 10) {

      return "${ano.toString()}-${mes.toString()}-0${dia.toString()} 20:00:01";
    } else {

      return "${ano.toString()}-${mes.toString()}-${dia.toString()} 20:00:01";
    }
  }

  _intForWeek(int weekCode) {
    var weekdays = ["segunda-feira", "terça-feira", "quarta-feira", "quinta-feira", "sexta-feira", "sábado","domingo"];
    return weekdays[weekCode - 1];
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
      appBar: GradientAppBar(
        backgroundColorStart: primary_yellow,
        backgroundColorEnd: Color.fromRGBO( 255, 255, 102,1),
        elevation: 1,
        title: Text(
          widget.title,
          style: TextStyle(color: pretty_black),
        ),
        actions: <Widget>[_buildPlusButton(), _buildOptionsButton()],
      ),
      body: FutureBuilder(
          future: DBProvider.db.getWeek(),
          builder: (BuildContext context, AsyncSnapshot<List<Notes>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    Notes item = snapshot.data[index];
                    print(item.day);
                    return Card(
                        elevation: 2,
                        child: ExpansionTile(
                          title: _roundAdvice(item.note, item.title, item.day),
                          children: <Widget>[
                            Column(
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  padding:
                                      const EdgeInsets.only(left: 10, bottom: 8, right:8),
                                  child: Row(
                                    children: <Widget>[
                                      Flexible(child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(_isNoteNull(item.note, item.title)),
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
    _buildWeek();

    var strdate = [];
    for (int i = 0; i <= 7; i++) {
      String parseData = this.strdate[i].toString().substring(0, 10);
      strdate.add(parseData);
    }

    DBProvider.db.createWeek(strdate, weekdays);
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
      if(title == null || title.isEmpty || title == " "){
        return "Nenhuma nota para hoje :/";
      }else {
        return "Que tal colocar um corpo para essa nota?";
      }
    } else {
      return note;
    }
  }

  var _isTitleNull = (String title) => (title == null) ?  "" : title;

  _roundAdvice(String note, String title, String day) {
    if ((note != null && note.isNotEmpty && note != " ") || (title != null && title.isNotEmpty && title != " ")) {
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
