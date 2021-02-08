import 'package:flutter/material.dart';
import 'package:lists/src/model/todo_list.dart';
import 'package:lists/src/model/todo_tab.dart';
import 'package:lists/src/service/sqflite.dart';
import 'package:lists/src/styles.dart';
import 'package:lists/src/widgets/todo/add_list.dart';
import 'package:lists/src/widgets/todo/todo_card.dart';
import 'package:lists/src/utils/context.dart';

class TabWidget extends StatefulWidget {
  final TodoTab tab;
  final double paddingTop;

  TabWidget({Key key, @required this.tab, this.paddingTop}) : super(key: key);

  @override
  TabWidgetState createState() => TabWidgetState();
}

class TabWidgetState extends State<TabWidget> {
  void addList(TodoList list) {
    setState(() {
      widget.tab.todoLists.add(list);
    });
  }

  void _addList(String title) async {
    if (title != null && title.isNotEmpty) {
      int id = await DBProvider.instance.addList(title, widget.tab.id);
      scaffold.showSnackBar(SnackBar(
        content: Text('New list has been added'),
      ));
      setState(() {
        widget.tab.todoLists.add(TodoList(title, id: id, todos: []));
      });
    }
  }

  void _deleteList(int id) async {
    final list = widget.tab.todoLists.singleWhere((list) => list.id == id);
    final listIndex = widget.tab.todoLists.indexOf(list);
    final duration = Duration(seconds: 4);
    bool delete = true;

    final snackBar = SnackBar(
      duration: duration,
      content: Row(
        children: [
          Text('List "'),
          Text(list.title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text('" was deleted.'),
        ],
      ),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          delete = false;
          setState(() {
            widget.tab.todoLists.insert(listIndex, list);
          });
        },
      ),
    );

    setState(() {
      widget.tab.todoLists.remove(list);
    });

    scaffold.showSnackBar(snackBar);

    Future.delayed(duration, () {
      if (delete) DBProvider.instance.deleteList(id);
    });
  }

  @override
  Widget build(context) {
    final listsContainer = Column(
      children: [
        widget.tab.todoLists.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 8),
                  scrollDirection: Axis.vertical,
                  itemCount: widget.tab.todoLists.length,
                  itemBuilder: (_, index) => ToDoCard(
                    todoList: widget.tab.todoLists[index],
                    onDelete: _deleteList,
                  ),
                ),
              )
            : Text('Nothing here yet',
                style: TextStyle(color: AppColors.backgroundGrey))
      ],
    );

    return Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: widget.tab == null
          ? Center(
              child: Text("Something is not okay"),
            )
          : listsContainer,
    );
  }
}
