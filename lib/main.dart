import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
