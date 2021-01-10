import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:semanas/OptionScreen.dart';
import 'package:semanas/Week/WeekManagement.dart';
import 'package:semanas/database/Database.dart';
import 'package:semanas/database/NoteModel.dart';
import 'package:semanas/widgets/NoteCell.dart';
import 'Preferences.dart';
import 'Designs.dart';

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
    WeekUtils.hasWeekEnded().then((var res) => res
        ? _showDialog(
            "Sua Semana Acabou",
            "Iremos apagà-la para que você possa criar uma nova semana.\n"
                "Recomeçar é essencial :D",
            "Ok, apagar.")
        : null);

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

  Widget _buildOptionsButton() {
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
    WeekUtils wu = new WeekUtils();

    wu.buildWeek();

    alreadyClicked = true;
    saveNewPref(alreadyClicked);
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
                  child: Text(accept),
                ),
              )
            ],
          );
        });
  }
}
