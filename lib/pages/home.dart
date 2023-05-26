import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_online/models/models.dart';
import 'package:todo_online/utils/dialogbox.dart';
import 'package:todo_online/utils/todo_tile.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();
  List todoList = [];
  final _dbBox = Hive.box('dbBox');

  @override
  void initState() {
    super.initState();
    getTodos();
  }

  void checkBoxChanged(bool? val, int index, bool prevVal) async {
    final response = await http.post(
        Uri.parse('https://Todo.sheikhumaid.repl.co/update/$index'),
        body: jsonEncode({"newDone": !prevVal}),
        headers: {
          'Content-Type': 'application/json',
          'authorization': "Token ${_dbBox.get('token')}",
        });
    if (response.statusCode == 200) {
      setState(() {
        getTodos();
      });
    }
  }

  void addNewTodo() async {
    var response =
        await http.post(Uri.parse('https://Todo.sheikhumaid.repl.co/'),
            body: jsonEncode({
              "todo": _controller.text.toString(),
            }),
            headers: {
          'Content-Type': 'application/json',
          'authorization': "Token ${_dbBox.get('token')}",
        });
    if (response.statusCode == 200) {
      setState(() {
        getTodos();
        _controller.clear();
      });
    }
    Navigator.of(context).pop();
  }

  void createNewTodo() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onSave: addNewTodo,
            onCancel: () => Navigator.of(context).pop(),
          );
        });
  }

  deleteTodo(int index) async {
    final response = await http.get(
        Uri.parse('https://Todo.sheikhumaid.repl.co/delete/$index'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': "Token ${_dbBox.get('token')}",
        });
    if (response.statusCode == 200) {
      setState(() {
        getTodos();
      });
    }
  }

  getTodos() async {
    todoList.clear();
    final response = await http
        .get(Uri.parse('https://Todo.sheikhumaid.repl.co/'), headers: {
      'Content-Type': 'application/json',
      'authorization': "Token ${_dbBox.get('token')}",
    });
    if (response.statusCode == 200) {
      final todosJson = jsonDecode(response.body) as List;
      setState(() {
        for (var todoJson in todosJson) {
          todoList.add(Todo(
              id: todoJson['id'],
              todo: todoJson['todo'],
              done: todoJson['done']));
        }
      });
    } else {
      throw Exception('Failed to load todos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[200],
      appBar: AppBar(
        title: const Text(
          'To Do',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton(
            color: Colors.white,
            onSelected: (value) async {
              if (value == 1) {
                await _dbBox.delete('token');
                await Navigator.popAndPushNamed(context, '/');
              } else {
                debugPrint('About');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Text('Logout'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('About'),
              ),
            ],
          )
        ],
      ),
      body: todoList.isEmpty
          ? const Center(
              child: Text("No todos created yet!"),
            )
          : ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                return TodoTile(
                  taskName: todoList[index].todo,
                  taskCompleted: todoList[index].done,
                  onChanged: (val) => checkBoxChanged(
                      val, todoList[index].id, todoList[index].done),
                  deleteTodo: (context) => deleteTodo(todoList[index].id),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createNewTodo(),
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}
