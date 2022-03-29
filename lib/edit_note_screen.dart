import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:semanas/model/note.dart';
import 'package:semanas/model/todo_item.dart';
import 'package:semanas/service/week_service.dart';
import 'package:semanas/utils.dart';
import 'package:semanas/widgets/todo_list.dart';
import 'designs.dart';

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
  var titleController = TextEditingController();
  List<Widget> columnWidgets = [];
  List<TextEditingController> controllers = [];
  List<FocusNode> focuses = [];

  String day;
  String note;

  var titleNode = FocusNode();

  _EditNoteScreenState(String day, String title, String note) {
    this.day = day;
    this.note = note;
    titleController.text = (title.isEmpty) ? null : title;
  }

  _saveNote() {
    String body = '';

    columnWidgets.forEach((widget) {
      var key = normalizeKey(widget.key);
      if (key.contains('textBody')) {
        int pos = int.parse(key.replaceAll('textBody', ''));
        body = body + controllers[pos].text;
        return;
      }

      if (widget.runtimeType == ToDoList) {
        var aux = widget as ToDoList;
        body = body + aux.text;
      }
    });

    WeekService.addNote(Note(DateTime.parse(day), titleController.text, body))
        .then((value) {
      Navigator.pop(context);
    });
  }

  _addTextOnSelected() {
    var controller = TextEditingController();
    var focus = FocusNode();
    controllers.add(controller);
    focuses.add(focus);

    columnWidgets.insert(columnWidgets.length - 1,
        _buildTextBodyContainer(controller, focus, focuses.length));
    setState(() {});
  }

  _addToDoOnSelected() {
    columnWidgets.insert(columnWidgets.length - 1, ToDoList([]));
    setState(() {});
  }

  _onSelected(int item) {
    switch (item) {
      case 0:
        _addToDoOnSelected();
        break;
      case 1:
        _addTextOnSelected();
        break;
    }
  }

  PopupMenuButton _buildOptionsMenu() {
    return PopupMenuButton(
        onSelected: (item) => _onSelected(item),
        itemBuilder: (context) => [
              PopupMenuItem<int>(value: 0, child: Text("Adicionar Lista")),
              PopupMenuItem<int>(value: 1, child: Text("Adicionar Texto"))
            ]);
  }

  Widget _buildTitleContainer() {
    return Container(
      key: Key("title"),
      margin: const EdgeInsets.only(top: 18, left: 18, right: 18),
      child: TextField(
        controller: titleController,
        focusNode: titleNode,
        autofocus: true,
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(focuses.first);
        },
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        decoration:
            InputDecoration(border: InputBorder.none, hintText: "Título"),
      ),
    );
  }

  Widget _buildTextBodyContainer(
      TextEditingController controller, FocusNode focusNode, int nextFocusPos) {
    return Container(
      key: Key('textBody${controllers.length - 1}'),
      margin: new EdgeInsets.only(left: 18, right: 8),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: null,
        onEditingComplete: () {
          if (nextFocusPos == -1) {
            return;
          }

          if (!focuses.asMap().containsKey(nextFocusPos)) {
            return;
          }
          FocusScope.of(context).requestFocus(focuses[nextFocusPos]);
        },
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
            border: InputBorder.none, hintText: "Corpo da nota"),
      ),
    );
  }

  Widget _buildRegisterNoteButton() {
    return Padding(
      key: Key('registerNoteButton'),
      padding: const EdgeInsets.only(right: 16.0, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: ElevatedButton.icon(
              onPressed: () {
                _saveNote();
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(primary_dark_yellow),
                  elevation: MaterialStateProperty.all(0),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30)))),
              label: Text(
                "Registrar Nota",
                style: TextStyle(color: white),
              ),
              icon: Icon(
                Icons.edit,
                color: white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildNoteEdition() {
    if (columnWidgets.length > 0) {
      return;
    }

    columnWidgets.add(_buildTitleContainer());

    print(this.note);

    if (!this.note.contains(LIST_START_ID)) {
      var controller = TextEditingController();
      controller.text = this.note;
      var focus = FocusNode();
      controllers.add(controller);
      focuses.add(focus);
      columnWidgets.add(_buildTextBodyContainer(controller, focus, -1));
    } else {
      var parts = this.note.split("//");

      for (var part in parts) {
        print("PART " + part);

        if (part.startsWith(LIST_START_ID) && part.endsWith(LIST_END_ID)) {
          part = part.replaceAll(LIST_START_ID, '');
          part = part.replaceAll(LIST_END_ID, '');
          part = part.trim();

          List t = jsonDecode(part);
          List<ToDoItem> items =
              t.map((raw) => ToDoItem(raw['checked'], raw['text'])).toList();
          columnWidgets.add(ToDoList(items));
          continue;
        }
        var controller = TextEditingController();
        controller.text = part;
        var focus = FocusNode();
        controllers.add(controller);
        focuses.add(focus);
        columnWidgets
            .add(_buildTextBodyContainer(controller, focus, focuses.length));
      }
    }

    columnWidgets.add(_buildRegisterNoteButton());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _buildNoteEdition();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: [_buildOptionsMenu()],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 8.0),
            child: Column(
              children: columnWidgets,
            ),
          ),
        ));
  }
}
