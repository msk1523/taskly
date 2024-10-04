class Task {
  String content;
  DateTime timestamp;
  bool done;

  Task({
    required this.content,
    required this.timestamp,
    required this.done,
  });

  //we are going to save these data into the hive database
  //we are gonna convert the task class into a map so that we can store it in hive

  factory Task.fromMap(Map task) {
    return Task(
      content: task['content'],
      timestamp: task['timestamp'],
      done: task['done'],
    );
  } //factory constructor is used to return an instance of the class, it is an extension for the constructor that returns an instance
  Map toMap() {
    return {
      'content': content,
      'timestamp': timestamp,
      'done': done,
    };
  }
}
