import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;
  String? _newTaskContent;
  DateTime? _newTaskDeadline;
  Box<Task>? _box;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
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
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _tasksView() {
    return FutureBuilder(
      future: Hive.openBox<Task>('tasks'),
      builder: (BuildContext _context, AsyncSnapshot<Box<Task>> _snapshot) {
        if (_snapshot.hasData) {
          _box = _snapshot.data;
          return _tasksList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _tasksList() {
    List<Task> tasks = _box!.values.toList().cast<Task>();
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext _context, int _index) {
        Task task = tasks[_index];
        String subtitleText = task.done
            ? (task.deadline != null
                ? (task.timestamp.isBefore(task.deadline!)
                    ? 'On Time'
                    : 'Over Time')
                : 'Completed')
            : (task.deadline != null
                ? 'Deadline: ${DateFormat('MMM d, y hh:mm a').format(task.deadline!)}'
                : 'No Deadline');

        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(subtitleText),
          trailing: Icon(
            task.done
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_outlined,
            color: Colors.red,
          ),
          onTap: () {
            setState(() {
              task.done = !task.done;
              if (task.done) {
                task.timestamp = DateTime.now();
              }
              _box!.putAt(_index, task);
            });
          },
          onLongPress: () {
            _box!.deleteAt(_index);
            setState(() {});
          },
        );
      },
    );
  }

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
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration:
                        const InputDecoration(labelText: 'Task Content'),
                    onChanged: (_value) {
                      _newTaskContent = _value;
                    },
                  ),
                  ListTile(
                    title: _newTaskDeadline == null
                        ? const Text("Set Deadline")
                        : Text(
                            "Deadline: ${DateFormat('MMM d, y hh:mm a').format(_newTaskDeadline!)}"),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _newTaskDeadline = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_newTaskContent != null) {
                        var task = Task(
                          content: _newTaskContent!,
                          timestamp: DateTime.now(),
                          done: false,
                          deadline: _newTaskDeadline,
                        );
                        _box?.add(task);
                        setState(() {
                          _newTaskContent = null;
                          _newTaskDeadline = null;
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: const Text('Add Task'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
