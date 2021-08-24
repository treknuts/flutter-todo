import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'TODO.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(
      join(await getDatabasesPath(), 'todo_database.db'),
  );

  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  // FirebaseAuth auth = FirebaseAuth.instance;
  // // This widget is the root of your application.
  // @override
  // Widget build(BuildContext context) {
  //   return ;
  // }
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return MaterialApp(
              title: 'TODO',
              theme: ThemeData(
                primarySwatch: Colors.indigo
              ),
              home: Scaffold(
                body: Center(child: Text('Something went wrong initializing Firebase App' + snapshot.error.toString())),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
                  title: 'TODO',
                  theme: ThemeData(
                    primaryColor: Colors.blue,
                    accentColor: Colors.deepOrangeAccent,
                    floatingActionButtonTheme: FloatingActionButtonThemeData(
                      backgroundColor: Colors.deepOrange,
                      elevation: 16.0,
                    ),
                  ),
                  home: HomeWidget(title: 'TODO', storage: TodoStorage()),
                );
          }

          return MaterialApp(
            title: 'TODO',
            theme: ThemeData(
              primarySwatch: Colors.indigo,
            ),
            home: Scaffold(
              body: Center(child: Text('Loading...'))
            ),
          );
        }
    );
  }
}

class HomeWidget extends StatefulWidget {
  HomeWidget({Key? key, required this.title, required this.storage}) : super(key: key);

  final String title;
  final TodoStorage storage;

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<String> todos = ['Get started'];

  SnackBar snackBar = new SnackBar(content: Text("Add a TODO"));

  void addTodo(String todo) {
    setState(() {
      todos.add(todo);
    });
  }

  @override
  void initState() {
    // TODO: https://flutter.dev/docs/cookbook/persistence/reading-writing-files
    // TODO: Make todos an array instead of a String
    super.initState();
    widget.storage.readTodos().then((String value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 12.0,
      ),
      body: Center(
        child:
        todos.isEmpty ? Text("Add some TODOs to get started") : ListView.builder(
            itemCount: todos.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      todos.removeAt(index);
                    });
                  },
                ),
                title: Text(todos[index]),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TodoForm(notifyParent: addTodo)));
        },
        tooltip: 'Add TODO',
        child: Icon(Icons.add_circle_outline),
      ),
    );
  }
}

class TodoForm extends StatefulWidget {
  TodoForm({Key? key, required this.notifyParent}) : super(key: key);

  final Function(String todo) notifyParent;

  @override
  State<StatefulWidget> createState() {
    return _TodoFormState();
  }
}

class _TodoFormState extends State<TodoForm> {
  String _todo = "";
  final _formKey = GlobalKey<FormState>();
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a TODO"),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  controller: controller,
                ),
                ElevatedButton(
                  onPressed: () {
                    if(_formKey.currentState!.validate()) {
                      setState(() {
                        _todo = controller.text;
                      });
                    }
                    widget.notifyParent(_todo);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text("Successfully added " + _todo)));
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
      ),
    );
  }
} // _todoFormState

class TodoStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/todos.txt');
  }

  Future<File> writeTodos(String todo) async {
    final file = await _localFile;

    return file.writeAsString('$todo');
  }

  Future<String> readTodos() async {
    try {
      final file = await _localFile;

      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      return "";
    }
  }
}
