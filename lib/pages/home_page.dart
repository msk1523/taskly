import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';
/* 
THIS IS THE FORMAT TO CREATE A STATEFUL WIDGET IN FLUTTER
*/

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;

  String? _newTaskContent;
  Box? _box;

  _HomePageState();
  @override
  void initState() {
    super.initState();
  } //this is a lifecycle method that is called when the state object is created

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    //print("Input Value: $_newTaskContent");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        toolbarHeight: _deviceHeight * 0.15,
        title: const Text(
          'Taskly!',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
      ),
      body: _tasksView(),
      floatingActionButton:
          _addTaskButton(), // appbar is the top bar that houses the application title
    );
  }

  Widget _tasksView() {
    // we cant use async and await to build this container as this is a ui function and it doesnt work properly in this
    //Hive.openBox('tasks');   //openBox creates a box or a container to store key:value pairs
    return FutureBuilder(
        future: Hive.openBox('tasks'),
        //future: Hive.openBox('tasks'),
        builder: (BuildContext _context, AsyncSnapshot _snapshot) {
          //if (_snapshot.connectionState == ConnectionState.done) instead of this (to remove the loading symbol, we can use:
          if (_snapshot.hasData) {
            // this works cz as we know, openBox is a future aspect that happens in the future, but when initially called, it'll open a box first and we can use this property to our advantage
            //in this if there is data, then it'll load for 2 seconds before displaying the data
            _box = _snapshot.data;
            //the _box variable will create a box to store the data
            return _tasksList();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _tasksList() {
    /* Task _newTask =
        Task(content: "Go to gym", timestamp: DateTime.now(), done: false);
    _box?.add(_newTask.toMap());
    */
    // The above piece of code can be done to add new tasks to the database
    // The below code is to display the tasks in the list

    List tasks = _box!.values
        .toList(); //ikt if i call this, there is bound to be a value for this variable

    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext _context, int _index) {
          var task = Task.fromMap(tasks[_index]);
          return ListTile(
            title: Text(
              task.content,
              style: TextStyle(
                  decoration: task.done ? TextDecoration.lineThrough : null),
            ),
            subtitle: Text(
              //DateTime.now().toString(),
              task.timestamp.toString(),
            ), //this gives the current time under the title
            trailing: Icon(
              task.done
                  ? Icons.check_box_outlined
                  : Icons
                      .check_box_outline_blank_outlined, // if checked, the value will change
              color: Colors.red,
            ),
            onTap: () {
              task.done = !task.done;
              _box!.putAt(
                _index,
                task.toMap(),
              );
              setState(() {}); //we need to set the state of the changes made
              // we can do it in this way too:
              /*
              setState(() {
                task.done = !task.done;
                _box.putAt(_index, task.toMap());
              });
              */
            },
            onLongPress: () {
              _box!.deleteAt(_index);
              setState(() {});
            },
          );
        });
  }

  // ListView(
  //   //its like rows and column but the difference is that ListView is scrollable
  //   children: [
  //     ListTile(
  //       title: const Text(
  //         "Do Laundry!",
  //         style: TextStyle(decoration: TextDecoration.lineThrough),
  //       ),
  //       subtitle: Text(
  //         DateTime.now().toString(),
  //       ), //this gives the current time under the title
  //       trailing: const Icon(
  //         Icons.check_box_outlined,
  //         color: Colors.red,
  //       ),
  //     ),
  //
  // //ListTile is a widget that is used to create a list item
  // ListTile(
  //   title: const Text(
  //     "Do The Dishes!",
  //     style: TextStyle(decoration: TextDecoration.lineThrough),
  //   ),
  //   subtitle: Text(
  //     DateTime.now().toString(),
  //   ), //this gives the current time under the title
  //   trailing: const Icon(
  //     Icons.check_box_outlined,
  //     color: Colors.red,
  //   ),
  // ),
  //     ],
  //   );
  // }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      backgroundColor: Colors.red,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: const Text("Add new Task"),
          content: TextField(
            onSubmitted: (_) {
              if (_newTaskContent != null) {
                var _task = Task(
                    content: _newTaskContent!,
                    timestamp: DateTime.now(),
                    done: false);
                _box?.add(_task.toMap());
                setState(() {
                  _newTaskContent = null;
                  Navigator.pop(context);
                });
              }
            },
            onChanged: (_value) {
              setState(() {
                _newTaskContent = _value;
              }); //setstate will automatically call the build func to update the value
            },
          ),
        ); //for showing an alert message and also we can add functions/properties to this AlertDialog
      },
    );
  }
}
