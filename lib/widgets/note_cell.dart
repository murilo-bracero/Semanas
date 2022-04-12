import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:semanas/model/note.dart';
import 'package:semanas/model/todo_item.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../designs.dart';
import '../edit_note_screen.dart';
import '../utils.dart';

// ignore: must_be_immutable
class NoteCell extends StatelessWidget {
  Note _note;
  Function _updateState;

  NoteCell(Note note, Function updateState) {
    this._note = note;
    this._updateState = updateState;
  }

  String _displayNoteText(String note, String title) {
    if (note == null || note.trim().isEmpty) {
      if (title == null || title.trim().isEmpty) {
        return "Nenhuma nota para hoje :/";
      } else {
        return "Que tal colocar um corpo para essa nota?";
      }
    }

    List<String> text = [];

    if (note.contains(LIST_START_ID)) {
      var parts = note.split("//");

      for (var part in parts) {
        if (part.startsWith(LIST_START_ID) && part.endsWith(LIST_END_ID)) {
          part = part.replaceAll(LIST_START_ID, '');
          part = part.replaceAll(LIST_END_ID, '');
          part = part.trim();

          List t = jsonDecode(part);
          List<ToDoItem> items =
              t.map((raw) => ToDoItem(raw['checked'], raw['text'])).toList();

          var parsed = items.map((item) => item.checked
              ? '- [x] ~~${item.text}~~\n'
              : '- [ ] ${item.text}\n');

          text.add(parsed.join(""));
          continue;
        }

        text.add(part);
      }
    } else {
      return note;
    }

    return text.join("\n");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 9.0, bottom: 12),
                  child: Text(
                    _note.weekday.capitalize(),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _note.title == null ? "" : _note.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 20, right: 8),
              child: Row(
                children: <Widget>[
                  Flexible(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      MarkdownBody(
                          data: _displayNoteText(_note.note, _note.title)),
                    ],
                  ))
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                    icon: _note.note.isEmpty
                        ? new Icon(
                            Icons.add,
                            color: primary_dark_yellow,
                          )
                        : new Icon(
                            Icons.edit,
                            color: primary_dark_yellow,
                          ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditNoteScreen(
                                    day: _note.day.toIso8601String(),
                                    title: _note.title,
                                    note: _note.note,
                                    updateParentState: _updateState,
                                  ))).then((value) {
                        _updateState(() {});
                      });
                    })
              ],
            )
          ],
        ));
  }
}
