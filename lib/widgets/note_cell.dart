import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:semanas/model/note.dart';

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

  String _isNoteNull(String note, String title) {
    if (note == null || note.trim().isEmpty) {
      if (title == null || title.trim().isEmpty) {
        return "Nenhuma nota para hoje :/";
      } else {
        return "Que tal colocar um corpo para essa nota?";
      }
    } else {
      return note;
    }
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
                    style: subtitleStyle,
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
                      Text(_isNoteNull(_note.note, _note.title)),
                    ],
                  ))
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                    icon: _note.note == null
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
