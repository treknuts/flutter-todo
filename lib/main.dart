import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
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
                  themeMode: ThemeMode.dark,
                  theme: ThemeData(
                    primarySwatch: Colors.indigo,
                  ),
                  home: HomeWidget(title: 'TODO'),
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
  HomeWidget({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int _counter = 0;
  List<String> todos = ['Get started'];

  SnackBar snackBar = new SnackBar(content: Text("Add a TODO"));

  void addTodo(String todo) {
    setState(() {
      todos.add(todo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
        tooltip: 'Increment',
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
      body: Form(
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
    );
  }

}
