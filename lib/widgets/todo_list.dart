import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:semanas/model/todo_item.dart';

class ToDoList extends StatefulWidget {
  _ToDoListState _state;

  List<ToDoItem> items = [];

  ToDoList(this.items);

  @override
  State<StatefulWidget> createState() {
    _state = _ToDoListState(items);
    return _state;
  }

  String get text {
    return _state.text;
  }
}

class _ToDoListState extends State<ToDoList> with TickerProviderStateMixin {
  List<ToDoItem> items = [];

  _ToDoListState(this.items);

  String get text {
    var sc = items.where((item) => item.controller.text.isNotEmpty).toList();

    if (sc.isEmpty) {
      return '';
    }

    String parsed = '//list-start[';

    var rawItems = sc.map((item) {
      item.persist();
      return '{"checked":${item.checked},"text":"${item.text}"}';
    }).toList();

    parsed = parsed + rawItems.join(',');

    return parsed + ']list-end//';
  }

  _buildListItem() {
    if (items.isEmpty) {
      items.add(ToDoItem(false, ''));
    }

    items.forEach((item) {
      if (item.controller == null) {
        item.controller = TextEditingController(text: item.text);
      }

      if (item.focusNode == null) {
        item.focusNode = FocusNode();
      }
    });

    setState(() {});
  }

  _addListItem() {
    var item = ToDoItem(false, '');
    item.controller = TextEditingController(text: item.text);
    item.focusNode = FocusNode();
    items.add(item);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _buildListItem();
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Row(
        children: [
          Expanded(
            flex: 1,
            child: CheckboxListTile(
                value: items[index].checked,
                onChanged: (value) {
                  setState(() {
                    items[index].checked = value;
                  });
                }),
          ),
          Expanded(
            flex: 4,
            child: TextField(
              controller: items[index].controller,
              focusNode: items[index].focusNode,
              maxLines: 1,
              enabled: !items[index].checked,
              onEditingComplete: () {
                _addListItem();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FocusScope.of(context).requestFocus(items.last.focusNode);
                });
              },
              style: TextStyle(
                  fontSize: 18,
                  decoration: items[index].checked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none),
              decoration:
                  InputDecoration(border: InputBorder.none, hintText: "Tarefa"),
            ),
          )
        ],
      ),
    );
  }
}
