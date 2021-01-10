import 'package:flutter/material.dart';
import 'package:semanas/database/Database.dart';
import 'Designs.dart';
import 'Designs.dart';
import 'Designs.dart';
import 'Designs.dart';

class EditNoteScreen extends StatefulWidget {
  final String day;
  final String title;
  final String note;

  EditNoteScreen({Key key, @required this.day, this.title, this.note})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditNoteScreenState(day, title, note);
  }
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  var noteController = TextEditingController();
  var titleController = TextEditingController();

  String day;

  var noteNode = FocusNode();
  var titleNode = FocusNode();

  _EditNoteScreenState(String day, String title, String note) {
    this.day = day;
    titleController.text = (title == " ") ? null : title;
    noteController.text = (note == " ") ? null : note;

    print('$day, $title, $note');
  }

  _saveNote() {
    DBProvider.db
        .addNote(day, titleController.text, noteController.text)
        .then((value) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0.0),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 8.0),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 18, left: 18, right: 18),
                  child: TextField(
                    controller: titleController,
                    focusNode: titleNode,
                    autofocus: true,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(noteNode);
                    },
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Título"),
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(left: 18, right: 8),
                  child: TextField(
                    controller: noteController,
                    focusNode: noteNode,
                    maxLines: 10,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Corpo da nota"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        child: RaisedButton.icon(
                          onPressed: () {
                            _saveNote();
                          },
                          color: primary_dark_yellow,
                          elevation: 0,
                          label: Text(
                            "Registrar Nota",
                            style: TextStyle(color: white),
                          ),
                          icon: Icon(
                            Icons.edit,
                            color: white,
                          ),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
