import 'package:flutter/widgets.dart';

class ToDoItem {
  bool checked;
  String text;
  TextEditingController controller;
  FocusNode focusNode;

  ToDoItem(this.checked, this.text);

  persist() {
    this.text = this.controller.text;
  }

  //retorna os dados de um objeto em forma de Json/Map
  factory ToDoItem.fromJson(Map<String, dynamic> json) =>
      ToDoItem(json['checked'], json['text']);
}
