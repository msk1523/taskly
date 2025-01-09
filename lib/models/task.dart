import 'package:hive/hive.dart';

part 'task.g.dart'; // Needed for Hive type adapter generator

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String content;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  bool done;

  @HiveField(3)
  DateTime? deadline;

  Task({
    required this.content,
    required this.timestamp,
    required this.done,
    this.deadline,
  });
}

// TypeAdapter for Hive
// class TaskAdapter extends TypeAdapter<Task> {
//   @override
//   final int typeId = 0;

//   @override
//   Task read(BinaryReader reader) {
//     final content = reader.readString();
//     final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
//     final done = reader.readBool();
//     final deadlineMillis = reader.read(); // Reads null-safe deadline
//     DateTime? deadline = deadlineMillis != null
//         ? DateTime.fromMillisecondsSinceEpoch(deadlineMillis)
//         : null;

//     return Task(
//       content: content,
//       timestamp: timestamp,
//       done: done,
//       deadline: deadline,
//     );
//   }

//   @override
//   void write(BinaryWriter writer, Task obj) {
//     writer.writeString(obj.content);
//     writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
//     writer.writeBool(obj.done);
//     writer.write(obj.deadline?.millisecondsSinceEpoch);
//   }
// }
